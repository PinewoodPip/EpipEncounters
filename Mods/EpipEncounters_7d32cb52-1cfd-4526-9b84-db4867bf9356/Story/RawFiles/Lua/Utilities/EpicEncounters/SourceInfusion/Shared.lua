
---@class EpicEncountersLib
local EpicEncounters = EpicEncounters

---@class EpicEncountersLib_SourceInfusionLib : Library
local SourceInfusion = {
    PATTERNS = {
        INFUSING_STATUS = "AMER_SOURCEINFUSION_(%d+)",
    },
    -- Skill ability levels required for each infusion level.
    INFUSION_ABILITY_REQUIREMENTS = {
        0,
        5,
        9,
    },
    MAX_INFUSION_LEVEL = 3,
}
Epip.InitializeLibrary("EpicEncounters_SourceInfusion", SourceInfusion)
EpicEncounters.SourceInfusion = SourceInfusion

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the infusion level that char is currently preparing (how many times they've cast Source Infuse).
---@param char Character
---@return number --Infusion count.
function SourceInfusion.GetPreparedInfusionLevel(char)
    local level = 0

    for _,status in pairs(char:GetStatuses()) do
        local match = status:match(SourceInfusion.PATTERNS.INFUSING_STATUS)

        if match then
            level = tonumber(match)
            break
        end
    end

    return level
end

---Returns whether char is preparing a Source Infusion.
---@param char Character
---@return boolean
function SourceInfusion.IsPreparingInfusion(char)
    return SourceInfusion.GetPreparedInfusionLevel(char) > 0
end