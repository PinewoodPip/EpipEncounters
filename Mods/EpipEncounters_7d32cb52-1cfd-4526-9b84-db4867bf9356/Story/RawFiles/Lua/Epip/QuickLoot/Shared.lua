
---@class Features.QuickLoot : Feature
local QuickLoot = {
    NETMSG_PICKUP_ITEM = "Features.QuickLoot.NetMsgs.PickUp",

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
    }
}
Epip.RegisterFeature("Features.QuickLoot", QuickLoot)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.QuickLoot.NetMsgs.PickUp : NetLib_Message_Character, NetLib_Message_Item
