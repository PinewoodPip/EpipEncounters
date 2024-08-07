
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")

---@class OsirisLib : Library, {[string]: function|OsiDatabase|OsirisLib.LegacyDatabase}, Osi
Osiris = {
    _Databases = DefaultTable.Create({}), ---@type table<string, table<integer, OsirisLib_Database>>
    _UserQueries = DefaultTable.Create({}), ---@type table<string, table<integer, OsirisLib_UserQuery>>
}
Epip.InitializeLibrary("Osiris", Osiris)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias OsirisType "INTEGER"|"INTEGER64"|"REAL"|"STRING"|"REAL"|"GUIDSTRING"|"CHARACTERGUID"|"ITEMGUID"|"TRIGGERGUID"|"SPLINEGUID"|"LEVELTEMPLATEGUID"
---@alias OsirisLib_OsirisCompatibleLuaType string|number|boolean
---@alias OsirisLib_CompatibleType OsirisLib_OsirisCompatibleLuaType|EsvCharacter|EsvItem

---@class OsirisLib.LegacyDatabase : OsiDatabase
---@field Set fun(...)

---@class OsirisLib_Tuple : Class, {[string]:OsirisLib_OsirisCompatibleLuaType, [integer]:OsirisLib_OsirisCompatibleLuaType}
---@field Values OsirisLib_OsirisCompatibleLuaType[]
---@field DatabaseDescriptor OsirisLib_Database
local Tuple = {}
OOP.RegisterClass("OsirisLib_Tuple", Tuple)

---Creates a tuple.
---@param database OsirisLib_Database
---@param values OsirisLib_OsirisCompatibleLuaType[]
---@return OsirisLib_Tuple
function Tuple.Create(database, values)
    ---@type OsirisLib_Tuple
    local instance = Tuple:__Create({
        Values = values,
        DatabaseDescriptor = database,
    })

    -- Allow indexing via index (assumes immutability)
    for i,value in ipairs(values) do
        instance[i] = value
    end

    return instance
end

-- Allow accessing values by their field names, if registered
function Tuple.__index(self, key)
    if type(key) == "string" then -- Only do this for string indexing. Integer indexing is setup within constructor (assumes immutability).
        local index = self.DatabaseDescriptor:GetFieldIndex(key)
        return self.Values[index]
    end
end

---Returns whether a query matches this tuple's values.
---@param ... OsirisLib_OsirisCompatibleLuaType
---@return boolean
function Tuple:MatchesQuery(...)
    local query = table.pack(...)
    local matches = true

    if query.n == #self.Values then
        for i,v in ipairs(self.Values) do
            local queriedValue = query[i]
            queriedValue = string.match(queriedValue, Text.PATTERNS.GUID) or queriedValue -- Remove GUID prefixes

            if GetExtType(queriedValue) ~= nil then -- Convert userdata to GUID for comparisons
                queriedValue = queriedValue.MyGuid
            end

            -- Remove GUID prefixes
            v = string.match(v, Text.PATTERNS.GUID) or v

            if queriedValue ~= nil and v ~= queriedValue then
                matches = false
                break
            end
        end
    else
        matches = false
    end

    return matches
end

---Unpacks the tuple's values.
---@return ... OsirisLib_OsirisCompatibleLuaType
function Tuple:Unpack()
    return table.unpack(self.Values)
end

---@class OsirisLib_Database : Class
---@field Name string
---@field Arity integer
---@field Fields {Name:string, Type:OsirisType}[]? Names and types for each element within the database's tuples. Only present if the DB was registered via `RegisterDatabase()`.
local DB = {}
OOP.RegisterClass("OsirisLib_Database", DB)

---Creates a DB descriptor.
---@param data OsirisLib_Database
---@return OsirisLib_Database
function DB.Create(data)
    DB:__Create(data)

    return data
end

---Queries a DB.
---@param ... OsirisLib_OsirisCompatibleLuaType
---@return (OsirisLib_Tuple|`T`)[]
function DB:Query(...)
    local tuples = {}
    local queryParams = table.pack(Osiris._ParseParameters(...))
    local osiQuery = Osi[self.Name]:Get(table.unpack(queryParams, 1, queryParams.n)) or {}

    for _,returnedTuple in ipairs(osiQuery) do
        local tuple = Tuple.Create(self, returnedTuple)

        table.insert(tuples, tuple)
    end

    return tuples
end

---Writes a fact to the DB.
---@param ... OsirisLib_CompatibleType
function DB:Set(...)
    local params = table.pack(Osiris._ParseParameters(...))
    Osi[self.Name](table.unpackSelect(params))
end

---Deletes a fact from the DB.
---@param ... OsirisLib_CompatibleType
function DB:Delete(...)
    local params = table.pack(Osiris._ParseParameters(...))
    Osi[self.Name]:Delete(table.unpackSelect(params))
end

