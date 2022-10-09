
---@class EntityLib
Entity = {}

---------------------------------------------
-- CLASSES
---------------------------------------------

---Return types of GetGameObject().
---@alias EntityLib_GetGameObjectFuntionReturnType "esv::Character"|"ecl::Character"|"ecl::Inventory"|"ecl::Scenery"|"ecl::Item"|"esv::Item"|"Trigger"|"esv::Projectile"|"ecl::Projectile"|"ecl::CombatComponent"

---@alias EntityLib_EntityComponent string|EclCharacter|EsvCharacter|EclItem|EsvItem|EclScenery|EclProjectile|EclCombatComponent|EsvProjectile

---------------------------------------------
-- METHODS
---------------------------------------------

---@return EclLevel|EsvLevel
function Entity.GetLevel()
    return Ext.Entity.GetCurrentLevel()
end

---Returns a list of items registered on the current level.
---@return EclItem[]|EsvItem[] -- Read-only.
function Entity.GetRegisteredItems()
    local level = Entity.GetLevel()
    local items

    if level then
        local levelID = level.LevelDesc.UniqueKey
        
        items = level.EntityManager.ItemConversionHelpers.RegisteredItems[levelID]
    else
        Entity:LogWarning("GetRegisteredItems(): level unavailable")
    end

    return items
end

---@param entity BaseComponent|ComponentHandle
---@return IGameObject
function Entity.GetEntity(entity)
    if Ext.Utils.IsValidHandle(entity) then
        entity = Entity.GetComponent(entity)
    end

    return entity.Base.Entity
end

---Returns a list of characters registered on the current level.
---@return EclCharacter[]|EsvCharacter[] Read-only.
function Entity.GetRegisteredCharacters()
    local level = Entity.GetLevel()
    local characters

    if level then
        local levelID = level.LevelDesc.UniqueKey
        
        characters = level.EntityManager.CharacterConversionHelpers.RegisteredCharacters[levelID]
    else
        Entity:LogWarning("GetRegisteredCharacters(): level unavailable")
    end

    return characters
end

---Returns a component from a base entity.
---@generic T
---@param entity Entity|EntityHandle
---@param component `T`|EntityLib_EntityComponent
---@return T
function Entity.GetComponent(entity, component)
    if Ext.Utils.IsValidHandle(entity) then
        entity = Entity.GetEntity(entity).Base.Entity
    end

    return entity:GetComponent(component)
end

---Returns the main game object component of an entity.
---This will be either a character or item component, if either are on the entity.
---@param entity Entity|EntityHandle
function Entity.GetGameObjectComponent(entity)
    if Ext.Utils.IsValidHandle(entity) then
        entity = Entity.GetEntity(entity)
    end
    local component

    if entity:HasComponent("Character") then
        component = Entity.GetComponent(entity, "Character")
    elseif entity:HasComponent("Item") then
        component = Entity.GetComponent(entity, "Item")
    end

    return component
end

---@param handle ComponentHandle|GUID
---@return BaseComponent?
function Entity._GetComponent(handle)
    local entity

    if type(handle) ~= "userdata" or Ext.Utils.IsValidHandle(handle) then
        entity = Ext.Entity.GetGameObject(handle)
    end

    return entity
end

---Returns the values of the first parametrized tag by pattern.
---@param gameObject IGameObject
---@param pattern pattern
---@return string ...
function Entity.GetParameterTagValue(gameObject, pattern)
    for _,tag in ipairs(gameObject:GetTags()) do
        local params = {tag:match(pattern)}

        if #params > 0 then
            return table.unpack(params)
        end
    end
end