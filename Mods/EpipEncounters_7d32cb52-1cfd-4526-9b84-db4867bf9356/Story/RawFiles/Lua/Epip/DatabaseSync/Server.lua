
---@class Feature_DatabaseSync
local DBSync = Epip.GetFeature("Feature_DatabaseSync")

---------------------------------------------
-- METHODS
---------------------------------------------

function DBSync._UpdateDatabaseVariables(name, arity)
    DBSync:DebugLog("Synching database ", name, arity)

    local tuples = Osiris.DatabaseQuery(name, false, table.unpackSelect({}, arity))

    Net.Broadcast("Feature_DatabaseSync_NetMessage_SyncDatabase", {
        DatabaseName = name,
        Arity = arity,
        Tuples = tuples,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for clients becoming ready to send them database entries.
GameState.Events.ClientReady:Subscribe(function (ev)
    for dbName,arities in pairs(DBSync._Definitions) do
        for arity,_ in pairs(arities) do
            Net.PostToCharacter(ev.CharacterNetID, "Feature_DatabaseSync_NetMessage_SyncDatabase", {
                DatabaseName = dbName,
                Arity = arity,
                Tuples = Osiris.DatabaseQuery(dbName, false, table.unpackSelect({}, arity))
            })
        end
    end
end)