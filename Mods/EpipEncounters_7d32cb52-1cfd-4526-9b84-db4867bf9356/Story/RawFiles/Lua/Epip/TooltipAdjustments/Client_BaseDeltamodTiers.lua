
---------------------------------------------
-- Appends a label showing the "tier" of randomly-generated equipments's base deltamod.
-- EE-only.
---------------------------------------------

local Tooltip = Client.Tooltip

---@type Feature
local BaseDeltamodTiers = {
    TranslatedStrings = {
        Label_MaxQuality = {
           Handle = "he442b301g5534g421egbd7bg890c9f507e4c",
           Text = "Max Quality",
           ContextDescription = "Label for items with the best roll.",
        },
        Label_Quality = {
           Handle = "h9d15a9d1gffb2g4d67g8a4fg06b96367fd81",
           Text = "Quality %s%%",
           ContextDescription = "Toolip. First param is the quality of the item, as a percentage",
        },
        Label_Handedness_1 = {
           Handle = "hc7cfbfcdgc4b2g4ac3g92b3gbb6856d5b361",
           Text = "1Handed",
           ContextDescription = "Short for 'One-Handed'",
        },
        Label_Handedness_2 = {
           Handle = "hf9059123gbc1cg4092gb6dag0e85a8175300",
           Text = "2Handed",
           ContextDescription = "Short for 'Two-Handed'",
        },
    }
}
Epip.RegisterFeature("TooltipAdjustments.BaseDeltamodTiers", BaseDeltamodTiers)
local TSK = BaseDeltamodTiers.TranslatedStrings

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the "tier" of an item's base deltamod.
---@param item EclItem
---@return integer?, EpicEncounters.DeltaMods.BaseBoostTier? -- Tier and information on the tiers of the item type. `nil` if the item has no tier.
function BaseDeltamodTiers.GetTier(item)
    local tier = nil
    local itemType = Item.GetItemSlot(item)
    local tiers = EpicEncounters.DeltaMods.EQUIPMENT_BASE_BOOST_TIERS

    -- Use subtypes for armor only. Weapons all use the same deltamods regardless of subtype.
    if itemType ~= "Weapon" and Data.Game.SLOTS_WITH_SUBTYPES[itemType] then
        itemType = Item.GetEquipmentSubtype(item)
    end

    -- happens with the starting tattered robes (Cloth armor)
    if not tiers[itemType] then return nil, nil end

    -- find the "tier" of the item based on boosts
    for _,v in pairs(item.Stats.DynamicStats) do
        local boostName = v.ObjectInstanceName
        local boostTier = tiers[itemType].Boosts[boostName]
        if boostTier ~= nil then
            tier = boostTier
            break
        end
    end

    return tier, tiers[itemType]
end

---Adds a tier label to an equipment item tooltip.
---@param item EclItem Must be equipment.
---@param tooltip TooltipLib_FormattedTooltip
function BaseDeltamodTiers.AddLabel(item, tooltip)
    if not item.Stats then return end
    local tier, tiersInfo = BaseDeltamodTiers.GetTier(item)

    -- Do nothing for items with no tier found (ex. items that are not randomly-generated)
    if not tier then return end

    local slotType = tooltip:GetFirstElement("ArmorSlotType")
    local tierDisplay = 0
    local totalTiers = tiersInfo.Tiers
    local tierCutoff = math.max(0, totalTiers - 10)

    if tier >= tierCutoff then -- 55% to 100%, 10 tiers
        tierDisplay = ((tier - tierCutoff) * 0.05) + 0.5
    else -- 20% to 50%, 4 tiers
        tierDisplay = (tier * 0.1) + 0.1
    end

    tierDisplay = tierDisplay * 100

    tierDisplay = math.floor(tierDisplay)
    tierDisplay = math.max(0, tierDisplay)

    if tierDisplay == 100 then
        tierDisplay = TSK.Label_MaxQuality:GetString() -- Fancy display for fancy items!
    else
        tierDisplay = TSK.Label_Quality:Format(tierDisplay)
    end

    if slotType then
        -- Append tier display
        slotType.Label = slotType.Label .. string.format("  -  %s", tierDisplay)

        -- Shorten "One-Handed X" and "Two-Handed X" label if present
        local weaponType = Item.IsWeapon(item) and Item.GetEquipmentSubtype(item) or nil
        if weaponType and Item.WEAPONS_WITH_BOTH_HANDEDNESS_TYPES[weaponType] == true then
            local handedness = Item.GetHandedness(item)
            local tsk = handedness == "Two-Handed" and Item.ITEM_TYPE_TOOLTIP_TSKHANDLES.TWO_HANDED[weaponType] or Item.ITEM_TYPE_TOOLTIP_TSKHANDLES.ONE_HANDED[weaponType]
            local label = Text.GetTranslatedString(tsk)
            local replacement = string.format("%s %s", handedness == "Two-Handed" and TSK.Label_Handedness_2:GetString() or TSK.Label_Handedness_1:GetString(), Text.CommonStrings[weaponType]:GetString())

            slotType.Label = Text.Replace(slotType.Label, label, replacement)
        end
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Hook item tooltips.
Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    if Item.IsEquipment(ev.Item) then
        BaseDeltamodTiers.AddLabel(ev.Item, ev.Tooltip)
    end
end)