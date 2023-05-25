
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
    SOURCE_GENERATION_DISPLAY_STATUSES = {
        "AMER_SOURCEGEN_DISPLAY_1",
        "AMER_SOURCEGEN_DISPLAY_2",
        "AMER_SOURCEGEN_DISPLAY_3",
        "AMER_SOURCEGEN_DISPLAY_4",
        "AMER_SOURCEGEN_DISPLAY_5",
        "AMER_SOURCEGEN_DISPLAY_6",
        "AMER_SOURCEGEN_DISPLAY_7",
    },
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

---Returns the display status ID
---for an amount of Source Generation.
---@param amount integer
---@return string? `nil` if amount is <= 0.
function SourceInfusion.GetGenerationDisplayStatus(amount)
    -- Source Gen beyond the maximum uses the last available status
    amount = math.min(amount or 0, #SourceInfusion.SOURCE_GENERATION_DISPLAY_STATUSES)
    local status = SourceInfusion.SOURCE_GENERATION_DISPLAY_STATUSES[amount]

    return status
end