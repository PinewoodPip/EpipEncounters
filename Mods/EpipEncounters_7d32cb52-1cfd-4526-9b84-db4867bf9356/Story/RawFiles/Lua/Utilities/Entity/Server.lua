
---@class EntityLib
local Entity = Entity

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns an entity by its handle.
---See the `EntityLib_GetGameObjectFuntionReturnType` alias for possible return types.
---@param handle EntityHandle
---@return Entity?
function Entity.Get(handle)
    return Entity._Get(handle)
end