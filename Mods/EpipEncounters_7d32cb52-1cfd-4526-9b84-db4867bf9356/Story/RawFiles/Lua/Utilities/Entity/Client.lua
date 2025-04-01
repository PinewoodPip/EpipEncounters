
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
---@param component `T`|EntityLib_EntityComponent For IDE purposes only.
---@return BaseComponent?
---@diagnostic disable-next-line: unused-local
function Entity.GetComponent(handle, component, isFlashHandle)
    if isFlashHandle then
        handle = Ext.UI.DoubleToHandle(handle)
    end

    return Entity._GetComponent(handle)
end

---Sets the highlight for an entity.
---**Does nothing if the extender fork is not installed.**
---@param entity EclCharacter|EsvCharacter|ComponentHandle
---@param highlight EntityLib.HighlightType
---@param playerID integer? Defaults to `1`.
---@param unknownBool boolean? Defaults to `false`.
function Entity.SetHighlight(entity, highlight, playerID, unknownBool)
    if Ext.Entity.SetHighlight == nil then return end -- This function used to be fork-exclusive
    local entityHandle = GetExtType(entity) ~= nil and entity.Handle or entity -- Handle overload.
    Ext.Entity.SetHighlight(playerID or 1, entityHandle, highlight, unknownBool or false)
end
