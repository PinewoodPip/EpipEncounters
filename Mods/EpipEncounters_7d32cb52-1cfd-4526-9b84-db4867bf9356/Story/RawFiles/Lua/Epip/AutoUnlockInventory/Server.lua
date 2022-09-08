
-- Listen for unlock requests, broadcast them to all peers.
Net.RegisterListener("EPIPENCOUNTERS_ToggleInventoryLock", function (payload)
    Net.Broadcast("EPIPENCOUNTERS_ToggleInventoryLock", payload)
end)