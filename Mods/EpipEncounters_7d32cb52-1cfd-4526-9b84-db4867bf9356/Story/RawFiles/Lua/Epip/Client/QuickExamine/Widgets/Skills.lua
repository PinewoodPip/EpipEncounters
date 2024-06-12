
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local V = Vector.Create

---@class Features.QuickExamine.Widgets.Skills : Feature
local Skills = {
    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h186d9f82g7ad6g4113gb261g2a5eb62cf612",
            Text = "Show skills",
            ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
            Handle = "h41f3c758g87e9g4caegb1eeg5e324bd1564a",
            Text = "If enabled, the Quick Examine UI will show the skills of player characters and their cooldowns.",
            ContextDescription = "Setting tooltip",
        },
    },
    Settings = {},
}
Epip.RegisterFeature("Features.QuickExamine.Widgets.Skills", Skills)
local TSK = Skills.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

Skills.Settings.Enabled = Skills:RegisterSetting("Enabled", {
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
    HEADER_LABEL = Text.CommonStrings.Skills,
    Setting = Skills.Settings.Enabled,
}
Skills:RegisterClass("Features.QuickExamine.Widgets.Skills.Widget", Widget, {"Features.QuickExamine.Widgets.Grid"})
QuickExamine.RegisterWidget(Widget)

---@override
function Widget:CanRender(entity)
    return Skills:IsEnabled() and Entity.IsCharacter(entity) and not table.isempty(entity.SkillManager.Skills)
end

---@override
function Widget:RenderGridElements(entity)
    local skills = entity.SkillManager.Skills
    for skill,_ in pairs(skills) do
        self:RenderSkill(entity, skill)
    end
end

---Renders a skill onto the grid.
---@param char EclCharacter
---@param skillID string
function Widget:RenderSkill(char, skillID)
    local skill = Stats.Get("StatsLib_StatsEntry_SkillData", skillID)
    local state = char.SkillManager.Skills[skillID]

    if state and Character.IsSkillMemorized(char, skillID) then
        local element = HotbarSlot.Create(QuickExamine.UI, skillID, self.Grid, {CooldownAnimations = true})
        local cooldown = state.ActiveCooldown
        local handle = char.Handle

        element:SetUpdateDelay(-1)
        element:SetUsable(false)
        element:SetSkill(skillID)
        element:SetEnabled(cooldown <= 0)
        element:SetCooldown(math.ceil(cooldown / 6), false)
        element:SetIcon(skill.Icon)
        element:SetSize(self.ELEMENT_SIZE, self.ELEMENT_SIZE)

        element.Hooks.GetTooltipData:Subscribe(function (ev)
            local position = V(QuickExamine.UI:GetUI():GetPosition())

            ev.Owner = Character.Get(handle)
            ev.Position = position - V(420, 0) -- Rough width of tooltip UI
        end)
    end
end
