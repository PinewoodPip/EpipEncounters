
local DBSync = Epip.GetFeature("Feature_DatabaseSync")
local SourceInfusion = EpicEncounters.SourceInfusion

---@class EpicEncounters_BatteredHarriedLib : Library
local BH = {
    T3_STACKS_REQUIREMENT = 7,
    T3_STACKS_REQUIREMENT_INFUSING_REDUCTION = 2,
    STATUS_PATTERNS = {
        BATTERED = "^BATTERED_(%d+)$",
        HARRIED = "^HARRIED_(%d+)$",
    },
    STATUS_ICON_PREFIXES = {
        BATTERED = "AMER_Icon_Status_Battered_",
        HARRIED = "AMER_Icon_Status_Harried_",
    },

    -- Maps status ID to the Battered amount it represents.
    ---@type table<string, integer>
    BATTERED_STATUSES = {
        ["BATTERED_1"] = 1,
        ["BATTERED_2"] = 2,
        ["BATTERED_3"] = 3,
        ["BATTERED_4"] = 4,
        ["BATTERED_5"] = 5,
        ["BATTERED_6"] = 6,
        ["BATTERED_7"] = 7,
        ["BATTERED_8"] = 8,
        ["BATTERED_9"] = 9,
        ["BATTERED_10"] = 10,
    },
    -- Maps status ID to the Harried amount it represents.
    ---@type table<string, integer>
    HARRIED_STATUSES = {
        ["HARRIED_1"] = 1,
        ["HARRIED_2"] = 2,
        ["HARRIED_3"] = 3,
        ["HARRIED_4"] = 4,
        ["HARRIED_5"] = 5,
        ["HARRIED_6"] = 6,
        ["HARRIED_7"] = 7,
        ["HARRIED_8"] = 8,
        ["HARRIED_9"] = 9,
        ["HARRIED_10"] = 10,
    },

    ---@type table<string, Feature_DatabaseSync_DatabaseDefinition>
    Databases = {
        BufferedDamage = {
            DatabaseName = "DB_AMER_BatteredHarried_BufferedDamage",
            Arity = 2,
            FieldNames = {"CharacterGUID", "Amount"},
        },
    }
}
EpicEncounters.BatteredHarried = BH
Epip.InitializeLibrary("EpicEncounters_BatteredHarried", BH)

local _BATTERED_STATUSES_MAP = BH.BATTERED_STATUSES
local _HARRIED_STATUSES_MAP = BH.HARRIED_STATUSES

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class DB_AMER_BatteredHarried_BufferedDamage : OsirisLib_Tuple
---@field CharacterGUID GUID
---@field Amount number

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the current stacks on char, as well as lifetime. Queries the related status effects.
---@param char Character
---@param type StackType
---@return number, number --Stack count, duration left (as seconds)
function BH.GetStacks(char, type)
    local stacks = 0
    local lifetime = 0
    local statusesMap = _BATTERED_STATUSES_MAP -- Default to Battered
    if type == "Harried" or type == "H" then
        statusesMap = _HARRIED_STATUSES_MAP
    end

    -- Search for B/H statuses
    -- Note: GetStatus() by statusID is O(n), so it is better to do a single pass with GetStatuses()
    local statuses = char:GetStatusObjects() ---@type EclStatus[]
    for _,status in pairs(statuses) do
        local amount = statusesMap[status.StatusId]
        if amount then
            stacks = amount
            lifetime = status.CurrentLifeTime
            break
        end
    end

    return stacks, lifetime
end

---Returns the icon for a certain amount of a stack.
---@param stack "Battered"|"Harried"
---@param amount integer
---@return string
function BH.GetIcon(stack, amount)
    local icon = "unknown"

    if stack == "Battered" then
        icon = BH.STATUS_ICON_PREFIXES.BATTERED .. tostring(amount)
    elseif stack == "Harried" then
        icon = BH.STATUS_ICON_PREFIXES.HARRIED .. tostring(amount)
    end

    return icon
end

---Get the stack amount this character needs to apply a T3 to someone else under regular circumstances.
---**This only takes into account the bonus from infusing!**
---@param char Character
---@return number --Stacks needed
function BH.GetStacksNeededToInflictTier3(char)
    local amount = BH.T3_STACKS_REQUIREMENT

    if SourceInfusion.IsPreparingInfusion(char) then
        amount = amount - BH.T3_STACKS_REQUIREMENT_INFUSING_REDUCTION
    end

    return amount
end

---Returns whether a status is a BH display status.
---@param statusID string
---@return boolean
function BH.IsDisplayStatus(statusID)
    local isBH = false

    for _,pattern in pairs(BH.STATUS_PATTERNS) do
        if statusID:match(pattern) then
            isBH = true
            break
        end
    end

    return isBH
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register databases for synching.
for _,data in pairs(BH.Databases) do
    DBSync.RegisterDatabase(data.DatabaseName, data.Arity, data.FieldNames)
end