
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local Textures = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local CommonStrings = Text.CommonStrings
local V = Vector.Create

local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local RadialMenuUI = RadialMenus.UI
local TSK = RadialMenus.TranslatedStrings

local UI = Generic.Create("Features.RadialMenus.UI.MenuCreator", 15) ---@class Features.RadialMenus.UI.MenuCreator : GenericUI_Instance
RadialMenus.MenuCreatorUI = UI
UI.CONTENT_SIZE = V(670, 500)
UI.HEADER_SIZE = V(400, 50)
UI.SETTING_SIZE = V(650, 50)
UI._MenuBeingEdited = nil ---@type Features.RadialMenus.Menu?

---@class Features.RadialMenus.UI.MenuCreator.Hooks
UI.Hooks = UI.Hooks
UI.Hooks.CreateMenu = UI:AddSubscribableHook("CreateMenu") ---@type Hook<Features.RadialMenus.UI.MenuCreator.Hooks.CreateMenu>

---@class Features.RadialMenus.UI.MenuCreator.Events : GenericUI.Instance.Events
UI.Events = UI.Events
UI.Events.RenderMenuSettings = UI:AddSubscribableEvent("RenderMenuSettings") ---@type Event<Features.RadialMenus.UI.MenuCreator.Events.RenderMenuSettings>
UI.Events.UpdateMenu = UI:AddSubscribableEvent("UpdateMenu") ---@type Event<{Menu:Features.RadialMenus.Menu}> Thrown when editing a menu has finished.

