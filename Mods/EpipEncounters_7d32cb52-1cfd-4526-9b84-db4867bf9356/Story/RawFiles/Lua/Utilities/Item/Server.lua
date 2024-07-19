
---@class ItemLib
local Item = Item

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Forward item use events.
Osiris.RegisterSymbolListener("CharacterUsedItem", 2, "after", function(charGUID, itemGUID)
    local char, item = Character.Get(charGUID), Item.Get(itemGUID)
    Item.Events.ItemUsed:Throw({
        Character = char,
        Item = item,
    })
    -- Forward event to clients.
    Net.Broadcast(Item.NETMSG_ITEM_USED, {
        CharacterNetID = char.NetID,
        ItemNetID = item.NetID,
    })
end)
