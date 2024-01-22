
local Input = Client.Input
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local DraggingArea = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local CommonStrings = Text.CommonStrings
local SettingsLib = Settings
local V = Vector.Create

---@class Features.SurfacePainter
local SurfacePainter = Epip.GetFeature("Features.SurfacePainter")
local UI = Generic.Create("Features.SurfacePainter")
SurfacePainter.UI = UI

UI.PANEL_SIZE = V(600, 300)
UI.DRAG_AREA_SIZE = V(UI.PANEL_SIZE[1], 50)
UI.HEADER_SIZE = Vector.Clone(UI.DRAG_AREA_SIZE)
UI.SETTING_SIZE = V(UI.PANEL_SIZE[1] - 20, 50)

local TSK = {
    Setting_SurfaceType_Name = SurfacePainter:RegisterTranslatedString({
        Handle = "h3ffa6f44g1a2bg400ega4a1gcd72590aa73f",
        Text = "Surface Type",
        ContextDescription = "Dropdown name",
    }),
    InputAction_ToggleUI_Name = SurfacePainter:RegisterTranslatedString({
        Handle = "hfafda83bg44a1g4985g890eg761c814db0c8",
        Text = "Toggle Surface Painter",
        ContextDescription = "Keybind name; used in developer mode only",
    }),
    InputAction_ToggleUI_Description = SurfacePainter:RegisterTranslatedString({
        Handle = "h5cb514c6g75c3g4309g95e6g4fb71e5ba1f3",
        Text = "Toggles the Surface Painter UI.",
        ContextDescription = "Keybind tooltip; used in developer mode only",
    }),
    Header = SurfacePainter:RegisterTranslatedString({
        Handle = "hc55a2a98g37ddg4140gacc9gf4b048f7180f",
        Text = "Surface Painter",
        ContextDescription = "Header for the UI",
    }),
}

local InputActions = {
    ToggleUI = SurfacePainter:RegisterInputAction("ToggleUI", {
        Name = TSK.InputAction_ToggleUI_Name,
        Description = TSK.InputAction_ToggleUI_Description,
        DeveloperOnly = true,
    }),
}

-- Generate Choices for unmodified surface types.
---@type ({Index:integer, ID:SurfaceType}|SettingsLib_Setting_Choice_Entry)[]
local surfaceTypeChoices = {
    {Index = -1, ID = "None", Name = "None"}, -- Not present in the enum, but valid for the Osiris call.
}
for i,v in ipairs(Ext.Enums.SurfaceType) do
    local id = v.Label

    -- Only add the unmodified versions of each surface.
    -- ShockwaveCloud is not usable in Osiris (appears to be missing from the string -> enum functions)
    if not id:find("Blessed$") and not id:find("Cursed$") and not id:find("Purified$") and v ~= Ext.Enums.SurfaceType.Sentinel and v ~= Ext.Enums.SurfaceType.ShockwaveCloud then
        table.insert(surfaceTypeChoices, {Index = i, ID = id, Name = id})
    end
end
table.sort(surfaceTypeChoices, function (a, b)
    return a.Index < b.Index
end)

local Settings = {
    SurfaceType = SurfacePainter:RegisterSetting("SurfaceType", {
        Type = "Choice",
        Name = TSK.Setting_SurfaceType_Name,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = surfaceTypeChoices,
        DefaultValue = "None",
        Context = "Client",
    }),
    Modifier = SurfacePainter:RegisterSetting("Modifier", {
        Type = "Choice",
        Name = CommonStrings.Modifier,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = "", NameHandle = CommonStrings.None.Handle}, -- No modifier.
            {ID = "Blessed", NameHandle = CommonStrings.Blessed.Handle},
            {ID = "Cursed", NameHandle = CommonStrings.Cursed.Handle},
            {ID = "Purified", NameHandle = CommonStrings.Purified.Handle},
        },
        DefaultValue = "",
        Context = "Client",
    }),
    Radius = SurfacePainter:RegisterSetting("Radius", {
        Type = "ClampedNumber",
        Name = CommonStrings.Radius,
        Min = 1,
        Max = 20,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 3,
    }),
    -- Units are turns, not seconds.
    Duration = SurfacePainter:RegisterSetting("Duration", {
        Type = "ClampedNumber",
        Name = CommonStrings.Duration,
        Min = -1,
        Max = 10,
        Step = 1,
        HideNumbers = false,
        DefaultValue = -1,
    }),
}
surfaceTypeChoices = nil -- Dispose of the local.

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function UI:Show()
    UI:_Initialize()
    Client.UI._BaseUITable.Show(self)
end

---Creates the UI's elements, if necessary.
function UI._Initialize()
    if UI._Initialized then return end

    local panel = UI:CreateElement("BG", "GenericUI_Element_TiledBackground")
    panel:SetBackground("Black", UI.PANEL_SIZE:unpack())
    panel:SetAlpha(0.7)

    local _ = DraggingArea.Create(UI, "DragArea", panel, UI.DRAG_AREA_SIZE)

    local header = TextPrefab.Create(UI, "Header", panel, TSK.Header:GetString(), "Center", UI.HEADER_SIZE)
    header:SetPositionRelativeToParent("Top", 0, 10)

    local settingsList = panel:AddChild("SettingsList", "GenericUI_Element_VerticalList")
    SettingWidgets.RenderSetting(UI, settingsList, Settings.SurfaceType, UI.SETTING_SIZE, function (value)
        -- Set the "Modifier" setting to None for surfaces that cannot be modified.
        if SurfacePainter.SURFACES_WITH_NO_MODIFIERS[value] then
            local modifierSetting = Settings.Modifier
            SettingsLib.SetValue(modifierSetting.ModTable, modifierSetting:GetID(), "")
        end
    end)
    SettingWidgets.RenderSetting(UI, settingsList, Settings.Modifier, UI.SETTING_SIZE) -- TODO grey out for non-modifable surfaces
    SettingWidgets.RenderSetting(UI, settingsList, Settings.Duration, UI.SETTING_SIZE)
    SettingWidgets.RenderSetting(UI, settingsList, Settings.Radius, UI.SETTING_SIZE)
    settingsList:RepositionElements()
    settingsList:SetPositionRelativeToParent("Top", 0, header:GetHeight() + 10)

    UI._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Set surface data based on preferences set in the UI.
-- Active only while the UI is visible.
SurfacePainter.Hooks.GetSurfaceData:Subscribe(function (ev)
    local modifier = Settings.Modifier:GetValue()
    local surfaceType = Settings.SurfaceType:GetValue()
    if SurfacePainter.SURFACES_WITH_NO_MODIFIERS[surfaceType] then
        modifier = ""
    end

    -- Append modifier as suffix
    surfaceType = surfaceType .. modifier

    ev.Request = {
        SurfaceType = surfaceType,
        LifeTime = Settings.Duration:GetValue() * 6, -- The setting is in turns.
        Radius = Settings.Radius:GetValue(),
        Position = Pointer.GetWalkablePosition(),
    }
end, {StringID = "DefaultImplementationFromUI", EnabledFunctor = function ()
    return UI:IsVisible()
end})

-- Toggle the UI when the input action is executed.
-- TODO move
Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action:GetID() == InputActions.ToggleUI:GetID() then
        SurfacePainter.UI:ToggleVisibility()
    end
end)
