
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
        Combat:LogError("No combat found with ID " .. combatID)
        return nil
    end

    for _,team in ipairs(combat.CurrentRoundTeams) do
        local component = Ext.Entity.GetCombatComponent(team.Handle) ---@type EclCombatComponent
        local gameObject = Entity.GetGameObjectComponent(component.Base.Entity)

        table.insert(info.CurrentRound.Participants, gameObject)
    end
    for _,team in ipairs(combat.NextRoundTeams) do
        local component = Ext.Entity.GetCombatComponent(team.Handle) ---@type EclCombatComponent
        local gameObject = Entity.GetGameObjectComponent(component.Base.Entity)

        table.insert(info.NextRound.Participants, gameObject)
    end

    return info
end