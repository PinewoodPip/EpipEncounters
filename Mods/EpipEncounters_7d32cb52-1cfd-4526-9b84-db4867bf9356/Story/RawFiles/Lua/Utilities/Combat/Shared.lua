
---@class CombatLib : Library
Combat = {}
Epip.InitializeLibrary("Combat", Combat)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias CombatLib_CombatCompatibleEntity Character|Item

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

---Returns the current active combatant in a combat.
---@return CombatLib_CombatCompatibleEntity
function Combat.GetActiveCombatant(combatID)
    local combat = Combat.GetCombat(combatID)
    if not combat then
        Combat:Error("GetActiveCombatant", "Combat not found with ID", combatID)
    end
    local currentTeam, combatant

    if Ext.IsClient() then
        combatant = Combat.GetTurnOrder(combatID).CurrentRound.Participants[1]
    else
        currentTeam = combat:GetCurrentTurnOrder()[1]
        combatant = currentTeam.Character or currentTeam.Item
    end

    return combatant
end

---Returns the combat component of an entity.
---@param entity CombatLib_CombatCompatibleEntity
---@return EocCombatComponent? -- `nil` if the entity does not have the component.
function Combat.GetCombatComponent(entity)
    local componentHandle = entity.Base.Entity:GetComponent("Combat")

    return Ext.Entity.GetCombatComponent(componentHandle)
end

---Returns the combat ID of an entity.
---@param entity CombatLib_CombatCompatibleEntity
---@return integer? -- `nil` if the entity is not in combat.
function Combat.GetCombatID(entity)
    local component = Combat.GetCombatComponent(entity)
    local combatID = nil

    if component then
        combatID = component.CombatAndTeamIndex.CombatId
    end

    -- 0 indicates no combat.
    if combatID == 0 then
        combatID = nil
    end

    return combatID
end

---Returns all the entities in a combat.
---@param combat EclTurnManagerCombat|EsvTurnManagerCombat
---@return CombatLib_CombatCompatibleEntity[]
function Combat.GetParticipants(combat)
    local entities = {} ---@type CombatLib_CombatCompatibleEntity[]
    if Ext.IsClient() then
        ---@cast combat EclTurnManagerCombat
        local teams = combat.Teams
        for _,handle in pairs(teams) do
            table.insert(entities, Combat.GetEntityByCombinedID(Ext.Entity.GetCombatComponent(handle.Handle).CombatAndTeamIndex))
        end
    else
        Combat:__ThrowNotImplemented("GetParticipants") -- TODO
    end
    return entities
end

---Returns an entity by its combat and team ID.
---@param id EocCombatTeamId|integer
---@return CombatLib_CombatCompatibleEntity?
function Combat.GetEntityByCombinedID(id)
    local combatID, teamID
    if type(id) == "number" then -- Number overload (ex. for IDs extracted from UIs)
        combatID, teamID = id >> 24, id & 16777215 -- Higher 8 bits is combat ID, lower 24 bits is team ID
    else
        combatID, teamID = id.CombatId, id.TeamId
    end
    local combat = Combat.GetCombat(combatID)
    for _,team in pairs(combat.Teams) do
        local combatComp = Ext.Entity.GetCombatComponent(team.Handle)
        if combatComp.CombatAndTeamIndex.TeamId == teamID then
            return Entity.GetGameObjectComponent(combatComp.Entity)
        end
    end
    return nil
end
