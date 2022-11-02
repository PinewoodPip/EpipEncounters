
---@class DataStructures
DataStructures = {
    _Structures = {},
}

---------------------------------------------
-- METHODS
---------------------------------------------

---@param className string
---@param tbl table
function DataStructures.Register(className, tbl)
    DataStructures._Structures[className] = tbl
end

---@generic T
---@param className `T`
---@return T
function DataStructures.Get(className)
    return DataStructures._Structures[className]
end