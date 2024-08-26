
---@class Features.EpicEncountersStatsTabKeywords
local Stats = Epip.GetFeature("Features.EpicEncountersStatsTabKeywords")

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the current free reaction charges of char.
---@param char EsvCharacter
---@param reaction string TODO
---@return integer?
function Stats.GetCurrentCharges(char, reaction)
    local db = Osi.DB_AMER_Reaction_FreeCount_Remaining:Get(char, reaction, nil)
    return #db > 0 and db[1][3] or nil
end

---Returns a regeneration extended stat of char.
---@param char EsvCharacter
---@param regenType string
---@return integer
function Stats.GetRegen(char, regenType)
    local allRegenDb = Osi.DB_AMER_ExtendedStat_AddedStat:Get(char, "Regen_All", nil, nil, nil, nil)
    local requestedRegenDB = Osi.DB_AMER_ExtendedStat_AddedStat:Get(char, "Regen_" .. regenType, nil, nil, nil, nil)
    local amount = 0

    amount = amount + Stats._GetExtendedStatDBValue(allRegenDb)
    amount = amount + Stats._GetExtendedStatDBValue(requestedRegenDB)

    -- add BothArmor stat when requesting armor regen
    if regenType == "PhysicalArmor" or regenType == "MagicArmor" then
        local bothArmorRegenDb = Osi.DB_AMER_ExtendedStat_AddedStat:Get(char, "Regen_BothArmor", nil, nil, nil, nil)

        amount = amount + Stats._GetExtendedStatDBValue(bothArmorRegenDb)
    end

    return math.min(amount, 50)
end

---Returns the value within an extended stat DB.
---@param db any TODO
---@return integer
function Stats._GetExtendedStatDBValue(db)
    if #db == 0 then
        return 0
    end
    return db[1][6]
end
