
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
           Text = "Multi-select Controls",
           ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
           Handle = "h9582c7b8geff7g40cbg9276g6afac3ab2ee3",
           Text = "If enabled, multi-select controls will be available for the party inventory UI.\n\nUse Ctrl+Click to select/deselect items. If at least one item is selected, Shift+Click will select a range of items.\n\nRight-click selected items to access a context menu with operations, or drag and drop them to inventory slots, player inventory tabs, or container items to move them.",
           ContextDescription = "Setting tooltip",
        },
        InputAction_ToggleSelection_Name = {
            Handle = "h44c561a7g4b32g4e52ga47fg00e32a6f82fc",
            Text = "Toggle Item Selection",
            ContextDescription = "Keybind name",
        },
        InputAction_ToggleSelection_Description = {
            Handle = "h8af4098fga9b6g4981g8338g8c4008d54f8a",
            Text = "Toggles multi-select on the hovered item, if 'Multi-select controls' are enabled.",
            ContextDescription = "Keybind description",
        },
        InputAction_SelectRange_Name = {
            Handle = "h6b5b9ed9g85f0g421bga071g409b1e4491ca",
            Text = "Select Range",
            ContextDescription = "Keybind name",
        },
        InputAction_SelectRange_Description = {
            Handle = "h4a828b3egc70fg4ce9g8d81gd46b307b9366",
            Text = "Selects a range of items starting from the first selected item and ending with the hovered one, if 'Multi-Select controls' are enabled and at least one item is selected.",
            ContextDescription = "Keybind description",
        },
    },
    Settings = {},

    ---@class Features.InventoryMultiSelect.Events
    Events = {
        MultiDragStarted = {}, ---@type Event<Empty> Client-only.
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
