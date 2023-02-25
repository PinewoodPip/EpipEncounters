
local CommonStrings = Text.CommonStrings
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")

QuickInventory.SLOTS_WITH_ARMOR_SUBTYPES = Set.Create({
    "Helmet",
    "Breast",
    "Leggings",
    "Boots",
    "Gloves"
})

QuickInventory.DYNAMIC_STAT_FIELD_ALIASES = {
    -- Resistances
    ["Fire"] = Set.Create({
        "Fire Resistance",
        "Resistance",

        "Fire Damage",
        "Damage",
    }),
    ["Air"] = Set.Create({
        "Air Resistance",
        "Resistance",

        "Air Damage",
        "Damage",
    }),
    ["Water"] = Set.Create({
        "Water Resistance",
        "Resistance",

        "Water Damage",
        "Damage",
    }),
    ["Earth"] = Set.Create({
        "Earth Resistance",
        "Resistance",

        "Earth Damage",
        "Damage",
    }),
    ["Poison"] = Set.Create({
        "Poison Resistance",
        "Resistance",

        "Poison Damage",
        "Damage",
    }),
    ["Physical"] = Set.Create({
        "Physical Resistance",
        "Resistance",

        "Physical Damage",
        "Damage",
    }),
    ["Piercing"] = Set.Create({
        "Piercing Resistance",
        "Resistance",

        "Piercing Damage",
        "Damage",
    }),

    -- Abilities
    ["WarriorLore"] = Set.Create({
        "Warfare",
    }),
    ["RangerLore"] = Set.Create({
        "Huntsman",
    }),
    ["RogueLore"] = Set.Create({
        "Scoundrel",
    }),
    ["FireSpecialist"] = Set.Create({
        "Pyrokinetic",
    }),
    ["WaterSpecialist"] = Set.Create({
        "Hydrosophist",
    }),
    ["AirSpecialist"] = Set.Create({
        "Aerotheurge",
        "Aerothurge", -- Alias for Ameranth
    }),
    ["EarthSpecialist"] = Set.Create({
        "Geomancer",
    }),
    ["Necromancy"] = Set.Create({
        "Necromancy",
        "Necromancer",
    }),
    ["Barter"] = Set.Create({
        "Bartering",
    }),
    ["Luck"] = Set.Create({
        "Lucky Charm",
    }),
    ["PainReflection"] = Set.Create({
        "Retribution",
        "Reflect",
    }),

    ["Vitality"] = Set.Create({
        "Vitality",
        "HP",
        "Health",
    }),
    ["IntelligenceBoost"] = Set.Create({
        "Power",
        "Intelligence", -- For non-EE.
    }),
    ["CriticalChance"] = Set.Create({
        "Critical Chance",
    }),
}
-- Convert set elements to lowercase
for k,aliasSet in pairs(QuickInventory.DYNAMIC_STAT_FIELD_ALIASES) do
    local newSet = Set.Create()
    for element in aliasSet:Iterator() do
        newSet:Add(string.lower(element))
    end
    QuickInventory.DYNAMIC_STAT_FIELD_ALIASES[k] = newSet
end

local CACHED_STAT_FIELDS = nil ---@type table<string, string>

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

QuickInventory.Settings.ArmorSubType = QuickInventory:RegisterSetting("ArmorSubType", {
    Type = "Choice",
    Name = CommonStrings.ArmorType,
    DefaultValue = "Any",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Any", NameHandle = Text.CommonStrings.Any.Handle},
        {ID = "Cloth", NameHandle = Text.CommonStrings.ClothArmor.Handle},
        {ID = "Robe", NameHandle = Text.CommonStrings.RobesArmor.Handle},
        {ID = "Leather", NameHandle = Text.CommonStrings.LeatherArmor.Handle},
        {ID = "Plate", NameHandle = Text.CommonStrings.PlateArmor.Handle},
    },
})

QuickInventory.Settings.DynamicStat = QuickInventory:RegisterSetting("DynamicStat", {
    Type = "String",
    Name = QuickInventory.TranslatedStrings.DynamicStat_Name,
    DefaultValue = "",
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether an item's stat boosts match a string query.
---@param item EclItem
---@param query string Case-insensitive.
---@return boolean
local function ItemMatchesStatBoostQuery(item, query)
    local matches = false
    local dynamicStats = item.Stats.DynamicStats
    query = query:lower()

    -- Build a list of dynamic stat keys and their lowercase forms, for performance
    if not CACHED_STAT_FIELDS then
        local dynStat = dynamicStats[1]
        CACHED_STAT_FIELDS = {}

        for k,v in pairs(dynStat) do
            -- Only check bool and number fields.
            if type(v) == "boolean" or type(v) == "number" then
                CACHED_STAT_FIELDS[k] = string.lower(k)
            end
        end
    end

    for i=1,#dynamicStats,1 do
        local dynStat = dynamicStats[i]
        
        for field,value in pairs(dynStat) do
            local valueIsNotDefault = false
            local lowerCaseField = CACHED_STAT_FIELDS[field]

            if not lowerCaseField then
                lowerCaseField = field:lower()
                CACHED_STAT_FIELDS[field] = lowerCaseField
            end

            if type(value) == "boolean" then
                valueIsNotDefault = value
            elseif type(value) == "number" then
                valueIsNotDefault = value > 0 -- Don't consider penalties.
            end

            if valueIsNotDefault then
                local boostNames = {lowerCaseField}
                local aliases = QuickInventory.DYNAMIC_STAT_FIELD_ALIASES[field]

                if aliases then
                    boostNames = {}
                    for alias in aliases:Iterator() do
                        table.insert(boostNames, alias)
                    end
                end

                for _,boostName in ipairs(boostNames) do
                    local match = string.match(boostName, query)
                    if match then
                        matches = true
                        goto ItemMatchesDeltamodQuery_Done
                    end
                end
            end
        end
    end
    ::ItemMatchesDeltamodQuery_Done::

    return matches
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
        local statBoostSetting = QuickInventory:GetSettingValue(QuickInventory.Settings.DynamicStat)

        visible = Item.IsEquipment(item)

        if itemSlotSetting ~= "Any" then
            visible = visible and Item.GetItemSlot(item) == itemSlotSetting
        end

        -- Slot restriction
        if itemSlotSetting == "Weapon" then
            local weaponSubTypeSetting = QuickInventory:GetSettingValue(QuickInventory.Settings.WeaponSubType)

            -- Weapon subtype restriction
            if weaponSubTypeSetting ~= "Any" then
                visible = visible and Item.GetEquipmentSubtype(item) == weaponSubTypeSetting
            end
        elseif QuickInventory.SLOTS_WITH_ARMOR_SUBTYPES:Contains(itemSlotSetting) then 
            local armorSubTypeSetting = QuickInventory:GetSettingValue(QuickInventory.Settings.ArmorSubType)

            -- Armor subtype restriction
            if armorSubTypeSetting ~= "Any" then
                visible = visible and Item.GetEquipmentSubtype(item) == armorSubTypeSetting
            end
        end

        -- Filter by deltamod stat boosts.
        if statBoostSetting ~= "" then
            visible = visible and ItemMatchesStatBoostQuery(item, statBoostSetting)
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