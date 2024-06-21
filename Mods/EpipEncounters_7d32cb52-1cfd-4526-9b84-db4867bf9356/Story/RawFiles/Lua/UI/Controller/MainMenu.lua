
---------------------------------------------
-- UI used for both the main menu as well as the options tab selection in-session.
---------------------------------------------

---@class UI.Controller.MainMenu : UI
local Menu = {
    OPTIONS_BUTTON_IDS = {
        VIDEO = 1,
        AUDIO = 2,
        CONTROLS = 3,
        GAME = 4,
    }
}
Epip.InitializeUI(Ext.UI.TypeID.mainMenu_c, "MainMenuC", Menu)
Client.UI.Controller.MainMenu = Menu

---------------------------------------------
-- METHODS
---------------------------------------------

---Adds a button to the list.
---@param id integer
---@param label TextLib.String
---@param enabled boolean? Defaults to `true`.
function Menu.AddButton(id, label, enabled)
    if enabled == nil then enabled = true end
    local root = Menu:GetRoot()
    root.addMenuButton(id, Text.Resolve(label), "", enabled) -- Description param appears to be unused; likely result of copy-pasting parts of the UI from the KB+M version.
end

---@override
function Menu:GetUI()
    local ui = nil
    -- There appear to be multiple instances of this UI at times. 
    for _,otherUI in pairs(Ext.UI.GetUIObjectManager().UIObjects) do
        if otherUI:GetTypeId() == Ext.UI.TypeID.mainMenu_c then
            -- Prioritize fetching the visible one.
            if not ui or otherUI.OF_Visible then
                ui = otherUI
            end
        end
    end
    return ui
end
