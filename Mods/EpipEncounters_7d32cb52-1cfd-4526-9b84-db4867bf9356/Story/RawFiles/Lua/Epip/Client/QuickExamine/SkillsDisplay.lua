
local QuickExamine = Epip.GetFeature("Feature_QuickExamine")
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
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
        local element = container:AddChild(skillID, "GenericUI_Element_Slot")
        local movieClip = element:GetMovieClip()
        local cooldown = state.ActiveCooldown
        local handle = char.Handle

        element:SetEnabled(cooldown <= 0)
        element:SetCooldown(math.ceil(cooldown / 6), false)
        element:SetIcon(skill.Icon, 50, 50)
        movieClip.width = Skills.SKILL_ICON_SIZE
        movieClip.height = Skills.SKILL_ICON_SIZE
    
        element.Events.MouseOver:Subscribe(function (_) -- Show tooltip.
            local position = V(QuickExamine.UI:GetUI():GetPosition())

            Client.Tooltip.ShowSkillTooltip(Character.Get(handle), skillID, position - V(420, 0))
        end)
        element.Events.MouseOut:Subscribe(function (_) -- Hide tooltip.
            Client.Tooltip.HideTooltip()
        end)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

QuickExamine.Events.EntityChanged:RegisterListener(function (entity)

    if Skills:IsEnabled() and Entity.IsCharacter(entity) then
        local hasSkills = not table.isempty(entity.SkillManager.Skills)

        if hasSkills then
            local container = QuickExamine.GetContainer()
    
            TextPrefab.Create(QuickExamine.UI, "SkillsDisplay_Header", container, "Skills", "Center", V(QuickExamine.GetContainerWidth(), 30))

            local grid = container:AddChild("SkillsDisplay_Grid", "GenericUI_Element_Grid")

            grid:SetCenterInLists(true)
            grid:SetGridSize(QuickExamine.GetContainerWidth() / Skills.SKILL_ICON_SIZE - 2, -1)

            local skills = entity.SkillManager.Skills
            for skill,_ in pairs(skills) do
                Skills._RenderSkill(grid, entity, skill)
            end

            local div = container:AddChild("QuickExamine_Divider", "GenericUI_Element_Divider")
            div:SetSize(QuickExamine.DIVIDER_WIDTH)
        end
    end
end)