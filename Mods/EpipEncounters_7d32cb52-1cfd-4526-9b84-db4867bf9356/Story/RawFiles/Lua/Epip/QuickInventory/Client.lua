
local CommonStrings = Text.CommonStrings

---@class Feature_QuickInventory : Feature
local QuickInventory = {
    RARITY_PRIORITY = {
        Common = 1,
        Uncommon = 2,
        Rare = 3,
        Epic = 4,
        Legendary = 5,
        Divine = 6,
        Unique = 7,
        Artifact = 8,
    },

    TranslatedStrings = {
        Header = {
           Handle = "hf196badfg6c61g4bd5g91e8g7bfbf9874cbf",
           Text = "Quick Swap",
           ContextDescription = "Header for the UI",
        },
    },

    Settings = {
        ItemCategory = {
            Type = "Choice",
            Name = "Item Category",
            Description = "",
            DefaultValue = "Equipment",
            ---@type SettingsLib_Setting_Choice_Entry[]
            Choices = {
                {ID = "Equipment", NameHandle = CommonStrings.Equipment.Handle},
                {ID = "Consumables", NameHandle = CommonStrings.Consumables.Handle},
                {ID = "Skillbooks", NameHandle = CommonStrings.Skillbooks.Handle},
            },
        },
        ItemSlot = {
            Type = "Choice",
            Name = "Item Slot",
            Description = "",
            DefaultValue = "Helmet",
            ---@type SettingsLib_Setting_Choice_Entry[]
            Choices = {
                {ID = "Any", Name = "Any"},
                {ID = "Helmet", Name = "Helmet"},
                {ID = "Breast", Name = "Breast"},
                {ID = "Leggings", Name = "Leggings"},
                {ID = "Weapon", Name = "Weapon"},
                {ID = "Shield", Name = "Shield"},
                {ID = "Ring", Name = "Ring"},
                {ID = "Boots", Name = "Boots"},
                {ID = "Belt", Name = "Belt"},
                {ID = "Amulet", Name = "Amulet"},
            },
        },
        WeaponSubType = {
            Type = "Choice",
            Name = "Weapon Type",
            Description = "",
            DefaultValue = "Any",
            ---@type SettingsLib_Setting_Choice_Entry[]
            Choices = {
                {ID = "Any", Name = Text.CommonStrings.Any:GetString()},
                {ID = "Sword", Name = Text.CommonStrings.Sword:GetString()},
                {ID = "Axe", Name = Text.CommonStrings.Axe:GetString()},
                {ID = "Club", Name = Text.CommonStrings.Club:GetString()},
                {ID = "Staff", Name = Text.CommonStrings.Staff:GetString()},
                {ID = "Knife", Name = Text.CommonStrings.Knife:GetString()},
                {ID = "Spear", Name = Text.CommonStrings.Spear:GetString()},
            },
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        IsItemVisible = {}, ---@type Event<Feature_QuickInventory_Hook_IsItemVisible>
        SortItems = {}, ---@type Event<Feature_QuickInventory_Hook_SortItems>
    }
}
Epip.RegisterFeature("QuickInventory", QuickInventory)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Feature_QuickInventory_Hook_IsItemVisible
---@field Item EclItem
---@field Visible boolean Hookable. Defaults to `true`.

---@class Feature_QuickInventory_Hook_SortItems
---@field ItemA EclItem
---@field ItemB EclItem
---@field Result boolean Hookable. Defaults to sorting by handle.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the items from the party's inventory that match the filters set by hooks.
---@return EclItem[]
function QuickInventory.GetItems()
    local char = Client.GetCharacter()
    local allItems = Item.GetItemsInPartyInventory(char)
    local items = {} ---@type EclItem[]

    for _,item in ipairs(allItems) do
        local visible = QuickInventory.Hooks.IsItemVisible:Throw({
            Item = item,
            Visible = true,
        }).Visible

        if visible then
            table.insert(items, item)
        end
    end

    -- Sort items
    table.sort(items, function (itemA, itemB)
        local sortOutcome = QuickInventory.Hooks.SortItems:Throw({
            ItemA = itemA,
            ItemB = itemB,
            Result = Ext.UI.HandleToDouble(itemA.Handle) > Ext.UI.HandleToDouble(itemB.Handle),
        }).Result

        return sortOutcome
    end)

    return items
end

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

-- Consumables filter.
QuickInventory.Hooks.IsItemVisible:Subscribe(function (ev)
    local item = ev.Item
    local visible = ev.Visible

    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Consumables" then
        visible = visible and Item.HasUseAction(item, "Consume")
    end
    
    ev.Visible = visible
end)

-- Skillbooks filter.
QuickInventory.Hooks.IsItemVisible:Subscribe(function (ev)
    local item = ev.Item
    local visible = ev.Visible

    if QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory) == "Skillbooks" then
        visible = visible and Item.HasUseAction(item, "SkillBook")
    end
    
    ev.Visible = visible
end)