
---@meta Library: GameItem, ContextClient, Item

---------------------------------------------
-- REGION Querying items in inventories.
---------------------------------------------

---Sets a custom icon for an item.
---Not persistent!
---@param item Item
---@param icon string
function Item.SetIconOverride(item, icon)
    item.Icon = icon
end

---Count the amount of template instances (prefix + guid) in the client party's inventory.
---@param template string
---@return number
function Item.GetPartyTemplateCount(template)
    local count = 0
    local predicate = function(item)
        return item.RootTemplate.Id == template
    end

    for _,player in ipairs(Character.GetPartyMembers(Client.GetCharacter())) do
        count = count + Item.CountItemsInInventory(player, predicate)
    end

    return count
end

-- As of v56, Amount is now mapped on client.
--- Count the items in an entity's inventory that match a predicate.  
--- Different from the server implementation, as item amounts cannot be queried on client from the item object. We rely on partyInventory UI instead.
-- function Item.CountItemsInInventory(entity, predicate)
--     local root = Client.UI.PartyInventory:GetRoot()
--     local count = 0

--     -- Need to refresh the inventory beforehand, as it might not have been opened while calling (and therefore be out of date)
--     Client.UI.PartyInventory.Refresh()

--     -- For each character inventory
--     for i=0,#root.inventory_mc.list.content_array-1,1 do
--         local inv = root.inventory_mc.list.content_array[i].inv

--         if inv.id == Ext.HandleToDouble(entity.Handle) then
--             -- For each item cell
--             for z=0,#inv.item_array-1,1 do
--                 local cell = inv.item_array[z]
--                 local item = Ext.GetItem(Ext.DoubleToHandle(cell._itemHandle))

--                 if item and predicate(item) then
--                     local amount = cell.amount_txt.htmlText
--                     if amount == "" then amount = 1 end

--                     count = count + tonumber(amount)
--                 end

--             end
--         end
--     end

--     return count
-- end

-- function Item.CountItemsInInventory(entity, predicate)
--     local root = Client.UI.PartyInventory:GetRoot()
--     local count = 0

--     for i,guid in ipairs(entity:GetInventoryItems()) do
--         local item = Ext.Entity.GetItem(guid)

--         if predicate(item) then
--             count = count + item.Amount
--         end
--     end

--     return count
-- end