---Returns the index of a field by its name.
---@param fieldName string
---@return integer --Will throw error if field names are not registered for the DB.
function DB:GetFieldIndex(fieldName)
    local fields = self.Fields
    local index

    if not fields then
        Osiris:Error("Database:GetFieldIndex", "Field names are not registered for DB ", self.Name, self.Arity)
    end

    -- TODO optimize
    for i,field in ipairs(fields) do
        if field.Name == fieldName then
            index = i
            break
        end
    end

    return index
end

---@class OsirisLib_UserQuery : Class
---@field Name string
---@field ParamCount integer TODO also document types?
---@field OutputDatabases {Name:string, Arity:integer}[]
local UserQuery = {}
OOP.RegisterClass("OsirisLib_UserQuery", UserQuery)

---Creates a user query descriptor.
---@param data OsirisLib_UserQuery
---@return OsirisLib_UserQuery
function UserQuery.Create(data)
    local instance = UserQuery:__Create(data) ---@cast instance OsirisLib_UserQuery

    return instance
end

---Performs a query.
---@param ... OsirisLib_OsirisCompatibleLuaType
---@return ... OsirisLib_OsirisCompatibleLuaType
function UserQuery:Query(...)
    local output = {}

    -- Call the query
    Osi[self.Name](Osiris._ParseParameters(...))

    -- Collect return values from all output DBs
    for _,db in ipairs(self.OutputDatabases) do
        local descriptor = Osiris.GetDatabase(db.Name, db.Arity)
        local dbOutput = descriptor:Query(table.unpackSelect({}, db.Arity)) -- Query with all wildcards.

        -- Collect return values from all tuples (there may be more than one)
        for _,tuple in ipairs(dbOutput) do
            for _,value in ipairs(tuple.Values) do
                table.insert(output, value)
            end
        end
    end

    return table.unpack(output)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a database.
---@param data OsirisLib_Database
---@return OsirisLib_Database
function Osiris.RegisterDatabase(data)
    local instance = DB.Create(data)

    Osiris._Databases[data.Name][data.Arity] = instance

    return instance
end

---Returns the descriptor of a database.
---@param name string|OsirisLib_DatabaseName
---@param arity integer
---@return OsirisLib_Database
function Osiris.GetDatabase(name, arity)
    local db = Osiris._Databases[name][arity]
    if not db then
        ---@type OsirisLib_Database
        local newEntry = {
            Name = name,
            Arity = arity
        }
        db = Osiris.RegisterDatabase(newEntry)
    end

    return db
end

---Registers a user query.
---@param data OsirisLib_UserQuery
function Osiris.RegisterUserQuery(data)
    local instance = UserQuery.Create(data)

    Osiris._UserQueries[instance.Name][instance.ParamCount] = instance
end

---Returns the descriptor for a user query.
---@param name string
---@param paramCount integer
---@return OsirisLib_UserQuery
function Osiris.GetUserQuery(name, paramCount)
    return Osiris._UserQueries[name][paramCount]
end

---Queries a database.
---@generic T
---@param name string|OsirisLib_DatabaseName|`T`
---@param ... OsirisLib_CompatibleType
---@return OsirisLib_Tuple[] --TODO generic support
function Osiris.QueryDatabase(name, ...)
    local paramCount = select("#", ...)
    local db = Osiris.GetDatabase(name, paramCount)

    return db:Query(...)
end

---Writes a fact to a database.
---@param name string
---@param ... OsirisLib_CompatibleType
function Osiris.Set(name, ...)
    Osiris.GetDatabase(name, select("#", ...)):Set(...)
end

---Deletes a fact from a database.
---@param name string
---@param ... OsirisLib_CompatibleType
function Osiris.Delete(name, ...)
    Osiris.GetDatabase(name, select("#", ...)):Delete(...)
end

---Returns the first fact in a database that matches the query.
---@see Osiris.GetFirstFactOrEmpty
---@generic T
---@param dbName string|OsirisLib_DatabaseName|`T`
---@param ... OsirisLib_CompatibleType
---@return OsirisLib_Tuple
function Osiris.GetFirstFact(dbName, ...)
    local paramCount = select("#", ...)
    local db = Osiris.GetDatabase(dbName, paramCount)

    return db:Query(...)[1]
end

---Returns the first fact in a database that matches the query.
---If no facts exist, returns a dummy tuple with no values.
---Useful for cleaner nil checks.
---@see Osiris.GetFirstFact
---@generic T
---@param dbName string|OsirisLib_DatabaseName|`T`
---@param ... OsirisLib_CompatibleType
---@return OsirisLib_Tuple
function Osiris.GetFirstFactOrEmpty(dbName, ...)
    local tuples = Osiris.GetFirstFact(dbName, ...) or Tuple.Create(Osiris.GetDatabase(dbName, select("#", ...)), {})
    return tuples
end

---@class OsirisDatabase
---@field Name string
local _OsirisDatabase = {
    Name = "",
}

---Table for built-in osi symbols.
---@class Osiris_BuiltInSymbol
local _BuiltInOsiSymbol = {Name = ""}
function _BuiltInOsiSymbol:__call(...)
    return Osi[self.Name](Osiris._ParseParameters(...))
