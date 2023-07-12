
---------------------------------------------
-- A data structure for object pooling.
---------------------------------------------

---@class ObjectPool<T> : Class, { (Create:fun(objType:`T`):ObjectPool<T>), (Get:fun(self):T?), (Dispose:fun(self, obj:T)) }
---@field _Objects table<any, boolean> Value is `true` if the object is available.
local ObjectPool = {}
OOP.RegisterClass("ObjectPool", ObjectPool)
DataStructures.Register("ObjectPool", ObjectPool)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias DataStructures_DataStructureClassName "ObjectPool"

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an object pool.
---@generic T
---@param objType `T`? For type capture only.
---@return ObjectPool<T>
---@diagnostic disable-next-line: unused-local
function ObjectPool.Create(objType)
    local instance = ObjectPool:__Create() ---@cast instance ObjectPool
    instance._Objects = {}

    return instance
end

---Returns an available object from the pool (if there are any)
---and marks it as unavailable.
---@generic T
---@return T?
function ObjectPool:Get()
    local object, _ = table.getFirst(self._Objects, function (_, v)
        return v
    end)

    if object then
        self._Objects[object] = false
    end

    return object
end

---Disposes of an object, adding or returning it to the pool of available ones.
---@generic T
---@param obj T
function ObjectPool:Dispose(obj)
    self._Objects[obj] = true
end