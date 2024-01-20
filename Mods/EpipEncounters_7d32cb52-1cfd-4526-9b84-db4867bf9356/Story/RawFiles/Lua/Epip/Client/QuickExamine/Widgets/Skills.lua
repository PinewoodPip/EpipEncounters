
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local V = Vector.Create

---@class Features.QuickExamine.Widgets.Skills : Feature
local Skills = {
    SKILL_ICON_SIZE = 32,

    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h186d9f82g7ad6g4113gb261g2a5eb62cf612",
            Text = "Show Skills",
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
-- METHODS
---------------------------------------------

---@param container GenericUI_Element_Grid
---@param char EclCharacter
---@param skillID string
function Skills._RenderSkill(container, char, skillID)
    local skill = Stats.Get("StatsLib_StatsEntry_SkillData", skillID)
    local state = char.SkillManager.Skills[skillID]

    if state and Character.IsSkillMemorized(char, skillID) then
        local element = HotbarSlot.Create(QuickExamine.UI, skillID, container, {CooldownAnimations = true})
        local movieClip = element.SlotElement:GetMovieClip()
        local cooldown = state.ActiveCooldown
        local handle = char.Handle

        element:SetUpdateDelay(-1)
        element:SetUsable(false)
        element:SetSkill(skillID)
        element:SetEnabled(cooldown <= 0)
        element:SetCooldown(math.ceil(cooldown / 6), false)
        element:SetIcon(skill.Icon)
        movieClip.width = Skills.SKILL_ICON_SIZE
        movieClip.height = Skills.SKILL_ICON_SIZE

        element.Hooks.GetTooltipData:Subscribe(function (ev)
            local position = V(QuickExamine.UI:GetUI():GetPosition())

            ev.Owner = Character.Get(handle)
            ev.Position = position - V(420, 0) -- Rough width of tooltip UI
        end)
    end
end

---------------------------------------------
-- WIDGET
---------------------------------------------

---@type Features.QuickExamine.Widget
local Widget = {
    Setting = Skills.Settings.Enabled,
}
Skills:RegisterClass("Features.QuickExamine.Widgets.Skills.Widget", Widget, {"Features.QuickExamine.Widget"})
QuickExamine.RegisterWidget(Widget)

---@override
function Widget:CanRender(entity)
    return Skills:IsEnabled() and Entity.IsCharacter(entity) and not table.isempty(entity.SkillManager.Skills)
end

---@override
function Widget:Render(entity)
    local container = QuickExamine.GetContainer()

    self:CreateHeader("SkillsDisplay_Header", container, "Skills")

    local grid = container:AddChild("SkillsDisplay_Grid", "GenericUI_Element_Grid")

    grid:SetCenterInLists(true)
    grid:SetGridSize(QuickExamine.GetContainerWidth() / Skills.SKILL_ICON_SIZE - 2, -1)

    local skills = entity.SkillManager.Skills
    for skill,_ in pairs(skills) do
        Skills._RenderSkill(grid, entity, skill)
    end

    self:CreateDivider("SkillsDisplayDivider", container)
end
