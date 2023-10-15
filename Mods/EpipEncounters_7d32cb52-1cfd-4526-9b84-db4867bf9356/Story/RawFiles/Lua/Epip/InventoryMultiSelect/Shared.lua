
---------------------------------------------
-- Implements multi-select for inventory-like UIs.
---------------------------------------------

---@class Features.InventoryMultiSelect : Feature
local MultiSelect = {
    NETMSG_SEND_TO_CONTAINER = "Features.InventoryMultiSelect.NetMsg.SendToContainer",
    NETMSG_SEND_TO_CHARACTER = "Features.InventoryMultiSelect.NetMsg.SendToCharacter",

    TranslatedStrings = {
        Setting_Enabled_Name = {
           Handle = "he2f705dbg1127g4f97gaceeg1dc7e9de1129",
           Text = "Multi-select controls",
           ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
           Handle = "h9582c7b8geff7g40cbg9276g6afac3ab2ee3",
           Text = "If enabled, multi-select controls will be available for the party inventory UI.\n\nUse Ctrl+Click to select/deselect items. If at least one item is selected, Shift+Click will select a range of items.\n\nRight-click selected items to access a context menu with operations, or drag and drop them to inventory slots, player inventory tabs, or container items to move them.",
           ContextDescription = "Setting tooltip",
        },
    },
    Settings = {},

    ---@class Features.InventoryMultiSelect.Events
    Events = {
        MultiDragStarted = {}, ---@type Event<EmptyEvent> Client-only.
        MultiDragEnded = {}, ---@type Event<Features.InventoryMultiSelect.Events.MultiDragEnded> Client-only. Prevent propagation if handled.
    },
    ---@class Features.InventoryMultiSelect.Hooks
    Hooks = {},

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

---@class Features.InventoryMultiSelect.NetMsg.SendToCharacter : NetMessage
---@field ItemNetIDs NetId[]
---@field CharacterNetID NetId

---------------------------------------------
-- SETTINGS
---------------------------------------------

MultiSelect.Settings.Enabled = MultiSelect:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = MultiSelect.TranslatedStrings.Setting_Enabled_Name,
    Description = MultiSelect.TranslatedStrings.Setting_Enabled_Description,
    Context = "Client",
    DefaultValue = false,
})