
-- Listen for unlock requests, broadcast them to all peers.
Net.RegisterListener("EPIPENCOUNTERS_AutoUnlockInventory", function (payload)
    Net.Broadcast("EPIPENCOUNTERS_AutoUnlockInventory", payload)
end)