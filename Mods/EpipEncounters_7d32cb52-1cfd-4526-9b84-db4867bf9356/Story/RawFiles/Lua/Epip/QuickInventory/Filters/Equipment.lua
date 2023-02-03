
local CommonStrings = Text.CommonStrings

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

---------------------------------------------
-- SETTINGS
---------------------------------------------

QuickInventory.Settings.ItemSlot = QuickInventory:RegisterSetting("ItemSlot", {
    Type = "Choice",
    Name = CommonStrings.ItemSlot,
    DefaultValue = "Helmet",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Any", NameHandle = CommonStrings.Any.Handle},
        {ID = "Helmet", NameHandle = CommonStrings.Helmet.Handle},
        {ID = "Breast", NameHandle = CommonStrings.Breast.Handle},
        {ID = "Leggings", NameHandle = CommonStrings.Leggings.Handle},
        {ID = "Weapon", NameHandle = CommonStrings.Weapon.Handle},
        {ID = "Shield", NameHandle = CommonStrings.Shield.Handle},
        {ID = "Ring", NameHandle = CommonStrings.Ring.Handle},
        {ID = "Boots", NameHandle = CommonStrings.Boots.Handle},
        {ID = "Belt", NameHandle = CommonStrings.Belt.Handle},
        {ID = "Amulet", NameHandle = CommonStrings.Amulet.Handle},
    },
})

QuickInventory.Settings.WeaponSubType = QuickInventory:RegisterSetting("WeaponSubType", {
    Type = "Choice",
    Name = CommonStrings.WeaponType,
    DefaultValue = "Any",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Any", NameHandle = Text.CommonStrings.Any.Handle},
        {ID = "Sword", NameHandle = Text.CommonStrings.Sword.Handle},
        {ID = "Axe", NameHandle = Text.CommonStrings.Axe.Handle},
        {ID = "Club", NameHandle = Text.CommonStrings.Club.Handle},
        {ID = "Staff", NameHandle = Text.CommonStrings.Staff.Handle},
        {ID = "Knife", NameHandle = Text.CommonStrings.Knife.Handle},
        {ID = "Spear", NameHandle = Text.CommonStrings.Spear.Handle},
    },
})

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