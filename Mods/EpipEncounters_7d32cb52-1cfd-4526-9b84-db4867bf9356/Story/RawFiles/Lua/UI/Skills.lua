
---@class SkillsUI : UI
local Skills = {
    selectedSkill = nil, ---@type string
}
Client.UI.Skills = Skills
Epip.InitializeUI(Ext.UI.TypeID.skills, "Skills", Skills)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the skill currently being hovered over.
---@return string?
function Skills.GetSelectedSkill()
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