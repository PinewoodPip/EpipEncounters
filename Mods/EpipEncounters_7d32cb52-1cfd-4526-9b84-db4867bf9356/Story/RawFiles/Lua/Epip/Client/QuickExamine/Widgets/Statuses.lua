
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local StatusPrefab = Generic.GetPrefab("GenericUI_Prefab_Status")

---@class Features.QuickExamine.Widgets.Statuses : Feature
local Statuses = {
    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h781196b1g2672g4814gba9cg909abae01815",
            Text = "Show statuses",
            ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
            Handle = "h70e80784gadb9g4d5agae96gc219142a7d43",
            Text = "If enabled, the Quick Examine UI will show the active and visible statuses of characters.",
            ContextDescription = "Setting tooltip",
        },
    },
    Settings = {},
}
Epip.RegisterFeature("Features.QuickExamine.Widgets.Statuses", Statuses)
local TSK = Statuses.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

Statuses.Settings.Enabled = Statuses:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = TSK.Setting_Enabled_Name,
    Description = TSK.Setting_Enabled_Description,
    DefaultValue = true,
})

---------------------------------------------
-- WIDGET
---------------------------------------------

---@type Features.QuickExamine.Widgets.Grid
local Widget = {
    HEADER_LABEL = Text.CommonStrings.Statuses,
    Setting = Statuses.Settings.Enabled,
}
Statuses:RegisterClass("Features.QuickExamine.Widgets.Statuses.Widget", Widget, {"Features.QuickExamine.Widgets.Grid"})
QuickExamine.RegisterWidget(Widget)

---@override
function Widget:CanRender(entity)
    return Statuses:IsEnabled() and Entity.IsCharacter(entity)
end

---@override
function Widget:RenderGridElements(entity)
    local char = entity ---@type EclCharacter

    local statuses = char:GetStatusObjects() ---@type EclStatus[]
    for i,status in ipairs(statuses) do
        if Stats.IsStatusVisible(status) then
            local _ = StatusPrefab.Create(QuickExamine.UI, status.StatusId .. "_" .. tostring(i), self.Grid, char, status, Vector.Create(self.ELEMENT_SIZE, self.ELEMENT_SIZE))
        end
    end
    self.Grid:RepositionElements() -- Necessary due to how Statuses initialize.
end
