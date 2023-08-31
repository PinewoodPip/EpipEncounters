
---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to move selections to a container.
Net.RegisterListener(MultiSelect.NETMSG_SEND_TO_CONTAINER, function (payload)
    local container = Item.Get(payload.TargetContainerNetID)
    for _,netID in ipairs(payload.ItemNetIDs) do
        local item = Item.Get(netID)
        Osiris.ItemToInventory(item, container.MyGuid, item.Amount, 0, 0)
    end
end)

-- Listen for requests to move selections to a character.
Net.RegisterListener(MultiSelect.NETMSG_SEND_TO_CHARACTER, function (payload)
    local targetCharacter = Character.Get(payload.CharacterNetID)
    for _,netID in ipairs(payload.ItemNetIDs) do
        local item = Item.Get(netID)
        Osiris.ItemToInventory(item, targetCharacter.MyGuid, item.Amount, 0, 0)
    end
end)