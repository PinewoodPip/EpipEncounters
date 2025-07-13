
---@class Features.QuickLoot : Feature
local QuickLoot = {
    NETMSG_PICKUP_ITEM = "Features.QuickLoot.NetMsgs.PickUp",
    NETMSG_GENERATE_TREASURE = "Features.QuickLoot.NetMsgs.GenerateTreasure",
    NETMSG_TREASURE_GENERATED = "Features.QuickLoot.NetMsgs.TreasureGenerated", -- Empty message.

    MAX_SEARCH_DISTANCE = 10, -- In meters.
    SEARCH_BASE_RADIUS = 1, -- In meters.
    GROUND_ITEM_PICKUP_EFFECT = "RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_01", -- A bit big and loud, but oh well.

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
            Text = [[Quick Loot is a feature that allows you to loot nearby containers and corpses from a unified UI. Access it by holding down its "Start Search" keybind.]],
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
        Label_OnGround = {
            Handle = "hecfea8f8g6674g4e1dg86b6g5ae65b73e3ba",
            Text = "On the ground.",
            ContextDescription = [[Tooltip for source of items laying on the ground]],
        },
        Label_LootingHint = {
            Handle = "h6b8490dcg409dg47c7gb49bg76989ace163f",
            Text = "Left-click to loot, right-click to loot as wares.",
            ContextDescription = [[Tooltip hint for items within the UI]],
        },
        Tooltip_LootAll = {
            Handle = "h8b644327gb5dag4a16ga237g8208c5db6f32",
            Text = "%s<br>Right-click to loot all items as wares.",
            ContextDescription = [[Tooltip for "Loot All" button. Param is keybind for the loot all action]],
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
        Notification_DidNotLootAll = {
            Handle = "h181532ebg36b3g426bg93e8gcadaeaf5f379",
            Text = "Not all items could be picked up.",
            ContextDescription = [[Warning when "loot all" doesn't complete fully]],
        },
        Label_CannotPickup_TooHeavy = {
            Handle = "h269e54a6g62f9g47afg8e22g52e0dd69a807",
            Text = "Picking up this item would overencumber you.",
            ContextDescription = [[Warning for items that are too heavy]],
        },
        Setting_FilterMode_Name = {
            Handle = "h27133569gae70g4950g968ag09472626efb7",
            Text = "Filter Mode",
            ContextDescription = [[Setting name]],
        },
        Setting_FilterMode_Description = {
            Handle = "ha9cb323cgaba1g42ddg9710g6b10d180a1cf",
            Text = "Determines how items filtered-out by other settings are treated.<br>- Hide items: filtered-out items are not shown in the UI.<br>- Grey out items: filtered-out items are shown greyed-out and moved to the end of the list.",
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
        Setting_ShowBooks_Name = {
            Handle = "h462927ecg6518g490bg8ec3gcb0a1f42f5cf",
            Text = "Show books",
            ContextDescription = [[Setting name]],
        },
        Setting_ShowBooks_Description = {
            Handle = "he5aa70fbg87fag4679gae29g7b8efc22f2f7",
            Text = "If enabled, books and other readable items will be included.",
            ContextDescription = [[Setting tooltip for "Show books"]],
        },
        Setting_ShowClutter_Name = {
            Handle = "h3dbd2ed3gf0efg4cacgb22fg727c434bb1f3",
            Text = "Show clutter",
            ContextDescription = [[Setting name]],
        },
        Setting_ShowClutter_Description = {
            Handle = "ha874d82cg830bg4658gbb16g7772fc94ea62",
            Text = "If enabled, items with no interactions nor crafting use will be included.",
            ContextDescription = [[Setting tooltip for "Show clutter]],
        },
        Setting_ShowGroundItems_Name = {
            Handle = "h481467e2g1b90g4f83ga5d9gc2b8e62f601f",
            Text = "Show ground items",
            ContextDescription = [[Setting name]],
        },
        Setting_ShowGroundItems_Description = {
            Handle = "h97731ba3geb7dg475agb3d2gcf173d6152b6",
            Text = "If enabled, items on the ground will be included, except containers themselves.",
            ContextDescription = [[Setting tooltip for "Include ground items"]],
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
        Setting_LootingEffect_Name = {
            Handle = "hac9dbcaeg3c55g4dedg96ccgb29dab55fde6",
            Text = "Looting GFX",
            ContextDescription = [[Setting name]],
        },
        Setting_LootingEffect_Description = {
            Handle = "h6b9c0d7fg3955g424bg847eg7b2201275db0",
            Text = "If enabled, a beam effect will play while looting items, visualizing the container or corpse they are being taken from.",
            ContextDescription = [[Setting tooltip for "Looting GFX"]],
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
        IsGroundItemLootable = {Context = "Client"}, ---@type Hook<Features.QuickLoot.Hooks.IsGroundItemLootable>
        IsItemFilteredOut = {Context = "Client"}, ---@type Hook<Features.QuickLoot.Hooks.IsItemFilteredOut>
        CanPickupItem = {Context = "Client"}, ---@type Hook<Features.QuickLoot.Hooks.CanPickupItem>
        CanSearch = {Context = "Client"}, ---@type Hook<{Character:EclCharacter, CanSearch:boolean}>
    },
}
Epip.RegisterFeature("Features.QuickLoot", QuickLoot)
local TSK = QuickLoot.TranslatedStrings

-- UI-only; does not affect filtering logic.
QuickLoot.Settings.FilterMode = QuickLoot:RegisterSetting("FilterMode", {
    Type = "Choice",
    Context = "Client",
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
    Context = "Client",
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
    Context = "Client",
    Name = TSK.Setting_ShowConsumables_Name,
    Description = TSK.Setting_ShowConsumables_Description,
    DefaultValue = true,
})
QuickLoot.Settings.ShowFoodAndDrinks = QuickLoot:RegisterSetting("ShowFoodAndDrinks", {
    Type = "Boolean",
    Context = "Client",
    Name = TSK.Setting_ShowFoodAndDrinks_Name,
    Description = TSK.Setting_ShowFoodAndDrinks_Description,
    DefaultValue = true,
})
QuickLoot.Settings.ShowIngredients = QuickLoot:RegisterSetting("ShowIngredients", {
    Type = "Boolean",
    Context = "Client",
    Name = TSK.Setting_ShowIngredients_Name,
    Description = TSK.Setting_ShowIngredients_Description,
    DefaultValue = true,
})
QuickLoot.Settings.ShowBooks = QuickLoot:RegisterSetting("ShowBooks", {
    Type = "Boolean",
    Context = "Client",
    Name = TSK.Setting_ShowBooks_Name,
    Description = TSK.Setting_ShowBooks_Description,
    DefaultValue = true,
})
QuickLoot.Settings.ShowClutter = QuickLoot:RegisterSetting("ShowClutter", {
    Type = "Boolean",
    Context = "Client",
    Name = TSK.Setting_ShowClutter_Name,
    Description = TSK.Setting_ShowClutter_Description,
    DefaultValue = true,
})
QuickLoot.Settings.ShowGroundItems = QuickLoot:RegisterSetting("ShowGroundItems", {
    Type = "Boolean",
    Context = "Client",
    Name = TSK.Setting_ShowGroundItems_Name,
    Description = TSK.Setting_ShowGroundItems_Description,
    DefaultValue = false,
})
QuickLoot.Settings.BaseRadius = QuickLoot:RegisterSetting("BaseRadius", {
    Type = "ClampedNumber",
    Context = "Client",
    Name = TSK.Setting_BaseRadius_Name,
    Description = TSK.Setting_BaseRadius_Description,
    Min = 1,
    Max = QuickLoot.MAX_SEARCH_DISTANCE,
    Step = 1,
    HideNumbers = false,
    DefaultValue = QuickLoot.SEARCH_BASE_RADIUS,
})
QuickLoot.Settings.LootingEffect = QuickLoot:RegisterSetting("LootingEffect", {
    Type = "Boolean",
    Context = "Client",
    Name = TSK.Setting_LootingEffect_Name,
    Description = TSK.Setting_LootingEffect_Description,
    DefaultValue = false,
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
---@field Position vec3 Origin of the request.
---@field Lootable boolean Hookable. Defaults to `true`.

---@class Features.QuickLoot.Hooks.IsGroundItemLootable
---@field Item EclItem
---@field RequestPosition vec3 Origin of the request.
---@field Lootable boolean Hookable. Defaults to whether the item is not a container.

---@class Features.QuickLoot.Hooks.IsItemFilteredOut
---@field Item EclItem
---@field FilteredOut boolean Hookable. Defaults to `false`.

---@class Features.QuickLoot.Hooks.CanPickupItem
---@field Character EclCharacter
---@field Item EclItem
---@field CanPickup boolean Defaults to `true`.

---@class Features.QuickLoot.Hooks.CanSearch
---@field Character EclCharacter
---@field CanSearch boolean Hookable. Defaults to whether the character currently has no search ongoing.

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.QuickLoot.NetMsgs.PickUp : NetLib_Message_Character, NetLib_Message_Item
---@field PlayLootingEffect boolean
---@field AddToWares boolean

---@class Features.QuickLoot.NetMsgs.GenerateTreasure : NetLib_Message_Character
---@field ItemNetIDs NetId[]

---@class Features.QuickLoot.NetMsgs.TreasureGenerated : NetLib_Message
---@field GeneratedContainerNetIDs table<NetId, integer> Maps container to expected amount of items.
