
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local V = Vector.Create

---@class Feature_QuickExamine_SkillsDisplay : Feature
local Skills = {
    SKILL_ICON_SIZE = 32,
}
Epip.RegisterFeature("QuickExamine_SkillsDisplay", Skills)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param container GenericUI_Element_Grid
---@param char EclCharacter
---@param skillID string
function Skills._RenderSkill(container, char, skillID)
    local skill = Stats.Get("SkillData", skillID)
    local state = char.SkillManager.Skills[skillID]

    if state and Character.IsSkillMemorized(char, skillID) then
        local element = HotbarSlot.Create(QuickExamine.UI, skillID, container)
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

local Widget = QuickExamine.RegisterWidget("SkillsDisplay", {Setting = {
    ID = "Widget_Skills",
    Type = "Boolean",
    Name = "Show Skills",
    Description = "Shows the skills of player characters and their cooldowns. Does not apply to non-player characters.",
    DefaultValue = true,
}})

function Widget:CanRender(entity)
    return Skills:IsEnabled() and Entity.IsCharacter(entity) and not table.isempty(entity.SkillManager.Skills)
end

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