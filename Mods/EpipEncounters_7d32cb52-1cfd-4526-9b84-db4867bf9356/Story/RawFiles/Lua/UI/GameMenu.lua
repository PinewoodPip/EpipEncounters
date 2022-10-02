
---@class GameMenuUI : UI
local Menu = {
    BUTTON_IDS = {
        RESUME = 0,
        FORMATION = 1,
        WAYPOINTS = 2,
        INVITE_PLAYERS = 3,
        WAYPOINTS = 4,
        SAVE = 5,
        LOAD = 8,
        OPTIONS = 10,
        MAIN_MENU = 12,
        CONNECTIVITY = 15,
        GIFT_BAGS = 24,
    }
}
Epip.InitializeUI(Client.UI.Data.UITypes.gameMenu, "GameMenu", Menu)
Menu:Debug()

---@class GameMenuButton
---@field ID integer
---@field Label string
---@field Enabled boolean

---Returns whether the pause menu can be opened. Hookable.
---@return boolean
function Menu.CanOpen()
    local canOpen = true

    canOpen = Menu:ReturnFromHooks("CanOpen", canOpen)

    return canOpen
end

---Render a button onto the UI.
---@param button GameMenuButton
function Menu.RenderButton(button)
    local shouldRender = Menu:ReturnFromHooks("ShouldRenderButton", true, button)

    button.Enabled = Menu:ReturnFromHooks("IsButtonEnabled", button.Enabled, button)

    if shouldRender then
        local root = Menu:GetRoot()

        root.addMenuButton(button.ID, button.Label, button.Enabled)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

local function OnGameMenuButtonAdd(ui, method, id, name, enabled)
    Menu:FireEvent("ButtonAdded", id, name, enabled)
end

-- Intercept vanilla button requests - TODO
-- Menu:RegisterInvokeListener("addMenuButton", function(ev)
--     Menu.RenderButton({
--         ID = ev.Args[1],
--         Label = ev.Args[2],
--         Enabled = ev.Args[3],
--     })

--     ev:PreventAction()
-- end)

-- Prevent opening the menu if any listeners demand so.
Menu:RegisterInvokeListener("openMenu", function(ev)
    local canOpen = Menu.CanOpen()

    if not canOpen then
        ev:PreventAction()
        ev.UI:Hide()
    end
end)

Menu:RegisterCallListener("buttonPressed", function(ev)
    local buttonID = ev.Args[1]
    Menu:DebugLog("Button pressed: " .. buttonID)

    Menu:FireEvent("ButtonPressed", buttonID)
end)

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function()
    Ext.RegisterUIInvokeListener(Menu:GetUI(), "addMenuButton", OnGameMenuButtonAdd)
end)