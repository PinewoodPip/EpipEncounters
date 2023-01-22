
---@class EpicEncounters_BatteredHarriedLib
local BH = EpicEncounters.BatteredHarried

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the buffered damage towards char's next stack, relative to its maximum HP.
---@param char EclCharacter
---@return number In range `[0, 1)`
function BH.GetBufferedDamage(char)
    local _, amount = Osiris.DB_AMER_BatteredHarried_BufferedDamage(char, nil)

    return amount or 0
end