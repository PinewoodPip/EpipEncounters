
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
        item.DontAddToHotbar = markAsWares
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