
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
        local owner = Osiris.ItemGetOwner(item)
        item.DontAddToHotbar = markAsWares

        -- Necessary to properly update the inventory UI, else the item will not show in the correct categories.
        -- The InPartyInventory flag tracks whether the item displays the "newly-received" border in the UI.
        -- We don't have access to it on the client, so we set it from the server and force a sync.
        -- Unfortunately, this will also cause the item to be moved to the first empty slot.
        Osiris.ItemToInventory(item, owner, item.Amount, 0, 0)
        item.InPartyInventory = false
        item.ForceClientSync = true
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