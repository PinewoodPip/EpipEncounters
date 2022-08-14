
local Encumbrance = Epip.Features.Encumbrance

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_ServerOptionChanged", function(payload)
    if payload.Mod == "EpipEncounters" and payload.Setting == "Inventory_InfiniteCarryWeight" then
        Encumbrance.Toggle(payload.Value)

        Net.Broadcast("EPIPENCOUNTERS_ToggleEncumbrance", {Enabled = payload.Value})
    end
end)

-- Send Net message on GameReady - the Net listener happens too early to ping back the clients.
GameState.Events.GameReady:Subscribe(function (e)
    Net.Broadcast("EPIPENCOUNTERS_ToggleEncumbrance", {Enabled = Encumbrance.enabled})
end)