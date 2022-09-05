
---@class EntityLib
local Entity = Entity

---------------------------------------------
-- METHODS
---------------------------------------------

---@param handle EntityHandle
---@return Entity?
function Entity.Get(handle)
    return Entity._Get(handle)
end