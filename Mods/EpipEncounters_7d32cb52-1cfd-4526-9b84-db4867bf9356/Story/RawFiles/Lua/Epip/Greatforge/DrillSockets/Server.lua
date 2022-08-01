
local Drill = Epip.Features.DrillSockets

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---@diagnostic disable-next-line
Osiris.RegisterSymbolListener('PROC_AMER_UI_Greatforge_DoCraft', 11, "after", function(instance, char, cont, item, level, itemType, slot, subType, handedness, value, craftOperation)
    if (craftOperation == "AddSockets") then
        local itemObj = Item.Get(item)

        itemObj.Stats.DynamicStats[2].RuneSlots = itemObj.Stats.DynamicStats[2].RuneSlots + 1

        Net.Broadcast("EPIPENCOUNTERS_ItemDrilled", {
            ItemNetID = itemObj.NetID,
        })

        Drill:DebugLog("Socket added to " .. itemObj.DisplayName)
    end
end)