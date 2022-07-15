
local ItemTagging = Epip.Features.ItemTagging

---------------------------------------------
-- METHODS
---------------------------------------------

---@param item EsvItem
---@param tag string
function ItemTagging.TagItem(item, tag)
    Osi.SetTag(item.MyGuid, tag)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Osiris.RegisterSymbolListener("GameBookInterfaceClosed", 2, "after", function(item, _)
    item = Item.Get(item)

    ItemTagging.TagItem(item, ItemTagging.BOOK_READ_TAG)
end)

Osiris.RegisterSymbolListener("ItemUnlocked", 3, "after", function(_, _, keyItem)
    if keyItem ~= NULLGUID and not keyItem:find("LockPick") then
        local item = Item.Get(keyItem)

        ItemTagging.TagItem(item, ItemTagging.KEY_USED_TAG)
    end
end)