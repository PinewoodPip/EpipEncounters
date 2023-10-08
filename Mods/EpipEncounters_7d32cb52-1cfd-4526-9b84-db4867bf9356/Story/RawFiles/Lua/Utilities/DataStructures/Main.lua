
---@class DataStructures
DataStructures = {
    _Structures = {},
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias DataStructures_DataStructureClassName "DataStructures_DefaultTable"|"DataStructures_Set"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param className string
---@param tbl table
function DataStructures.Register(className, tbl)
    DataStructures._Structures[className] = tbl
end

---@generic T
---@param className `T`|DataStructures_DataStructureClassName
---@return T
function DataStructures.Get(className)
    return DataStructures._Structures[className]
end