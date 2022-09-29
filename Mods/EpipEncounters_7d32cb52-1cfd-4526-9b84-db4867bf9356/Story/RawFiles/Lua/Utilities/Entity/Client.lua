
---@class EntityLib : Library
local Entity = Entity
Epip.InitializeLibrary("Entity", Entity)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns an entity component by its handle.
---See the `EntityLib_GetGameObjectFuntionReturnType` alias for possible return types.
---@param handle ComponentHandle
---@param isFlashHandle boolean? Defaults to false.
---@return BaseComponent?
function Entity.GetComponent(handle, isFlashHandle)
    if isFlashHandle then
        handle = Ext.UI.DoubleToHandle(handle)
    end

    return Entity._GetComponent(handle)
end