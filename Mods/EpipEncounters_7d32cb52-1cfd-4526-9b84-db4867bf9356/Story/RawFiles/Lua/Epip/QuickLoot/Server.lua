
---@class Features.QuickLoot
local QuickLoot = Epip.GetFeature("Features.QuickLoot")

---------------------------------------------
-- METHODS
---------------------------------------------

---Picks up an item to char's inventory.
---@param char EsvCharacter
---@param item EsvItem
function QuickLoot.PickUpItem(char, item)
    Osiris.ItemToInventory(item, char, item.Amount, 1, 0)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests to pick up items.
Net.RegisterListener(QuickLoot.NETMSG_PICKUP_ITEM, function (payload)
    QuickLoot.PickUpItem(payload:GetCharacter(), payload:GetItem())
end)
