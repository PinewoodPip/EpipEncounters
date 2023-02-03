
---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Equipment filter.
QuickInventory.Hooks.IsItemVisible:Subscribe(function (ev)
    local item = ev.Item
    local visible = ev.Visible

    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Equipment" then
        local itemSlotSetting = QuickInventory:GetSettingValue(QuickInventory.Settings.ItemSlot)

        visible = Item.IsEquipment(item)

        -- Slot restriction
        if itemSlotSetting == "Weapon" then
            local weaponSubTypeSetting = QuickInventory:GetSettingValue(QuickInventory.Settings.WeaponSubType)

            visible = visible and Item.GetItemSlot(item) == itemSlotSetting

            -- Weapon subtype restriction
            if weaponSubTypeSetting ~= "Any" then
                visible = visible and Item.GetEquipmentSubtype(item) == weaponSubTypeSetting
            end
        elseif itemSlotSetting ~= "Any" then
            visible = visible and Item.GetItemSlot(item) == itemSlotSetting
        end
    end

    ev.Visible = visible
end)

-- Sort equipment by rarity.
QuickInventory.Hooks.SortItems:Subscribe(function (ev)
    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Equipment" then
        local rarityA, rarityB = ev.ItemA.Stats.Rarity, ev.ItemB.Stats.Rarity
        local scoreA, scoreB

        if Item.IsArtifact(ev.ItemA) then
            rarityA = "Artifact"
        end
        if Item.IsArtifact(ev.ItemB) then
            rarityB = "Artifact"
        end

        scoreA, scoreB = QuickInventory.RARITY_PRIORITY[rarityA] or 0, QuickInventory.RARITY_PRIORITY[rarityB] or 0

        ev.Result = scoreA > scoreB
        ev:StopPropagation()
    end
end)