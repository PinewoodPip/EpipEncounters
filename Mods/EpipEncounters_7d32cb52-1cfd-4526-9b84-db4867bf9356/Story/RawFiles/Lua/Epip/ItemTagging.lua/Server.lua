
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

Osiris.RegisterSymbolListener("GameBookInterfaceClosed", 2, "after", function(item, char)
    item = Item.Get(item)
end)