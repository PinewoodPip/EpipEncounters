
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
-- function Combat.GetTurnOrder(combatID) -- Commented out as fetching Combat components appears to not currently work?
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

--     if not combat then
--         Combat:LogError("No combat found with ID " .. combatID)
--     end

--     for _,team in ipairs(combat.CurrentRoundTeams) do
--         local entity = Entity.GetEntity(team.Handle)

--         table.insert(info.CurrentRound.Participants, Entity.GetGameObjectComponent(entity))
--     end
--     for _,team in ipairs(combat.NextRoundTeams) do
--         local entity = Entity.GetEntity(team.Handle)

--         table.insert(info.NextRound.Participants, Entity.GetGameObjectComponent(entity))
--     end

--     return info
-- end