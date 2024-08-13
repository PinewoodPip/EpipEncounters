
---@class StatsLib
local Stats = Stats

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns a SkillData stats by its ID.
---@param skillID string
---@return StatsLib_StatsEntry_SkillData?
function Stats.GetSkillData(skillID)
    return Stats.Get("StatsLib_StatsEntry_SkillData", skillID)
end

---Removes the level suffix for a skill ID, if any.
---@param skillID skill
---@return skill
function Stats.RemoveLevelSuffix(skillID)
    local newSkillID, _ = string.gsub(skillID, "_%-?%d*$", "") -- Only -1 is ever used by the game from what I know, but I don't think levelled skills are entirely deprecated.
    return newSkillID
end
