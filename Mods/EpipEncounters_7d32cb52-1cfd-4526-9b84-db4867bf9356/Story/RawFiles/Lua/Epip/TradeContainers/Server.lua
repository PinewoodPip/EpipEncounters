
---@class Features.TradeContainers
local TradeContainers = Epip.GetFeature("Features.TradeContainers")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests to open containers.
Net.RegisterListener(TradeContainers.NETMSG_OPEN_CONTAINER, function (payload)
    local char, item = payload:GetCharacter(), payload:GetItem()
    Osiris.CharacterUseItem(char, item, "") -- Container check is client-side.
end)

-- Handle requests to transfer items from a container to their parent character.
Net.RegisterListener(TradeContainers.NETMSG_SEND_TO_CHARACTER, function (payload)
    local char, item = payload:GetCharacter(), payload:GetItem()
    Osiris.ItemToInventory(item, char, item.Amount, 0, 0)
    Net.PostToUser(char, TradeContainers.NETMSG_SEND_TO_CHARACTER_COMPLETED, {
        ItemNetID = item.NetID,
    })
end)
