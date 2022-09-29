
---@class CombatLib : Library
Combat = {}
Epip.InitializeLibrary("Combat", Combat)

---------------------------------------------
-- METHODS
---------------------------------------------

---@return EclTurnManager|EsvTurnManager
function Combat.GetTurnManager()
    -- Yet another unfortunate inconsistency.
    if Ext.IsClient() then
        return Ext.Entity.GetTurnManager()
    else
        return Ext.Combat.GetTurnManager()
    end
end

---@param combatID integer
---@return EclTurnManagerCombat|EsvTurnManagerCombat
function Combat.GetCombat(combatID)
    local manager = Combat.GetTurnManager()

    return manager.Combats[combatID]
end