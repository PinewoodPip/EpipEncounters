
---@class GameMenuUI : UI
local Menu = {
    ---@enum UI.GameMenu.ButtonID
    BUTTON_IDS = {
        RESUME = 0,
        FORMATION = 1,
        PARTY_FORMATION = 2,
        INVITE_PLAYERS = 3,
        WAYPOINTS = 4,
        SAVE = 5,
        LOAD = 8,
        OPTIONS = 10,
        MAIN_MENU = 12,
        QUIT_GAME = 14,
        CONNECTIVITY = 15,
        QUICK_SAVE = 16,
        QUICK_LOAD = 17,
        GM_EDIT_CAMPAIGN_METADATA = 18,
        GM_SAVE_CAMPAIGN = 19,
        GM_SAVE_CAMPAIGN_AS = 20,
        GM_RELOAD_ASSETS = 21,
        GM_PARTY_REROLL = 22,
        GIFT_BAGS = 24,
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        Opened = {}, ---@type Event<Empty>
        ButtonPressed = {}, ---@type Event<GameMenuUI_Event_ButtonPressed>
    },
}
Epip.InitializeUI(Ext.UI.TypeID.gameMenu, "GameMenu", Menu)
Menu:Debug()

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class GameMenuButton
---@field ID integer
---@field Label string
---@field Enabled boolean

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GameMenuUI_Event_ButtonPressed
---@field NumID integer

---------------------------------------------
-- METHODS
---------------------------------------------

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

Menu:RegisterInvokeListener("addMenuButton", function (_, id, name, enabled)
    Menu:FireEvent("ButtonAdded", id, name, enabled)
    if Menu:IsDebug() and not table.reverseLookup(Menu.BUTTON_IDS, id) then
        Menu:__LogWarning("Unmapped button ID:", id, name)
    end
end)

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
    else
        Menu.Events.Opened:Throw()
    end
end)

Menu:RegisterCallListener("buttonPressed", function(ev)
    local buttonID = ev.Args[1]
    Menu:DebugLog("Button pressed: " .. buttonID)

    Menu:FireEvent("ButtonPressed", buttonID)

    Menu.Events.ButtonPressed:Throw({
        NumID = buttonID,
    })
end)
