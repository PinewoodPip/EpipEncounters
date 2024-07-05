
---@class Features.QuickLoot : Feature
local QuickLoot = {
    NETMSG_PICKUP_ITEM = "Features.QuickLoot.NetMsgs.PickUp",
    NETMSG_GENERATE_TREASURE = "Features.QuickLoot.NetMsgs.GenerateTreasure",
    NETMSG_TREASURE_GENERATED = "Features.QuickLoot.NetMsgs.TreasureGenerated", -- Empty message.

    MAX_SEARCH_DISTANCE = 10, -- In meters.
    SEARCH_BASE_RADIUS = 1, -- In meters.

    SETTING_FILTERMODE_CHOICES = {
        HIDDEN = "Hidden",
        GREYED_OUT = "GreyedOut",
    },

    TranslatedStrings = {
        Label_FeatureName = {
            Handle = "hf0cdc4a1g6e7bg41c6ga408g9bd330ecae22",
            Text = "Quick Loot",
            ContextDescription = [[UI header]],
        },
        Label_FeatureDescription = {
            Handle = "h0547ce79g8094g4cb4gb975g81cc0b5c9b6a",
            Text = [[Quick Loot is a feature that allows you to loot nearby containers and corpses from a unified UI. Access it by holding down its "Search" keybind.]],
            ContextDescription = [[Hint in settings menu tab]],
        },
        Label_LootAll = {
            Handle = "h8eb26275gd698g4286gb7a5gaaa099e9aa37",
            Text = "Loot All",
            ContextDescription = [[Button label]],
        },
        Label_SourceContainer = {
            Handle = "h156a7412g4f0fg4483g9977g5341ae987ba1",
            Text = "In %s.",
            ContextDescription = [[Tooltip for source container of an item. Param is item name]],
        },
        Label_SourceCorpse = {
            Handle = "h3833c781g3601g4c0cgb6b0g17863e16b166",
            Text = "In %s's corpse.",
            ContextDescription = [[Tooltip for source corpse of an item. Param is character name]],
        },
        Notification_NoLootNearby = {
            Handle = "h75d9d7f6g8200g43ffg9ef6g10a48ab961a6",
            Text = "No loot found nearby.",
            ContextDescription = [[Notification text]],
        },
        Notification_Searching = {
            Handle = "h8fe098cag9221g4fdbgaec2g392e49012d1a",
            Text = "Searching...",
            ContextDescription = [[Notification when starting to search nearby lootables]],
        },
        Setting_FilterMode_Name = {
            Handle = "h27133569gae70g4950g968ag09472626efb7",
            Text = "Filter Mode",
            ContextDescription = [[Setting name]],
        },
        Setting_FilterMode_Description = {
            Handle = "ha9cb323cgaba1g42ddg9710g6b10d180a1cf",
            Text = "Determines items filtered-out by other settings are treated.<br>- Hide items: filtered-out items are not shown in the UI.<br>- Grey out items: filtered-out items are shown greyed-out and moved to the end of the list.",
            ContextDescription = [[Setting tooltip for "Filter Mode"]],
        },
        Setting_FilterMode_Choice_Hidden = {
            Handle = "h8ce3b6efg058fg476dga263gc226a11d49a2",
            Text = "Hide items",
            ContextDescription = [[Choice for "Filter Mode" setting]],
        },
        Setting_FilterMode_Choice_GreyedOut = {
            Handle = "h39465db7g62c7g4799g902ag39d3eb629f8a",
            Text = "Grey out items",
            ContextDescription = [[Choice for "Filter Mode" setting]],
        },
        Setting_MinEquipmentRarity_Name = {
            Handle = "hb4729dd9g3c8bg4adfg8845g821b99fe6cde",
            Text = "Minimum Rarity",
            ContextDescription = [[Setting name]],
        },
        Setting_MinEquipmentRarity_Description = {
            Handle = "h63dc15c7g9d83g495cg9555g0a3d9a468100",
            Text = "Determines the minimum rarity of equipment to include.",
            ContextDescription = [[Setting tooltip for "Minimum Rarity"]],
        },
        Setting_ShowConsumables_Name = {
            Handle = "h0440532agbdc5g4d55g82b7gbbc128030986",
            Text = "Show potions, scrolls & grenades",
            ContextDescription = [[Setting name]],
        },
        Setting_ShowConsumables_Description = {
            Handle = "h6fd97af9g0c50g41f5gb10ag07874c528116",
            Text = "If enabled, potion, scroll and grenade items will be included.",
            ContextDescription = [[Setting tooltip for "Show potions, scrolls & grenades"]],
        },
        Setting_ShowFoodAndDrinks_Name = {
            Handle = "hc2c9ebc7g4f13g4939g8851g01e9fca8ab4e",
            Text = "Show food & drinks",
            ContextDescription = [[Setting name]],
        },
        Setting_ShowFoodAndDrinks_Description = {
            Handle = "heded2e03g9a95g4567gaa8cg2e226f54865f",
            Text = "If enabled, food and drink items will be included.",
            ContextDescription = [[Setting tooltip for "Show food & drinks"]],
        },
        Setting_ShowIngredients_Name = {
            Handle = "h9b47b2d0gc233g4dbfga7d5g9dfae168e615",
            Text = "Show crafting ingredients",
            ContextDescription = [[Setting name]],
        },
        Setting_ShowIngredients_Description = {
            Handle = "h9bfec1c4g695dg4259gb489g606897bbe8e6",
            Text = "If enabled, crafting ingredients will be included.",
            ContextDescription = [[Setting tooltip for "Show crafting ingredients"]],
        },
        Setting_BaseRadius_Name = {
            Handle = "hdd379f13g9fb6g4195ga02bge51a06d5f44a",
            Text = "Default Radius",
            ContextDescription = [[Setting name]],
        },
        Setting_BaseRadius_Description = {
            Handle = "hb53ca0e9g7d6cg47c3g9747g38e19a343a90",
            Text = "Determines the starting radius of the search area, in meters.",
            ContextDescription = [[Setting tooltip for "Default Radius"]],
        },
        InputAction_Search_Name = {
            Handle = "ha539c465g36e0g4780g9892g58e33578124f",
            Text = "Quick Loot: Start Search",
            ContextDescription = [[Keybind name]],
        },
        InputAction_Search_Description = {
            Handle = "h7222d389g2b3cg40a8gb589gc41902b02ce8",
            Text = "Hold to search nearby containers and corpses to loot.",
            ContextDescription = [[Keybind tooltip]],
        },
    },
    Settings = {},

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
    Events = {
        SearchStarted = {Context = "Client"}, ---@type Event<{Character: EclCharacter}>
        SearchCompleted = {Context = "Client"}, ---@type Event<Features.QuickLoot.Events.SearchCompleted>
    },
    Hooks = {
        IsContainerLootable = {Context = "Client"}, ---@type Hook<Features.QuickLoot.Hooks.IsContainerLootable>
        IsItemFilteredOut = {Context = "Client"}, ---@type Hook<Features.QuickLoot.Hooks.IsItemFilteredOut>
        CanSearch = {Context = "Client"}, ---@type Hook<{Character:EclCharacter, CanSearch:boolean}>
    },
}
Epip.RegisterFeature("Features.QuickLoot", QuickLoot)
local TSK = QuickLoot.TranslatedStrings