local MenuTypes = {
    Hotbar = RadialMenus:GetClass("Features.RadialMenus.Menu.Hotbar"),
}
local Settings = {
    MenuName = RadialMenus:RegisterSetting("MenuCreator.MenuName", {
        Type = "String",
        Name = CommonStrings.Name, -- I don't feel this needs a description.
        DefaultValue = TSK.Label_NewMenu:GetString(),
    }),
    NewMenuType = RadialMenus:RegisterSetting("MenuCreator.NewMenuType", {
        Type = "Choice",
        Name = TSK.Setting_NewMenuType_Name,
        Description = TSK.Setting_NewMenuType_Description,
        DefaultValue = 1,
        ---@type SettingsLib_Setting_Choice_Entry[]
        Choices = {
            {ID = MenuTypes.Hotbar:GetClassName(), Name = Text.Resolve(MenuTypes.Hotbar:GetTypeName())},
        }
    }),
    HotbarStartIndex = RadialMenus:RegisterSetting("HotbarStartIndex", {
        Type = "ClampedNumber",
        Name = TSK.Setting_HotbarStartIndex_Name,
        Description = TSK.Setting_HotbarStartIndex_Description,
        Min = 1,
        Max = 145, -- TODO consider HotbarSlots min?
        Step = 1,
        HideNumbers = false,
        DefaultValue = 1,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
    HotbarSlots = RadialMenus:RegisterSetting("HotbarSlots", {
        Type = "ClampedNumber",
        Name = CommonStrings.Slots,
        Description = TSK.Setting_HotbarSlots_Description,
        Min = 5, -- 1/2-slot radial menus break the fabric of reality, low amounts look bad with the curve graphics
        Max = 20,
        Step = 1,
        HideNumbers = false,
        DefaultValue = 10,
        PreferredRepresentation = "Spinner", ---@type Features.SettingWidgets.PreferredRepresentation.ClampedNumber
    }),
}

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.RadialMenus.UI.MenuCreator.Hooks.CreateMenu
---@field Menu Features.RadialMenus.Menu? Hookable. Defaults to `nil`.

---@class Features.RadialMenus.UI.MenuCreator.Events.RenderMenuSettings
---@field MenuType classname
---@field Container GenericUI_Element_VerticalList

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI to create a new menu.
function UI.SetupCreation()
    UI._MenuBeingEdited = nil
    UI._Setup()
end

---Sets up the UI to edit an existing menu.
---@param menu Features.RadialMenus.Menu
function UI.SetupEdit(menu)
    UI._MenuBeingEdited = menu
    UI._Setup()
end

function UI._Setup()
    local isEditing = UI._IsEditing()
    UI._Initialize()

    -- Update static elements
    UI.CreateButton:SetLabel(isEditing and CommonStrings.Save or CommonStrings.Create)

    UI._RenderSharedSettings()
    UI._RenderMenuTypeSettings()

    UI:SetPositionRelativeToViewport("center", "center")
    UI:Show()
end

---Creates a menu from the current setting values and closes the UI.
function UI._CreateMenu()
    local menu = UI.Hooks.CreateMenu:Throw({
        Menu = nil,
    }).Menu
    if menu then -- Add the menu and set it as the active one
        RadialMenus.AddMenu(menu)
        RadialMenuUI.SetCurrentMenu(menu)
    else
        UI:__LogWarning("_CreateMenu()", "No CreateMenu hooks responded")
    end
    UI:Hide()
end

---Applies the edits to the current menu.
function UI._SaveEdits()
    local menu = UI._MenuBeingEdited
    if not menu then UI:__Error("_SaveEdits", "Not editing a menu") end
    UI.Events.UpdateMenu:Throw({
        Menu = menu,
    })
    RadialMenuUI.Refresh()
    UI:Hide()
end

---Initializes the static elements of the UI.
function UI._Initialize()
    if UI._Initialized then return end

    local root = UI:CreateElement("Root", "GenericUI_Element_Texture")
    root:SetTexture(Textures.PANELS.CLIPBOARD_FEEDBACK)
    UI.Root = root

    -- Auxiliary rect to simplify positioning
    local contentArea = root:AddChild("Content", "GenericUI_Element_TiledBackground")
    contentArea:SetBackground("Black", UI.CONTENT_SIZE:unpack())
    contentArea:SetAlpha(0)
    contentArea:SetPositionRelativeToParent("TopLeft", 100, 100)

    local header = TextPrefab.Create(UI, "Header", contentArea, TSK.Label_CreateNewMenu:GetString(), "Center", V(500, 50))
    header:SetPositionRelativeToParent("Top")

    local contentList = contentArea:AddChild("ContentList", "GenericUI_Element_ScrollList")
    contentList:SetPositionRelativeToParent("TopLeft", 0, 50)
    contentList:SetFrame(UI.CONTENT_SIZE)

    -- Setting lists
    local sharedSettingsList = contentList:AddChild("SharedSettingsList", "GenericUI_Element_VerticalList")
    UI.SharedSettingsList = sharedSettingsList
    UI._RenderSharedSettings()

    local menuSpecificSettingsList = contentList:AddChild("MenuSpecificSettingsList", "GenericUI_Element_VerticalList")
    UI.MenuSpecificSettingsList = menuSpecificSettingsList
    UI._RenderMenuTypeSettings()

    -- "Create" button
    local createButton = ButtonPrefab.Create(UI, "CreateButton", root, ButtonPrefab:GetStyle("DOS1Blue"))
    createButton:SetLabel(CommonStrings.Create)
    createButton:SetPositionRelativeToParent("Bottom", 0, -50)
    createButton.Events.Pressed:Subscribe(function (_)
        UI._Finish()
    end)
    UI.CreateButton = createButton

    -- Set panel size
    local uiObj = UI:GetUI()
    uiObj.SysPanelSize = {root:GetSize():unpack()}

    UI._Initialized = true
end

---Renders the shared setting widgets.
function UI._RenderSharedSettings()
    local list = UI.SharedSettingsList
    list:Clear()

    SettingWidgets.RenderSetting(UI, list, Settings.MenuName, UI.SETTING_SIZE)

    -- Cannot edit the type of existing menus.
    if not UI._IsEditing() then
        SettingWidgets.RenderSetting(UI, list, Settings.NewMenuType, UI.SETTING_SIZE, function (_)
            UI._RenderMenuTypeSettings()
        end)
    end

    list:RepositionElements()
end

---Renders settings specific to the selected menu type.
---@see Features.RadialMenus.UI.MenuCreator.Events.RenderMenuSettings
function UI._RenderMenuTypeSettings()
    local list = UI.MenuSpecificSettingsList
    list:Clear()
    UI.Events.RenderMenuSettings:Throw({
        MenuType = Settings.NewMenuType:GetValue(),
        Container = list,
    })
end

---Confirms the creation or edits of the menu.
function UI._Finish()
    if UI._IsEditing() then
        UI._SaveEdits()
    else
        UI._CreateMenu()
    end
end

---Returns whether the UI is being used to edit an existing menu.
---@return boolean
function UI._IsEditing()
    return UI._MenuBeingEdited ~= nil
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show the creator UI when a new menu or edit is requested.
RadialMenuUI.Events.NewMenuRequested:Subscribe(function (_)
    UI.SetupCreation()
end)
RadialMenuUI.Events.EditMenuRequested:Subscribe(function (ev)
    UI.SetupEdit(ev.Menu)
end)

-- Create menus when requested.
UI.Hooks.CreateMenu:Subscribe(function (ev)
    local menuClass = Settings.NewMenuType:GetValue()
    local menuName = Settings.MenuName:GetValue()
    if menuClass == MenuTypes.Hotbar:GetClassName() then -- Hotbar
        local startingIndex, slots = Settings.HotbarStartIndex:GetValue(), Settings.HotbarSlots:GetValue()
        ev.Menu = MenuTypes.Hotbar.Create(menuName, startingIndex, slots)
    end
end, {StringID = "DefaultImplementation"})

-- Apply menu edits.
UI.Events.UpdateMenu:Subscribe(function (ev)
    local menu = ev.Menu
    menu.Name = Settings.MenuName:GetValue()
    if menu:GetClassName() == MenuTypes.Hotbar:GetClassName() then
        ---@cast menu Features.RadialMenus.Menu.Hotbar
        menu.StartingIndex = Settings.HotbarStartIndex:GetValue()
        menu.SlotsAmount = Settings.HotbarSlots:GetValue()
    end
end, {StringID = "DefaultImplementation"})

-- Render menu-specific settings.
UI.Events.RenderMenuSettings:Subscribe(function (ev)
    local container = ev.Container
    if ev.MenuType == MenuTypes.Hotbar:GetClassName() then
        SettingWidgets.RenderSetting(UI, container, Settings.HotbarStartIndex, UI.SETTING_SIZE)
        SettingWidgets.RenderSetting(UI, container, Settings.HotbarSlots, UI.SETTING_SIZE)
    end
end, {StringID = "DefaultImplementation"})
