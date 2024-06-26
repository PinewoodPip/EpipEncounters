
---@class UI.Controller.GameMenu : UI
local GameMenu = {
    BUTTON_IDS = Client.UI.GameMenu.BUTTON_IDS, -- Identical across the 2 UIs.
}
Epip.InitializeUI(Ext.UI.TypeID.gameMenu_c, "GameMenuC", GameMenu, false)
Client.UI.Controller.GameMenu = GameMenu
