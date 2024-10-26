
---@class ItemLib
local Item = Item

---Sets a custom icon for an item.
---Not persistent!
---@param item Item
---@param icon string
function Item.SetIconOverride(item, icon)
    item.Icon = icon
end

---Counts the amount of template instances in the client party's inventory recursively, considering item stacks.
---@param template GUID|PrefixedGUID
---@return integer
function Item.GetPartyTemplateCount(template)
    local char = Client.GetCharacter()
    local templateGUID = template:match(Text.PATTERNS.GUID)
    local predicate = function(item)
        ---@cast item Item
        return item.CurrentTemplate.Id == templateGUID
    end
    local templateItems = Item.GetItemsInPartyInventory(char, predicate, true)
    local count = 0

    for _,item in ipairs(templateItems) do
        count = count + item.Amount -- Consider item stacks.
    end

    return count
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Forward item use events.
Net.RegisterListener(Item.NETMSG_ITEM_USED, function (payload)
    Item.Events.ItemUsed:Throw({
        Character = payload:GetCharacter(),
        Item = payload:GetItem(),
    })
end)
