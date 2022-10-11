
---@class EntityLib : Library
local Entity = Entity
Epip.InitializeLibrary("Entity", Entity)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns an entity component by its handle.
---See the `EntityLib_GetGameObjectFuntionReturnType` alias for possible return types.
---@deprecated A mess. TODO fix.
---@generic T
---@param handle ComponentHandle
---@param isFlashHandle boolean? Defaults to false.
---@param component `T`|EntityLib_EntityComponent
---@return BaseComponent?
function Entity.GetComponent(handle, component, isFlashHandle)
    if isFlashHandle then
        handle = Ext.UI.DoubleToHandle(handle)
    end

    return Entity._GetComponent(handle)
end