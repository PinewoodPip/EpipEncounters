
---@class OsirisHelper
---@field DATABASES table<string, OsirisDatabase>

---@class OsirisDatabase
---@field Name string
---@field Arity integer
---@field Fields OsirisType[]

---@type OsirisHelper
Osiris = {
    Query = {}, -- metatable, has __index override

    DATABASES = {},
    USER_QUERIES = {},
}
-- Epip.InitializeLibrary("Osiris", Osiris)

---@alias OsirisType "INTEGER" | "INTEGER64" | "REAL" | "STRING" | "REAL" | "GUIDSTRING" | "CHARACTERGUID" | "ITEMGUID" | "TRIGGERGUID" | "SPLINEGUID" | "LEVELTEMPLATEGUID"

---@class OsirisDatabase
---@field Name string

_OsirisDatabase = {
    Name = "",
}

-- TODO query class

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

---@param name string
---@param outputDBs OsirisDatabase[]
function Osiris.RegisterUserQuery(name, outputDBs)

    for i,outputDB in ipairs(outputDBs) do
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

-- TODO vanilla queries?
local function meta_osiindex(self, key, ...)
    -- local params = {table.unpack(params)}

    -- TODO
    -- -- Automatically convert Entities in parameters into Entity.MyGuid
    -- for i,v in ipairs(params) do
    --     if type(v) == "userdata" then
    --         params[i] = v.MyGuid
    --     end
    -- end

    if Osiris.USER_QUERIES[key] then
        return function(...)
            return Osiris.UserQuery(key, ...)
        end
    else -- Default to DB query
        local tb = {Name = key}
        setmetatable(tb, {__index = _OsirisDatabase, __call = _OsirisDatabase.__call})
        return tb
    end
end

setmetatable(Osiris.Query, {
    __index = meta_osiindex
})
setmetatable(Osiris, { -- Access is query by default
    __index = meta_osiindex
})

---Query a database.
---@param name string
---@param unpack boolean If true, the first tuple found will be unpacked. The last value returned (arity + 1) will be the list of all tuples.
---@vararg any Query parameters.
---@return any Unpacked values or list of tuples, based on unpack parameter.
function Osiris.DatabaseQuery(name, unpack, ...)
    -- local params = Osiris.DATABASES[name].Fields
    local output = {}
    local db = Osi[name]:Get(...)

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
        Osiris:LogError("Database does not exist: " .. name)
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
    Osi[name](...)

    -- Fetch its output DBs
    for i,dbName in ipairs(dbs) do
        local dbData = Osiris.DATABASES[dbName]
        local result

        -- TODO find a better way to do this
        if dbData.Arity == 0 then
            result = Osiris.DatabaseQuery(dbName, false)
        elseif dbData.Arity == 1 then
            result = Osiris.DatabaseQuery(dbName, false, nil)
        elseif dbData.Arity == 2 then
            result = Osiris.DatabaseQuery(dbName, false, nil, nil)
        elseif dbData.Arity == 3 then
            result = Osiris.DatabaseQuery(dbName, false, nil, nil, nil)
        elseif dbData.Arity == 4 then
            result = Osiris.DatabaseQuery(dbName, false, nil, nil, nil, nil)
        elseif dbData.Arity == 5 then
            result = Osiris.DatabaseQuery(dbName, false, nil, nil, nil, nil, nil, nil)
        elseif dbData.Arity == 6 then
            result = Osiris.DatabaseQuery(dbName, false, nil, nil, nil, nil, nil, nil, nil)
        elseif dbData.Arity == 7 then
            result = Osiris.DatabaseQuery(dbName, false, nil, nil, nil, nil, nil, nil, nil, nil)
        else
            Osiris:LogError("Unsupported arity: " .. dbData.Arity)
        end

        for i,queryResult in ipairs(result) do
            for z,value in ipairs(queryResult) do
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
