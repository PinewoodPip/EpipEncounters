
---@class EntityLib
Entity = {}

---------------------------------------------
-- CLASSES
---------------------------------------------

---Return types of GetGameObject().
---@alias EntityLib_GetGameObjectFuntionReturnType "esv::Character"|"ecl::Character"|"ecl::Inventory"|"ecl::Scenery"|"ecl::Item"|"esv::Item"|"Trigger"|"esv::Projectile"|"ecl::Projectile"|"ecl::CombatComponent"

---@alias EntityLib_EntityComponent EclCharacter|EsvCharacter|EclItem|EsvItem|EclScenery|EclProjectile|EclCombatComponent|EsvProjectile

---------------------------------------------
-- METHODS
---------------------------------------------

---@return EclLevel|EsvLevel
function Entity.GetLevel()
    return Ext.Entity.GetCurrentLevel()
end

---Returns the unique identifier of the level.
---For GM maps, this will not be the editor ID of the map, since
---it's possible to have multiple of the same map in a campaign.
---@param level (EclLevel|EsvLevel)? Defaults to current level.
---@return string
function Entity.GetLevelID(level)
    level = level or Entity.GetLevel()

    return level.LevelDesc.UniqueKey
end

---@param component EntityLib_EntityComponent
function Entity.IsCharacter(component)
    local className = GetExtType(component)

    return className and className == "ecl::Character" or className == "esv::Character"
end

---@param component EntityLib_EntityComponent
function Entity.IsItem(component)
    local className = GetExtType(component)

    return className and className == "ecl::Item" or className == "esv::Item"
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
        component = Entity.GetComponent(entity:GetComponent("Character"))
    elseif entity:HasComponent("Item") then
        component = Entity.GetComponent(entity:GetComponent("Item"))
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

---Returns the characters near a position.
---@param pos vec3
---@param radius number Radial.
---@param predicate (fun(char:Character):boolean)? Should return `true` for a character to be included.
---@return Character[]
function Entity.GetNearbyCharacters(pos, radius, predicate)
    local allChars = Entity.GetRegisteredCharacters()
    local radiusSquared = radius ^ 2
    local nearChars = {} ---@type Item[]
    for _,char in ipairs(allChars) do
        local charPos = char.WorldPos
        local dist = (charPos[1] - pos[1]) ^ 2 + (charPos[2] - pos[2]) ^ 2 + (charPos[3] - pos[3]) ^ 2 -- VectorLib and sqrt are avoided to maximize performance.
        if dist <= radiusSquared and (predicate == nil or predicate(char)) then
            table.insert(nearChars, char)
        end
    end
    return nearChars
end

---Returns the items near a position.
---@param pos vec3
---@param radius number Radial.
---@param predicate (fun(item:Item):boolean)? Should return `true` for an item to be included.
---@return Item[]
function Entity.GetNearbyItems(pos, radius, predicate)
    local allItems = Entity.GetRegisteredItems()
    local radiusSquared = radius ^ 2
    local nearItems = {} ---@type Item[]
    for _,item in ipairs(allItems) do
        local itemPos = item.WorldPos
        local dist = (itemPos[1] - pos[1]) ^ 2 + (itemPos[2] - pos[2]) ^ 2 + (itemPos[3] - pos[3]) ^ 2 -- VectorLib and sqrt are avoided to maximize performance.
        if dist <= radiusSquared and (predicate == nil or predicate(item)) then
            table.insert(nearItems, item)
        end
    end
    return nearItems
end

---Converts a list of entities to a list of their net IDs.
---@param list (IEoCClientReplicatedObject|IEoCServerObject)[]
---@return NetId[]
function Entity.EntityListToNetIDs(list)
    local netIDs = {}
    for i,entity in ipairs(list) do
        netIDs[i] = entity.NetID
    end
    return netIDs
end

---Converts a list of entities to a list of their net IDs.
---@param list (IEoCClientReplicatedObject|IEoCServerObject)[]
---@return ComponentHandle[]
function Entity.EntityListToHandles(list)
    local handles = {}
    for i,entity in ipairs(list) do
        handles[i] = entity.Handle
    end
    return handles
end

---Converts a list of net IDs to a list of their game objects.
---@generic T
---@param list NetId[]
---@param expectedType `T`|"EsvItem"|"EclItem"|"EsvCharacter"|"EclCharacter"
---@return T[]
---@diagnostic disable-next-line: unused-local
function Entity.NetIDListToEntities(list, expectedType)
    local entities = {}
    -- Entity.GetGameObject() does not accept net IDs.
    -- TODO expand this to support more types
    local getter = string.find(expectedType, "Character") and Character.Get or Item.Get
    for i,netID in ipairs(list) do
        entities[i] = getter(netID)
    end
    return entities
end

---Converts a list of handles to a list of their game objects.
---@generic T
---@param list ComponentHandle[]
---@param expectedType `T`|"EsvItem"|"EclItem"|"EsvCharacter"|"EclCharacter" For IDE purposes only.
---@return T[]
---@diagnostic disable-next-line: unused-local
function Entity.HandleListToEntities(list, expectedType)
    local entities = {}
    for i,handle in ipairs(list) do
        entities[i] = Ext.Entity.GetGameObject(handle)
    end
    return entities
end
