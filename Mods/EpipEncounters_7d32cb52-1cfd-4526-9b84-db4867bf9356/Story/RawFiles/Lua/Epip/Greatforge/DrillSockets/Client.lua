
local Drill = Epip.Features.DrillSockets

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Update item properties on clients upon drilling.
Net.RegisterListener("EPIPENCOUNTERS_ItemDrilled", function(_, payload)
    local item = Item.Get(payload.ItemNetID)
    item.Stats.DynamicStats[2].RuneSlots = item.Stats.DynamicStats[2].RuneSlots + 1

    Drill:DebugLog("Client item synced after drilling " .. item.DisplayName)
end)