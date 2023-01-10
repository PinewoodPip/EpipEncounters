
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")

---@class Feature_DatabaseSync : Feature
local DBSync = {
    ---@type table<string, table<integer, Feature_DatabaseSync_DatabaseDefinition>> Maps database name to table<arity, Feature_DatabaseSync_DatabaseDefinition>
    _Definitions = DefaultTable.Create({}),
    UserVars = {},
}
Epip.RegisterFeature("DatabaseSync", DBSync)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Feature_DatabaseSync_NetMessage_SyncDatabase : NetLib_Message
---@field DatabaseName string
---@field Arity integer
---@field Tuples any[][]

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_DatabaseSync_DatabaseDefinition
---@field DatabaseName string
---@field Arity integer
---@field FieldNames string[] Names for each element within the database's tuples.

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a database to be synched.
---@param name string
---@param arity integer
---@param fieldNames string[] Keys to be used for the table fields, in order of their appearance in tuples. **The field containing the GUID must be omitted.**
function DBSync.RegisterDatabase(name, arity, fieldNames)
    ---@type Feature_DatabaseSync_DatabaseDefinition
    local entry = {
        DatabaseName = name,
        Arity = arity,
        FieldNames = fieldNames,
    }

    if Ext.IsServer() then
        Osiris.RegisterSymbolListener(name, arity, "after", function (_)
            DBSync._UpdateDatabaseVariables(name, arity)
        end)

        DBSync._UpdateDatabaseVariables(name, arity)
    end

    DBSync._Definitions[name][arity] = entry
end

---------------------------------------------
-- TESTS
---------------------------------------------

function DBSync:__Test()
    DBSync.RegisterDatabase("DB_AMER_BatteredHarried_BufferedDamage", 2, {"Amount"})
end