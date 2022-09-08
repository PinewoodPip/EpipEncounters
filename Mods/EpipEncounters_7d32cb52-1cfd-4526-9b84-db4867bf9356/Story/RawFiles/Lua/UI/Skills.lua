
---@class SkillsUI : UI
local Skills = {
    selectedSkill = nil, ---@type string
}
Epip.InitializeUI(Ext.UI.TypeID.skills, "Skills", Skills)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the skill currently being hovered over.
---@return string?
function Skills.GetSelectedSkill()
    -- Exiting the UI without hovering out of a skill will not fire hideTooltip; we must clear the selected skill ourselves.
    if not Skills:IsVisible() then
        Skills.selectedSkill = nil
    end

    return Skills.selectedSkill
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Track the selected skill by listening for the tooltip.
Skills:RegisterCallListener("showSkillTooltip", function(_, _, skillID)
    Skills.selectedSkill = skillID
end)

Skills:RegisterCallListener("hideTooltip", function(_)
    Skills.selectedSkill = nil
end)