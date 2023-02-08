
---@class StatsLib
local Stats = Stats

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns a SkillData stats by its ID.
---@param skillID string
---@return StatsLib_StatsEntry_SkillData?
function Stats.GetSkillData(skillID)
    return Stats.Get("SkillData", skillID)
end