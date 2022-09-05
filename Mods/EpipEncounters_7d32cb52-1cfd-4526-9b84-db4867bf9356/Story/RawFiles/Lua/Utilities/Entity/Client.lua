
---@class EntityLib : Library
local Entity = Entity
Epip.InitializeLibrary("Entity", Entity)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns an entity by its handle.
---See the `EntityLib_GetGameObjectFuntionReturnType` alias for possible return types.
---@param handle EntityHandle
---@param isFlashHandle boolean? Defaults to false.
---@return Entity?
function Entity.Get(handle, isFlashHandle)
    if isFlashHandle then
        handle = Ext.UI.DoubleToHandle(handle)
    end

    return Entity._Get(handle)
end