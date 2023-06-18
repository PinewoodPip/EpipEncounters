
---@class CombatLib
local Combat = Combat

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class CombatLib_RoundInfo
---@field Participants (Character|Item)[]

---@class CombatLib_TurnOrder
---@field CurrentRound CombatLib_RoundInfo
---@field NextRound CombatLib_RoundInfo
---@field CombatID uint8

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the character participants of a combat.
---@return CombatLib_TurnOrder
function Combat.GetTurnOrder(combatID)
    ---@type CombatLib_TurnOrder
    local info = {
        CombatID = combatID,
        CurrentRound = {
            Participants = {},
        },
        NextRound = {
            Participants = {},
        },
    } 
    local combat = Combat.GetCombat(combatID)
    if not combat then
        Combat:Error("GetTurnOrder", "No combat found with ID", combatID)
    end

    for _,team in ipairs(combat.CurrentRoundTeams) do
        local component = Ext.Entity.GetCombatComponent(team.Handle) ---@type EclCombatComponent
        local gameObject = Entity.GetGameObjectComponent(component.Entity)

        table.insert(info.CurrentRound.Participants, gameObject)
    end
    for _,team in ipairs(combat.NextRoundTeams) do
        local component = Ext.Entity.GetCombatComponent(team.Handle) ---@type EclCombatComponent
        local gameObject = Entity.GetGameObjectComponent(component.Entity)

        table.insert(info.NextRound.Participants, gameObject)
    end

    return info
end