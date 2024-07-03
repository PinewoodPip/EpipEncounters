
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

Net.RegisterListener(QuickLoot.NETMSG_GENERATE_TREASURE, function (payload)
    local char = payload:GetCharacter()
    for _,netID in ipairs(payload.ItemNetIDs) do
        local item = Item.Get(netID)

        Item.GenerateDefaultTreasure(item, char)

        -- Mark the containers as having been opened
        item.Known = true -- Unsure if necessary, nor what exactly it means.
        item.IsContainer = true -- This appears to actually be the equivalent of the "WasOpened" client flag.
    end
    -- Items generated seem to need a delay before they're synched.
    -- 0.1s can fail even in singleplayer.
    Timer.Start(0.15, function (_)
        Net.PostToCharacter(payload:GetCharacter(), QuickLoot.NETMSG_TREASURE_GENERATED)
    end)
end)
