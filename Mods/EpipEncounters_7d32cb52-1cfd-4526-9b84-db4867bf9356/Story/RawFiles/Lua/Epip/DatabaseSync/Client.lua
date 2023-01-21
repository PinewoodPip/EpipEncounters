
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")

---@class Feature_DatabaseSync
local DBSync = Epip.GetFeature("Feature_DatabaseSync")
DBSync._Entries = DefaultTable.Create({}) ---@type table<string, table<integer, Feature_DatabaseSync_Entry>> Maps database name to table<arity, Feature_DatabaseSync_Entry>

---------------------------------------------
-- CLASSES
---------------------------------------------

---Represents a tuple within a database.
---@class Feature_DatabaseSync_Entry_Tuple
local _Tuple = {
    Values = {}, ---@type any[]
    DatabaseDefinition = nil, ---@type Feature_DatabaseSync_DatabaseDefinition
}
DBSync._Tuple = _Tuple

function _Tuple.__index(self, key)
    return _Tuple.ToTable(self)[key]
end

---Creates a tuple.
---@param tuple any[]
---@param def Feature_DatabaseSync_DatabaseDefinition
---@return Feature_DatabaseSync_Entry_Tuple
function _Tuple.Create(tuple, def)
    ---@type Feature_DatabaseSync_Entry_Tuple
    local obj = {
        Values = tuple,
        DatabaseDefinition = def,
    }
    Inherit(obj, _Tuple)

    return obj
end

---@return table
function _Tuple:ToTable()
    local fieldNames = self.DatabaseDefinition.FieldNames
    local tbl = {}

    for i,fieldName in ipairs(fieldNames) do
        tbl[fieldName] = self.Values[i]
    end

    return tbl
end

---Represents the tuples stored within a database.
---@class Feature_DatabaseSync_Entry
local _Entry = {
    Tuples = {}, ---@type Feature_DatabaseSync_Entry_Tuple[]
}
DBSync._Entry = _Entry

---@param tuples Feature_DatabaseSync_Entry_Tuple[]
---@return Feature_DatabaseSync_Entry
function _Entry.Create(tuples)
    local obj = {
        Tuples = tuples,
    }
    Inherit(obj, _Entry)

    return obj
end

---@param ... any|nil
---@return Feature_DatabaseSync_Entry_Tuple[]
function _Entry:Query(...)
    local validTuples = {}
    local query = table.pack(...)

    for _,tuple in ipairs(self.Tuples) do
        local isValid = true

        for i,element in ipairs(tuple.Values) do
            local queriedValue = query[i]
            if GetExtType(queriedValue) ~= nil then -- Convert userdata to GUID for comparisons
                queriedValue = queriedValue.MyGuid
            end

            element = string.match(element, Text.PATTERNS.GUID) or element

            if queriedValue ~= nil and element ~= queriedValue then
                isValid = false
                break
            end
        end

        if isValid then
            table.insert(validTuples, tuple)
        end
    end

    return validTuples
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Queries a synched database.
---@generic T
---@param dbName `T`|OsirisLib_DatabaseName
---@param ... any Query parameters.
---@return (Feature_DatabaseSync_Entry_Tuple|`T`)[]
function DBSync.Query(dbName, ...)
    local arity = select("#", ...)
    local db = DBSync._Entries[dbName][arity]

    if not DBSync._Definitions[dbName][arity] then
        DBSync:Error("Query", dbName, "with arity", arity, "is not registered for synching.")
    end

    return db and db:Query(...) or {}
end

---Queries a synched database and returns only the first matched tuple.
---@generic T
---@param dbName `T`|OsirisLib_DatabaseName
---@param ... any Query parameters.
---@return Feature_DatabaseSync_Entry_Tuple|`T`
function DBSync.QueryFirst(dbName, ...)
    return DBSync.Query(dbName, ...)[1]
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for databases being synched.
Net.RegisterListener("Feature_DatabaseSync_NetMessage_SyncDatabase", function (payload)
    local name, arity = payload.DatabaseName, payload.Arity
    local tuples = {}
    
    for i,t in ipairs(payload.Tuples) do
        local def = DBSync._Definitions[name][arity]

        if not def then
            DBSync:Error("Feature_DatabaseSync_NetMessage_SyncDatabase", "Attemped to sync database that is not registered on the client", name, arity)
        end

        tuples[i] = DBSync._Tuple.Create(t, def)
    end

    DBSync._Entries[name][arity] = DBSync._Entry.Create(tuples)
end)