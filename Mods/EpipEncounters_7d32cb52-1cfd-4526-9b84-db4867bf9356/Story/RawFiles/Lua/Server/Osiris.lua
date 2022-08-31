
---@class OsirisDatabase
---@field Name string
---@field Arity integer
---@field Fields OsirisType[]

---@class OsirisLib : Osi
Osiris = {
    DATABASES = {},
    USER_QUERIES = {},
}

---@alias OsirisType "INTEGER" | "INTEGER64" | "REAL" | "STRING" | "REAL" | "GUIDSTRING" | "CHARACTERGUID" | "ITEMGUID" | "TRIGGERGUID" | "SPLINEGUID" | "LEVELTEMPLATEGUID"

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
    return Osiris.DatabaseQuery(self.Name, true, ...)
end

---Query a database. The first tuple will be unpacked;
---afterwards, a list is returned as well.
---@vararg any Query parameters.
function _OsirisDatabase:Get(...)
    return Osiris.DatabaseQuery(self.Name, true, ...)
end

---Returns a list of tuples matching the query.
---@return table<integer, any>[]
function _OsirisDatabase:GetTuples(...)
    return Osiris.DatabaseQuery(self.Name, false, ...)
end

---Delete tuples from the DB.
---@vararg any Tuple query to delete.
function _OsirisDatabase:Delete(...)
    Osi[self.Name]:Delete(...)
end

---Set a tuple on the DB.
---@vararg any Tuple values
function _OsirisDatabase:Set(...)
    Osi[self.Name](...)
end

---@param db string
---@param params OsirisType[]
function Osiris.RegisterDatabase(db, fields)
    Osiris.DATABASES[db] = {
        Name = db,
        Arity = #fields,
        Fields = fields,
    }
end

---Requires all these parameters since we cannot store nil in a table.
function Osiris._ParseParameters(...)
    local params = table.pack(...)
    local length = select("#", ...)

    for i=1,length,1 do
        local v = params[i]
        -- Convert entity references to their GUIDs.
        if GetExtType(v) then
            params[i] = v.MyGuid
        end
    end

    return table.unpackSelect(params, length)
end

---@param name string
---@param outputDBs OsirisDatabase[]
function Osiris.RegisterUserQuery(name, outputDBs)
    for _,outputDB in ipairs(outputDBs) do
        if not Osiris.DATABASES[outputDB] then
            Osiris:LogError("Output DB must be registered before query: " .. outputDB)
            return nil
        end
    end

    Osiris.USER_QUERIES[name] = outputDBs
end

function Osiris.RegisterSymbolListener(symbol, arity, timing, handler)
    Ext.Osiris.RegisterListener(symbol, arity, timing, handler)
end

---------------------------------------------
-- CALL WRAPPER
---------------------------------------------

local function meta_osiindex(_, key)
    if Osiris.USER_QUERIES[key] then -- User Query
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

        return symbol
    end
end
setmetatable(Osiris, { -- Access is query by default
    __index = meta_osiindex
})

---Query a database.
---@param name string
---@param unpack boolean If true, the first tuple found will be unpacked. The last value returned (arity + 1) will be the list of all tuples.
---@vararg any Query parameters.
---@return any Unpacked values or list of tuples, based on unpack parameter.
function Osiris.DatabaseQuery(name, unpack, ...)
    local output = {}
    local db = Osi[name]:Get(Osiris._ParseParameters(...))

    if #db >= 1 then
        -- Unpack first value
        for i,value in ipairs(db[1]) do
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
---@vararg Query parameters.
function Osiris.UserQuery(name, ...)
    local dbs = Osiris.USER_QUERIES[name]
    local output = {}

    -- Call query
    Osi[name](Osiris._ParseParameters(...))

    -- Fetch its output DBs
    for i,dbName in ipairs(dbs) do
        local dbData = Osiris.DATABASES[dbName]
        local result

        result = Osiris.DatabaseQuery(dbName, false, table.unpackSelect({}, dbData.Arity))

        for _,queryResult in ipairs(result) do
            for _,value in ipairs(queryResult) do
                table.insert(output, value)
            end
        end
    end

    return table.unpack(output)
end

---------------------------------------------
-- TESTING
---------------------------------------------

local Integer = "DB_AMER_GEN_OUTPUT_Integer"
local Point = "DB_AMER_GEN_OUTPUT_Point"
local Real = "DB_AMER_GEN_OUTPUT_Real"
local IntegerB = "DB_AMER_GEN_OUTPUT_Integer_B"
local StringB = "DB_AMER_GEN_OUTPUT_String_B"
local String = "DB_AMER_GEN_OUTPUT_String"

local AMER_DATABASES = {
    -- Generic output DBs
    [Point] = {"REAL", "REAL", "REAL"},
    [Integer] = {"INTEGER"},
    [IntegerB] = {"INTEGER"},
    [Real] = {"REAL"},
    [String] = {"String"},
    [StringB] = {"String"},

    ["DB_AMER_Reaction_FreeCount_Remaining"] = {"CHARACTERGUID", "STRING", "INTEGER"},
    ["DB_AMER_ExtendedStat_AddedStat"] = {"CHARACTERGUID", "STRING", "STRING", "STRING", "STRING", "REAL"},
    ["DB_AMER_BatteredHarried_OUTPUT_CurrentStacks"] = {"INTEGER", "INTEGER", "INTEGER"},
}

local AMER_QUERIES = {
    ["QRY_AMER_GEN_FindValidPos_Guid"] = {Point},
    ["QRY_AMER_UI_Ascension_GetEmbodimentCount"] = {Integer},
    ["QRY_AMER_Combat_CharacterHasActed"] = {Integer},
    ["QRY_AMER_GEN_GetSurfaceKeyword"] = {String},

    -- Ascension Gameplay
    ["QRY_AMER_KeywordStat_Celestial_GetHeal"] = {Real},
    ["QRY_AMER_KeywordStat_VitalityVoid_GetRadius"] = {Real},
    ["QRY_AMER_KeywordStat_VitalityVoid_GetPower"] = {Real},
    ["QRY_AMER_KeywordStat_Prosperity_GetThreshold"] = {Real},

    ["QRY_AMER_BatteredHarried_GetCurrentStacks"] = {"DB_AMER_BatteredHarried_OUTPUT_CurrentStacks"},
}

for name,params in pairs(AMER_DATABASES) do
    Osiris.RegisterDatabase(name, params)
end

for name,outputDBs in pairs(AMER_QUERIES) do
    Osiris.RegisterUserQuery(name, outputDBs)
end
