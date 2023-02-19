
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
}
Epip.RegisterFeature("GreatforgeDragDrop", GreatforgeDragDrop)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EpipEncounters_Feature_GreatforgeDragDrop_RequestBench : NetLib_Message_Item, NetLib_Message_Character