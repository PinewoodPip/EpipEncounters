
---------------------------------------------
-- Helper methods to query info about the server, from a client.
---------------------------------------------

---@meta ContextClient, ClientServer

Server = {
    REGISTERED_OSIRIS_SYMBOL_EVENTS = {},
}
Epip.InitializeLibrary("Server", Server)

function Server.RegisterOsirisListener(symbol, arity, handler)
    local id = symbol .. arity

    -- Don't attempt to register these while on menu
    if not Server.REGISTERED_OSIRIS_SYMBOL_EVENTS[id] and Ext.Client.GetGameState() ~= "Menu" then
        Server.REGISTERED_OSIRIS_SYMBOL_EVENTS[id] = true

        Game.Net.PostToServer("EPIP_RegisterGenericOsiSymbolEvent", {
            Symbol = symbol,
            Arity = arity,
        })
    end

    Server:RegisterListener("OsirisSymbolEvent_" .. id, handler)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Forward generic osi events
Game.Net.RegisterListener("EPIP_GenericOsiSymbolEvent", function(cmd, payload)
    local id = payload.Symbol .. payload.Arity

    Server:FireEvent("OsirisSymbolEvent_" .. id, table.unpack(payload.Params))
end)