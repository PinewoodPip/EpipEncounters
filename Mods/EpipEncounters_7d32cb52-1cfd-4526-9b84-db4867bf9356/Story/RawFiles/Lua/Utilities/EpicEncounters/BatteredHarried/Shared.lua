
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
    local pattern = BH.STATUS_PATTERNS.BATTERED -- Default to Battered

    if type == "Harried" or type == "H" then
        pattern = BH.STATUS_PATTERNS.HARRIED
    end

    -- Search statuses
    for _,status in pairs(char:GetStatuses()) do
        local amount = status:match(pattern)

        if amount then
            stacks = tonumber(amount)
            lifetime = char:GetStatus(status).CurrentLifeTime
            break
        end
    end

    return stacks,lifetime
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

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register databases for synching.
for _,data in pairs(BH.Databases) do
    DBSync.RegisterDatabase(data.DatabaseName, data.Arity, data.FieldNames)
end