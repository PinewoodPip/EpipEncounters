
---@class EntityLib
Entity = {}

---------------------------------------------
-- METHODS
---------------------------------------------

---@param handle EntityHandle|GUID
---@return Entity?
function Entity._Get(handle)
    local entity

    if type(handle) ~= "userdata" or Ext.Utils.IsValidHandle(handle) then
        entity = Ext.Entity.GetGameObject(handle)
    end

    return entity
end