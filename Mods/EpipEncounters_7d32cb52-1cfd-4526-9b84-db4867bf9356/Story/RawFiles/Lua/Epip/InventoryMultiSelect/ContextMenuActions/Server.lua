
---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to toggle selections as wares.
Net.RegisterListener(MultiSelect.NETMSG_TOGGLE_WARES, function (payload)
    local markAsWares = payload.MarkAsWares
    for _,netID in ipairs(payload.ItemNetIDs) do
        local item = Item.Get(netID)
        Item.SetMarkedAsWares(item, markAsWares)

        -- The InPartyInventory flag tracks whether the item displays the "newly-received" border in the UI. Since SetMarkedAsWares requires the item to be re-added to the inventory, we need to clear the flag.
        item.InPartyInventory = false
    end
    MultiSelect:DebugLog("Toggled wares", markAsWares)
end)

-- Listen for requests to send selections to homestead chest.
Net.RegisterListener(MultiSelect.NETMSG_SEND_TO_HOMESTEAD, function (payload)
    local char = payload:GetCharacter()
    for _,netID in ipairs(payload.ItemNetIDs) do
        local item = Item.Get(netID)
        Osiris.ItemSendToHomesteadEvent(char, item)
    end
    MultiSelect:DebugLog("Sent items to homestead")
end)

-- Handle requests to drop items.
Net.RegisterListener(MultiSelect.NETMSG_DROP_ITEMS, function (payload)
    local char = payload:GetCharacter()
    local charPos = char.WorldPos
    for _,netID in ipairs(payload.ItemNetIDs) do
        local item = Item.Get(netID)
        Osiris.ItemScatterAt(item.MyGuid, table.unpack(charPos))
    end
    MultiSelect:DebugLog("Dropped items")
end)
