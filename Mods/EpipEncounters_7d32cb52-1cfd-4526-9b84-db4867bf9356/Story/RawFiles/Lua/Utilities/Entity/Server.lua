
---@class EntityLib
local Entity = Entity

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns an entity component by its handle.
---See the `EntityLib_GetGameObjectFuntionReturnType` alias for possible return types.
---@param handle ComponentHandle
---@return BaseComponent?
function Entity.GetComponent(handle)
    return Entity._GetComponent(handle)
end

---Removes all tags from a game object that match a pattern.
---@param gameObject IGameObject
---@param pattern pattern
function Entity.RemoveTagsByPattern(gameObject, pattern)
    for _,tag in ipairs(gameObject:GetTags()) do
        if tag:match(pattern) then
            Osiris.ClearTag(gameObject, tag)
        end
    end
end