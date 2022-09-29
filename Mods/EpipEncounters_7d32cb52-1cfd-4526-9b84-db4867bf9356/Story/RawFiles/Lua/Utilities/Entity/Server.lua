
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
    return Entity._Get(handle)
end