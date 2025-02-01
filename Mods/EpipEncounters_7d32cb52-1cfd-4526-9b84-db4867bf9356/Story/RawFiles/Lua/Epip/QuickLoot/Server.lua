
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

---Plays a beam effect between char and the container or corpse holding the item.
---@param char EsvCharacter
---@param item EsvItem
function QuickLoot.PlayLootingEffect(char, item)
    local inventoryParent = Item.GetInventoryParent(item) -- Assumed not to be nested in inventories.
    if inventoryParent then -- The item might be on the ground.
        Osiris.PlayBeamEffect(char, inventoryParent, Item.TELEKINESIS_BEAM_EFFECT, "Dummy_R_Hand", "Dummy_Root")
        Osiris.PlayEffect(item, Item.TELEKINESIS_IMPACT_EFFECT, "Dummy_Root")
    else -- Play a poof effect instead. Sadly using ItemMoveToPosition together with ItemToInventory causes random (and frequent) crashes, so we cannot emulate a pickup animation.
        local pos = item.WorldPos
        Osiris.PlayEffectAtPosition(QuickLoot.GROUND_ITEM_PICKUP_EFFECT, pos[1], pos[2], pos[3]) -- Could've been done client-side, but we consider it useful for other players to see that someone else is looting ground items this way.
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests to pick up items.
Net.RegisterListener(QuickLoot.NETMSG_PICKUP_ITEM, function (payload)
    local char, item = payload:GetCharacter(), payload:GetItem()
    -- Should be done before looting, as the container/corpse of the item must be determined.
    if payload.PlayLootingEffect then
        QuickLoot.PlayLootingEffect(char, item)
    end
    QuickLoot.PickUpItem(char, item)
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
