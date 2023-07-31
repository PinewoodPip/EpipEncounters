
---------------------------------------------
-- Adjusts the layer of textDisplay.swf to show above the hotbar.
---------------------------------------------

local TextDisplay = Client.UI.TextDisplay
local Hotbar = Client.UI.Hotbar
local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
local TSK = TooltipAdjustments.TranslatedStrings

---------------------------------------------
-- TRANSLATED STRINGS
---------------------------------------------

TSK.TooltipLayer_Setting_Name = TooltipAdjustments:RegisterTranslatedString("hcc271c27g1f31g42f9gafd3g989f2fc5dccd", {
    Text = "Increase Surface Tooltip UI Layer",
    ContextDescription = "Setting name",
})
TSK.TooltipLayer_Setting_Tooltip = TooltipAdjustments:RegisterTranslatedString("h3e92415fg1242g4d2dg8297g4f4ed3d3d413", {
    Text = "If enabled, increases the layer of the surface tooltip UI, which makes surface tooltips render over the hotbar instead of underneath it.",
    ContextDescription = "Setting description",
})

---------------------------------------------
-- SETTINGS
---------------------------------------------

TooltipAdjustments.Settings.TooltipLayer = TooltipAdjustments:RegisterSetting("TooltipLayer", {
    Type = "Boolean",
    Name = TSK.TooltipLayer_Setting_Name,
    Description = TSK.TooltipLayer_Setting_Tooltip,
    DefaultValue = true,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Updates the layer of the UI based on a setting value.
---@param enabled boolean
local function UpdateLayer(enabled)
    TextDisplay:GetUI().Layer = enabled and (Hotbar:GetUI().Layer + 1) or TextDisplay.DEFAULT_LAYER
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the setting value changing to update the layer.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting == TooltipAdjustments.Settings.TooltipLayer then
        UpdateLayer(ev.Value == true)
    end
end, {StringID = "TooltipAdjustments_TooltipLayer"})

-- Update the layer upon loading into the session.
GameState.Events.ClientReady:Subscribe(function (_)
    UpdateLayer(TooltipAdjustments:GetSettingValue(TooltipAdjustments.Settings.TooltipLayer) == true)
end, {StringID = "TooltipAdjustments_TooltipLayer"})