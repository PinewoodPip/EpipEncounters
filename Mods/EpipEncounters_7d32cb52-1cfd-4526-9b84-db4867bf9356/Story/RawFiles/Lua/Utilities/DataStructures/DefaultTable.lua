
---@class DataStructures_DefaultTable
local DefaultTable = {
    _DefaultValue = {}, ---@type any
    _DeepCopyTables = true,
}
DataStructures.Register("DataStructures_DefaultTable", DefaultTable)

---@class DataStructures_DefaultTable<K, V>:{[K]: V}

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

function DefaultTable.__pairs(self)
    local generator = function(tbl, k)
        local v

        k, v = next(tbl, k)

        -- Ignore internal variables
        while DefaultTable[k] ~= nil do
            k, v = next(tbl, k)
        end

        return k, v
    end

    return generator, self, nil
end