
---@class Features.QuickLoot : Feature
local QuickLoot = {
    NETMSG_PICKUP_ITEM = "Features.QuickLoot.NetMsgs.PickUp",
    NETMSG_GENERATE_TREASURE = "Features.QuickLoot.NetMsgs.GenerateTreasure",
    NETMSG_TREASURE_GENERATED = "Features.QuickLoot.NetMsgs.TreasureGenerated", -- Empty message.

    TranslatedStrings = {
        Label_FeatureName = {
            Handle = "hf0cdc4a1g6e7bg41c6ga408g9bd330ecae22",
            Text = "Quick Loot",
            ContextDescription = [[UI header]],
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
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        SearchCompleted = {Context = "Client"}, ---@type Event<Features.QuickLoot.Events.SearchCompleted>
    },
    Hooks = {
        IsContainerLootable = {Context = "Client"}, ---@type Hook<Features.QuickLoot.Hooks.IsContainerLootable>
    },
}
Epip.RegisterFeature("Features.QuickLoot", QuickLoot)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.QuickLoot.Events.SearchCompleted
---@field Character EclCharacter
---@field Radius number In meters.
---@field LootableItems EclItem[]
---@field Containers EclItem[]
---@field Corpses EclCharacter[]
---@field HandleMaps Features.QuickLoot.HandleMap

---@class Features.QuickLoot.Hooks.IsContainerLootable
---@field Container EclItem
---@field Lootable boolean Hookable. Defaults to `true`.

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.QuickLoot.NetMsgs.PickUp : NetLib_Message_Character, NetLib_Message_Item

---@class Features.QuickLoot.NetMsgs.GenerateTreasure : NetLib_Message_Character
---@field ItemNetIDs NetId[]
