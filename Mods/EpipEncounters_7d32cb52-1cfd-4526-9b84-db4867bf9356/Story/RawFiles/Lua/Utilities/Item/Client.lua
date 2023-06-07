
---@class ItemLib
local Item = Item

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
    local templateGUID = template:match(Text.PATTERNS.GUID)
    local count = 0
    local predicate = function(item)
        return item.RootTemplate.Id == templateGUID
    end

    for _,player in ipairs(Character.GetPartyMembers(Client.GetCharacter())) do
        count = count + Item.CountItemsInInventory(player, predicate)
    end

    return count
end