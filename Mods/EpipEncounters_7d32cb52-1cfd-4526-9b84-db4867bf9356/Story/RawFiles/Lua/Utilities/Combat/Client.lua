
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
-- function Combat.GetTurnOrder(combatID) -- Commented out as we do not have access to CombatComponent atm, making fetching the actual characters/items ridiculously hard.
--     ---@type CombatLib_TurnOrder
--     local info = {
--         CombatID = combatID,
--         CurrentRound = {
--             Participants = {},
--         },
--         NextRound = {
--             Participants = {},
--         },
--     } 
--     local combat = Combat.GetCombat(combatID)

--     for _,team in ipairs(combat.CurrentRoundTeams) do
--         local entity = Entity.Get(team.Handle)

--         table.insert(info.CurrentRound.Participants, entity)
--     end
--     for _,team in ipairs(combat.NextRoundTeams) do
--         local entity = Entity.Get(team.Handle)

--         table.insert(info.NextRound.Participants, entity)
--     end

--     return info
-- end