
---------------------------------------------
-- Implements multi-select for inventory-like UIs.
---------------------------------------------

---@class Features.InventoryMultiSelect : Feature
local MultiSelect = {
    NETMSG_SEND_TO_CONTAINER = "Features.InventoryMultiSelect.NetMsg.SendToContainer",

    TranslatedStrings = {},
    Events = {
        MultiDragStarted = {}, ---@type Event<EmptyEvent> Client-only.
        MultiDragEnded = {}, ---@type Event<Features.InventoryMultiSelect.Events.MultiDragEnded> Client-only. Prevent propagation if handled.
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
}
Epip.RegisterFeature("InventoryMultiSelect", MultiSelect)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Client-only. Prevent propagation if handled.
---@class Features.InventoryMultiSelect.Events.MultiDragEnded
---@field Selections table<ComponentHandle, Features.InventoryMultiSelect.Selection>
---@field OrderedSelections Features.InventoryMultiSelect.Selection[]

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.InventoryMultiSelect.NetMsg.SendToContainer : NetMessage
---@field ItemNetIDs NetId[]
---@field TargetContainerNetID NetId