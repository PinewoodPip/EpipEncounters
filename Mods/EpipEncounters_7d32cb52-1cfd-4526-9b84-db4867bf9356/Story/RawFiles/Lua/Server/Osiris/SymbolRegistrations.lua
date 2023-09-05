
---@alias OsirisLib_DatabaseName "DB_AMER_BatteredHarried_BufferedDamage"
---|"DB_IsPlayer"
---|"DB_Origins"

---@class DB_IsPlayer
---@field CharacterGUID GUID

---------------------------------------------
-- DATABASES
---------------------------------------------

local Integer = "DB_AMER_GEN_OUTPUT_Integer"
local Point = "DB_AMER_GEN_OUTPUT_Point"
local Real = "DB_AMER_GEN_OUTPUT_Real"
local IntegerB = "DB_AMER_GEN_OUTPUT_Integer_B"
local StringB = "DB_AMER_GEN_OUTPUT_String_B"
local String = "DB_AMER_GEN_OUTPUT_String"

local AMER_DATABASES = {
    -- Generic output DBs
    [Point] = {
        {Name = "X", Type = "REAL"},
        {Name = "Y", Type = "REAL"},
        {Name = "Z", Type = "REAL"},
    },
    [Integer] = {
        {Name = "Output", Type = "INTEGER"}
    },
    [IntegerB] = {
        {Name = "Output", Type = "INTEGER"}
    },
    [Real] = {
        {Name = "Output", Type = "REAL"}
    },
    [String] = {
        {Name = "Output", Type = "STRING"}
    },
    [StringB] = {
        {Name = "Output", Type = "STRING"}
    },

    ["DB_AMER_Reaction_FreeCount_Remaining"] = {
        {Name = "Character", Type = "CHARACTERGUID"},
        {Name = "Reaction", Type = "STRING"},
        {Name = "Amount", Type = "INTEGER"},
    },
    ["DB_AMER_ExtendedStat_AddedStat"] = {
        {Name = "Character", Type = "CHARACTERGUID"},
        {Name = "Stat", Type = "STRING"},
        {Name = "Param1", Type = "STRING"},
        {Name = "Param2", Type = "STRING"},
        {Name = "Param3", Type = "STRING"},
        {Name = "Amount", Type = "REAL"},
    },
    ["DB_AMER_BatteredHarried_OUTPUT_CurrentStacks"] = {
        {Name = "Battered", Type = "INTEGER"},
        {Name = "Harried", Type = "INTEGER"},
        {Name = "Total", Type = "INTEGER"},
    },
    ["DB_AMER_BatteredHarried_BufferedDamage"] = {
        {Name = "Character", Type = "CHARACTERGUID"},
        {Name = "Amount", Type = "REAL"},
    }
}

for name,fields in pairs(AMER_DATABASES) do
    ---@type OsirisLib_Database
    local db = {
        Name = name,
        Arity = #fields,
        Fields = fields,
    }
    Osiris.RegisterDatabase(db)
end

---------------------------------------------
-- USER QUERIES
---------------------------------------------

---@type table<string, OsirisLib_UserQuery>
local AMER_QUERIES = {
    ["QRY_AMER_GEN_FindValidPos_Guid"] = {
        ParamCount = 5,
        OutputDatabases = {
            {Name = Point, Arity = 3},
        }
    },
    ["QRY_AMER_UI_Ascension_GetEmbodimentCount"] = {
        ParamCount = 2,
        OutputDatabases = {
            {Name = Integer, Arity = 1},
        }
    },

    -- Ascension Gameplay
    ["QRY_AMER_KeywordStat_Celestial_GetHeal"] = {
        ParamCount = 1,
        OutputDatabases = {
            {Name = Real, Arity = 1},
        }
    },
    ["QRY_AMER_KeywordStat_VitalityVoid_GetRadius"] = {
        ParamCount = 2,
        OutputDatabases = {
            {Name = Real, Arity = 1},
        }
    },
    ["QRY_AMER_KeywordStat_VitalityVoid_GetPower"] = {
        ParamCount = 2,
        OutputDatabases = {
            {Name = Real, Arity = 1},
        }
    },
    ["QRY_AMER_KeywordStat_Prosperity_GetThreshold"] = {
        ParamCount = 1,
        OutputDatabases = {
            {Name = Real, Arity = 1},
        }
    },
    ["QRY_AMER_BatteredHarried_GetCurrentStacks"] = {
        ParamCount = 1,
        OutputDatabases = {
            {Name = "DB_AMER_BatteredHarried_OUTPUT_CurrentStacks", Arity = 3},
        }
    },
}

for name,data in pairs(AMER_QUERIES) do
    data.Name = name
    Osiris.RegisterUserQuery(data)
end