end

-- Calling the table itself does a query (backwards compatibility)
function _OsirisDatabase:__call(...)
    Osiris:LogWarning("Calling the table to interface with DBs is deprecated! " .. self.Name)
    local paramCount = table.pack(...).n
    local queryResult = Osiris.GetDatabase(self.Name, paramCount):Query(...)
    local first = queryResult[1]

    if first then
        local returnValues = table.pack(first:Unpack())
        table.insert(returnValues, queryResult)
        return table.unpack(returnValues)
    else
        return nil
    end
end

---Query a database. The first tuple will be unpacked;
---afterwards, a list is returned as well.
---@vararg any Query parameters.
function _OsirisDatabase:Get(...)
    Osiris:LogWarning("Calling the table to interface with DBs is deprecated! " .. self.Name)
    local paramCount = table.pack(...).n
    local queryResult = Osiris.GetDatabase(self.Name, paramCount):Query(...)
    local first = queryResult[1]

    if first then
        local returnValues = table.pack(first:Unpack())
        table.insert(returnValues, queryResult)
        return table.unpack(returnValues)
    else
        return nil
    end
end

---Returns a list of tuples matching the query.
---@return table<integer, any>[]
function _OsirisDatabase:GetTuples(...)
    Osiris:LogWarning("Calling the table to interface with DBs is deprecated! " .. self.Name)
    local paramCount = table.pack(...).n
    local queryResult = Osiris.GetDatabase(self.Name, paramCount):Query(...)

    return queryResult
end

---Delete tuples from the DB.
---@vararg any Tuple query to delete.
function _OsirisDatabase:Delete(...)
    Osiris:LogWarning("Calling the table to interface with DBs is deprecated! " .. self.Name)
    Osi[self.Name]:Delete(Osiris._ParseParameters(...))
end

---Set a tuple on the DB.
---@vararg any Tuple values
function _OsirisDatabase:Set(...)
    Osiris:LogWarning("Calling the table to interface with DBs is deprecated! " .. self.Name)
    Osi[self.Name](Osiris._ParseParameters(...))
end

---Converts parameters to Osiris-compatible types.
---@param ... any
---@return ... OsirisLib_OsirisCompatibleLuaType
function Osiris._ParseParameters(...)
    local params = table.pack(...)
    local length = select("#", ...)

    for i=1,length,1 do
        local v = params[i]
        local convertedParam = v

        -- Convert parameter types.
        if GetExtType(v) then -- Convert entity references to their GUIDs.
            convertedParam = v.MyGuid -- TODO support prefixed GUIDs as well
        elseif type(v) == "boolean" then -- Convert booleans to 0/1. TODO remove once this is fixed in the extender.
            if v then
                convertedParam = 1
            else
                convertedParam = 0
            end
        end

        params[i] = convertedParam
    end

    return table.unpackSelect(params, length)
end

function Osiris.RegisterSymbolListener(symbol, arity, timing, handler)
    Ext.Osiris.RegisterListener(symbol, arity, timing, handler)
end

---------------------------------------------
-- CALL WRAPPER
---------------------------------------------

local function meta_osiindex(_, key)
    if not table.isempty(Osiris._UserQueries[key]) then -- User Query
        return function(...)
            return Osiris.UserQuery(key, ...)
        end
    elseif key:match("^DB_") then -- DB query
        local tb = {Name = key}
        setmetatable(tb, {__index = _OsirisDatabase, __call = _OsirisDatabase.__call})
        return tb
    else -- Default to built-in symbol
        local symbol = {Name = key}
        setmetatable(symbol, _BuiltInOsiSymbol)

        return OOP.GetClass("Library")[key] or symbol 
    end
end
setmetatable(Osiris, { -- Access is query by default
    __index = meta_osiindex
})

---Query a database.
---@deprecated
---@param name string
---@param unpack boolean If true, the first tuple found will be unpacked. The last value returned (arity + 1) will be the list of all tuples.
---@vararg any Query parameters.
---@return any Unpacked values or list of tuples, based on unpack parameter.
function Osiris.DatabaseQuery(name, unpack, ...)
    local output = {}
    local db = Osi[name]:Get(Osiris._ParseParameters(...))

    if #db >= 1 then
        -- Unpack first value
        for _,value in ipairs(db[1]) do
            table.insert(output, value)
        end

        -- Append the list of all tuples at the very end - it will be returned as last parameter
        table.insert(output, db)

        if unpack then
            return table.unpack(output)
        else
            return db
        end

    elseif db == nil then
        error("[OSIRIS] Database does not exist: " .. name)
    else
        return nil
    end
end

---Return the output of a User Query.
---@param name string The query.
---@param ... any Query parameters.
function Osiris.UserQuery(name, ...)
    local paramCount = select("#", ...)
    local userQuery = Osiris.GetUserQuery(name, paramCount)

    -- Call query
    return userQuery:Query(...)
end
