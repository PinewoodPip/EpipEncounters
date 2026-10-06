
---@class UI.ConnectionMenu : UI
local ConnectionMenu = {
    STATE_IDS = {
        ANYBODY = 0,
        FRIENDS_ONLY = 1,
        INVITE_ONLY = 2,
        LOCAL = 3,
    },
    CHECKBOX_IDS = {
        LAN = 0,
        DIRECT_CONNECT = 1,
    },
}
Epip.InitializeUI(Ext.UI.TypeID.connectionMenu, "ConnectionMenu", ConnectionMenu)
