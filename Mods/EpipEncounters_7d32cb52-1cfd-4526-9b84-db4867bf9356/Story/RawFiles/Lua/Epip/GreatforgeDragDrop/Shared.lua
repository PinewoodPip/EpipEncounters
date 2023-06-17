
---------------------------------------------
-- Allows dragging an item onto the Greatforge socket UI to bench it.
---------------------------------------------

---@class Feature_GreatforgeDragDrop : Feature
local GreatforgeDragDrop = {
    REQUEST_BENCH_NET_MSG = "EpipEncounters_Feature_GreatforgeDragDrop_RequestBench",

    TranslatedStrings = {
        MouseHint = {
           Handle = "heb8e464cg6305g46aeg8fbag240af8560ebe",
           Text = "Release left-click to Greatforge this item.",
           ContextDescription = "Mouse hint for drag-drop",
        },
    },
    SupportedGameStates = _Feature.GAME_STATES.RUNNING_SESSION,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        ItemDropped = {}, ---@type Event<Feature_GreatforgeDragDrop_Event_ItemDropped>
    },
}
Epip.RegisterFeature("GreatforgeDragDrop", GreatforgeDragDrop)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired when a character attemps to insert an item into the Greatforge socket via drag-drop. Does not consider whether the item is Greatforge-compatible.
---**On the client, this is only ever fired for the client character**.
---@class Feature_GreatforgeDragDrop_Event_ItemDropped
---@field Character Character The character that dropped in the item.
---@field Item Item

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EpipEncounters_Feature_GreatforgeDragDrop_RequestBench : NetLib_Message_Item, NetLib_Message_Character