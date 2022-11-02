
---@class DataStructures_DefaultTable
local DefaultTable = {
    _DefaultValue = nil, ---@type any
    _DeepCopyTables = true,
}
DataStructures.Register("DataStructures_DefaultTable", DefaultTable)

---@class DataStructures_DefaultTable<K, V>:{[K]: V, Create:fun(defaultValue:V):DataStructures_DefaultTable<K,V>}

---------------------------------------------
-- METHODS
---------------------------------------------

---@param defaultValue any
---@param deepCopy boolean? Defaults to true.
---@return DataStructures_DefaultTable
function DefaultTable.Create(defaultValue, deepCopy)
    if deepCopy == nil then deepCopy = true end
    ---@type DataStructures_DefaultTable
    local tbl = {
        _DefaultValue = defaultValue,
        _DeepCopyTables = deepCopy,
    } 

    setmetatable(tbl, DefaultTable)

    return tbl
end

function DefaultTable.__index(self, key)
    local defaultValue = self._DefaultValue
    if type(defaultValue) == "table" and self._DeepCopyTables then -- Tables are deep-copied.
        defaultValue = table.deepCopy(defaultValue)
    end

    self[key] = defaultValue

    return defaultValue
end