-- UI-only; does not affect filtering logic.
QuickLoot.Settings.FilterMode = QuickLoot:RegisterSetting("FilterMode", {
    Type = "Choice",
    Name = TSK.Setting_FilterMode_Name,
    Description = TSK.Setting_FilterMode_Description,
    DefaultValue = QuickLoot.SETTING_FILTERMODE_CHOICES.GREYED_OUT,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = QuickLoot.SETTING_FILTERMODE_CHOICES.HIDDEN, NameHandle = TSK.Setting_FilterMode_Choice_Hidden.Handle},
        {ID = QuickLoot.SETTING_FILTERMODE_CHOICES.GREYED_OUT, NameHandle = TSK.Setting_FilterMode_Choice_GreyedOut.Handle},
    }
})
QuickLoot.Settings.MinEquipmentRarity = QuickLoot:RegisterSetting("MinEquipmentRarity", {
    Type = "Choice",
    Name = TSK.Setting_MinEquipmentRarity_Name,
    Description = TSK.Setting_MinEquipmentRarity_Description,
    DefaultValue = "Common",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Common", NameHandle = Item.RARITY_HANDLES.COMMON},
        {ID = "Uncommon", NameHandle = Item.RARITY_HANDLES.UNCOMMON},
        {ID = "Rare", NameHandle = Item.RARITY_HANDLES.RARE},
        {ID = "Epic", NameHandle = Item.RARITY_HANDLES.EPIC},
        {ID = "Legendary", NameHandle = Item.RARITY_HANDLES.LEGENDARY},
        {ID = "Divine", NameHandle = Item.RARITY_HANDLES.DIVINE},
    }
})
QuickLoot.Settings.ShowConsumables = QuickLoot:RegisterSetting("ShowConsumables", {
    Type = "Boolean",
    Name = TSK.Setting_ShowConsumables_Name,
    Description = TSK.Setting_ShowConsumables_Description,
    DefaultValue = true,
})
QuickLoot.Settings.ShowFoodAndDrinks = QuickLoot:RegisterSetting("ShowFoodAndDrinks", {
    Type = "Boolean",
    Name = TSK.Setting_ShowFoodAndDrinks_Name,
    Description = TSK.Setting_ShowFoodAndDrinks_Description,
    DefaultValue = true,
})
QuickLoot.Settings.ShowIngredients = QuickLoot:RegisterSetting("ShowIngredients", {
    Type = "Boolean",
    Name = TSK.Setting_ShowIngredients_Name,
    Description = TSK.Setting_ShowIngredients_Description,
    DefaultValue = true,
})
QuickLoot.Settings.BaseRadius = QuickLoot:RegisterSetting("BaseRadius", {
    Type = "ClampedNumber",
    Name = TSK.Setting_BaseRadius_Name,
    Description = TSK.Setting_BaseRadius_Description,
    Min = 1,
    Max = QuickLoot.MAX_SEARCH_DISTANCE,
    Step = 1,
    HideNumbers = false,
    DefaultValue = QuickLoot.SEARCH_BASE_RADIUS,
})

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.QuickLoot.Events.SearchCompleted
---@field Character EclCharacter
---@field Radius number In meters.
---@field LootableItems EclItem[] Sorted and with filters applied.
---@field Containers EclItem[]
---@field Corpses EclCharacter[]
---@field HandleMaps Features.QuickLoot.HandleMap

---@class Features.QuickLoot.Hooks.IsContainerLootable
---@field Container EclItem
---@field Lootable boolean Hookable. Defaults to `true`.

---@class Features.QuickLoot.Hooks.IsItemFilteredOut
---@field Item EclItem
---@field FilteredOut boolean Hookable. Defaults to `false`.

---@class Features.QuickLoot.Hooks.CanSearch
---@field Character EclCharacter
---@field CanSearch boolean Hookable. Defaults to whether the character currently has no search ongoing.

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.QuickLoot.NetMsgs.PickUp : NetLib_Message_Character, NetLib_Message_Item

---@class Features.QuickLoot.NetMsgs.GenerateTreasure : NetLib_Message_Character
---@field ItemNetIDs NetId[]
