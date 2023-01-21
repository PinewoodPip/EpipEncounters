
---@class Feature_DatabaseSync
local DBSync = Epip.GetFeature("Feature_DatabaseSync")

---------------------------------------------
-- METHODS
---------------------------------------------

function DBSync._ResyncAll()
    for dbName,arities in pairs(DBSync._Definitions) do
        for arity,_ in pairs(arities) do
            -- TODO char parameter for performance
            Net.Broadcast("Feature_DatabaseSync_NetMessage_SyncDatabase", {
                DatabaseName = dbName,
                Arity = arity,
                Tuples = Osiris.DatabaseQuery(dbName, false, table.unpackSelect({}, arity))
            })
        end
    end
end

function DBSync._UpdateDatabaseVariables(name, arity)
    DBSync:DebugLog("Synching database ", name, arity)

    if Ext.Osiris.IsCallable() then
        local tuples = Osiris.DatabaseQuery(name, false, table.unpackSelect({}, arity))
    
        Net.Broadcast("Feature_DatabaseSync_NetMessage_SyncDatabase", {
            DatabaseName = name,
            Arity = arity,
            Tuples = tuples,
        })
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Resend tuples when a reset completes.
Ext.Events.ResetCompleted:Subscribe(function (_)
    DBSync._ResyncAll()
end)

-- Listen for clients becoming ready to send them database entries.
GameState.Events.ClientReady:Subscribe(function (_)
    DBSync._ResyncAll()
end)