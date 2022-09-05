
---@class EntityLib
local Entity = Entity

---------------------------------------------
-- METHODS
---------------------------------------------

---@param handle EntityHandle
---@param isFlashHandle boolean? Defaults to false.
---@return Entity?
function Entity.Get(handle, isFlashHandle)
    if isFlashHandle then
        handle = Ext.UI.DoubleToHandle(handle)
    end

    return Entity._Get(handle)
end