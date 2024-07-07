
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
    local generatedContainers = {} ---@type table<NetId, integer>
    for _,netID in ipairs(payload.ItemNetIDs) do
        local item = Item.Get(netID)

        local oldItemsCount = #item:GetInventoryItems()
        local generated = Item.GenerateDefaultTreasure(item, char)
        local newItemsCount = #item:GetInventoryItems()
        local hasNewItems = newItemsCount > oldItemsCount
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

            -- Track containers that have had items generated
            -- so the client can know how many items to expect in them.
            -- Necessary as item synching can be at times slow.
            if hasNewItems then
                generatedContainers[item.NetID] = newItemsCount
            end
        end
    end
    Net.PostToCharacter(payload:GetCharacter(), QuickLoot.NETMSG_TREASURE_GENERATED, {
        GeneratedContainerNetIDs = generatedContainers,
    })
end)
