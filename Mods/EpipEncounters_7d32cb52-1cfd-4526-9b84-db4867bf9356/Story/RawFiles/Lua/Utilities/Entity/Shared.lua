
---@class EntityLib
Entity = {}

---------------------------------------------
-- CLASSES
---------------------------------------------

---Return types of GetGameObject().
---@alias EntityLib_GetGameObjectFuntionReturnType "esv::Character"|"ecl::Character"|"ecl::Inventory"|"ecl::Scenery"|"ecl::Item"|"esv::Item"|"Trigger"|"esv::Projectile"|"ecl::Projectile"

---------------------------------------------
-- METHODS
---------------------------------------------

---@return EclLevel|EsvLevel
function Entity.GetLevel()
    return Ext.Entity.GetCurrentLevel()
end

---Returns a list of items registered on the current level.
---@return EclItem[]|EsvItem[] Read-only.
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

---@param handle EntityHandle|GUID
---@return Entity?
function Entity._Get(handle)
    local entity

    if type(handle) ~= "userdata" or Ext.Utils.IsValidHandle(handle) then
        entity = Ext.Entity.GetGameObject(handle)
    end

    return entity
end