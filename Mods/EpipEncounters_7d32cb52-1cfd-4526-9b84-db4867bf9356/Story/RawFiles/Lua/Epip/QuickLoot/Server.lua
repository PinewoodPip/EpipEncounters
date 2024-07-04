
local AutoIdentify = Epip.GetFeature("Feature_AutoIdentify")

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

    -- Does not appear to work.
    -- Osiris.CharacterPlayHUDSoundResource(char, item.CurrentTemplate.PickupSound)
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

        local generated = Item.GenerateDefaultTreasure(item, char)
        if generated then
            -- Mark the containers as having been opened
            item.Known = true -- Unsure if necessary, nor what exactly it means.
            item.IsContainer = true -- This appears to actually be the equivalent of the "WasOpened" client flag.

            -- Run auto-identify feature
            for _,itemGUID in ipairs(item:GetInventoryItems()) do
                local generatedItem = Item.Get(itemGUID)
                if not Item.IsIdentified(generatedItem) then
                    AutoIdentify.ProcessItem(generatedItem)
                end
            end
        end
    end
    -- Items generated seem to need a delay before they're synched.
    -- 0.1s can fail even in singleplayer.
    Timer.Start(0.15, function (_)
        Net.PostToCharacter(payload:GetCharacter(), QuickLoot.NETMSG_TREASURE_GENERATED)
    end)
end)
