
---@class UI.Controller.ContextMenu : UI
local ContextMenu = {
    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        Opened = {}, ---@type Event<Empty>
    },
}
Epip.InitializeUI(Ext.UI.TypeID.contextMenu_c.Object, "ContextMenuC", ContextMenu, false)
Client.UI.Controller.ContextMenu = ContextMenu

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the menu being opened.
ContextMenu:RegisterInvokeListener("open", function (_)
    ContextMenu.Events.Opened:Throw()
end)
