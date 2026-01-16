
---------------------------------------------
-- Hooks for the StatusConsole UI (the healthbar above the hotbar)
---------------------------------------------

---@class StatusConsoleUI : UI
local StatusConsole = {
    ---@enum UI.StatusConsole.TurnNotificationType
    TURN_NOTIFICATION_TYPES = {
        NEUTRAL_TURN = 0,
        YOUR_TURN = 1,
        UNKNOWN = 2, -- Also a player-related one.
        ALLIED_TURN = 3,
        ENEMY_TURN = 4,
    },

    -- IDs of buttons by the health bar.
    BUTTON_IDS = {
        END_TURN = 0,
        DELAY_TURN = 1,
        FLEE = 2,
        TO_GM = 3, -- "To game master" button.
    },

    visible = true,
    modulesRequestingHide = {},

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        TurnEnded = {}, ---@type PreventableEvent<StatusConsoleUI_Event_TurnEnded>
    },

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/statusConsole.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/statusConsole.swf",
    },
}
Epip.InitializeUI(Ext.UI.TypeID.statusConsole, "StatusConsole", StatusConsole)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class StatusConsoleUI_Event_TurnEnded : PreventableEventParams
---@field Character EclCharacter

---------------------------------------------
-- METHODS
---------------------------------------------

function StatusConsole.Toggle(visible, requestID)
    if not requestID then
        StatusConsole:__LogWarning("Toggle() must be passed a request ID to track when the UI should be turned back on in case of multiple sources hiding it.")
        return nil
    end

    -- Never show StatusConsole in Character Creation
    if Client.UI.CharacterCreation.IsInCharacterCreation() then
        StatusConsole.UI:Hide()
        StatusConsole.visible = false
    else
        if not visible then
            StatusConsole.modulesRequestingHide[requestID] = true
        else
            StatusConsole.modulesRequestingHide[requestID] = nil
        end

        local newState = StatusConsole.ShouldBeVisible()

        -- don't do anything if there is no state change - otherwise chaos ensues as the engine tries to refresh hotbar, etc..
        if newState == StatusConsole.Root.visible then return nil end

        StatusConsole.Root.visible = newState
        StatusConsole.visible = newState

        if newState then
            StatusConsole.UI:Show()
        else
            StatusConsole.UI:Hide()
        end
    end
end

-- Returns false if any module is requesting the UI to remain hidden.
-- Meaning hide requests take priority over showing.
function StatusConsole.ShouldBeVisible()
    return next(StatusConsole.modulesRequestingHide) == nil
end

---Updates position based on hotbar bar count.
function StatusConsole.UpdatePosition()
    local ui = StatusConsole:GetUI()
    local root = StatusConsole:GetRoot()
    local scaleMultiplier = ui:GetUIScaleMultiplier()
    local extraBars = Client.UI.Hotbar.GetBarCount() - 1
    local hotbarRowHeight = 57
    local offset = extraBars > 0 and -2 or 0

    root.y = -hotbarRowHeight * (extraBars) - offset

    -- If UIScaling (the global switch only!) is not 1, the UIObject position on the Y axis is not 0; we need to compensate for this.
    if Ext.Utils.GetGlobalSwitches().UIScaling > 1 then
        root.y = StatusConsole:GetRoot().y + (ui:GetPosition()[2] / scaleMultiplier)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for turn being ended.
-- This is invoked by a key press as well, from onEventUp.
StatusConsole:RegisterCallListener("EndButtonPressed", function (ev)
    local event = StatusConsole.Events.TurnEnded:Throw({
        Character = Client.GetCharacter(),
    })

    if event.Prevented then
        ev:PreventAction()
    end
end)

StatusConsole:RegisterInvokeListener("setSourcePoints", function(ev, available)
    local max = 0
    local char = Client.GetCharacter()
    local root = StatusConsole:GetRoot()
    local list = root.sourcePointList

    available, max = Character.GetSourcePoints(char)

    ev.UI:GetRoot().pipSetSourcePoints(max, available)

    list.x = root.console_mc.x + 6
    list.y = root.console_mc.y - 13

    list.EL_SPACING = 5
    list.positionElements()

    -- IDK why .width doesn't work here
    list.x = list.x - ((15 * max + (max - 2) * 5) // 2)
end, "After")

---@diagnostic disable-next-line: unused-local
local function OnHealthBarUpdate(uiObj, method, param3, num1, str1, bool1)
    local root = uiObj:GetRoot()
    local char = Ext.GetCharacter(uiObj:GetPlayerHandle())

    root.console_mc.abTxt_mc.htmlText = char.Stats.CurrentArmor .. "/" .. char.Stats.MaxArmor
    root.console_mc.mabTxt_mc.htmlText = char.Stats.CurrentMagicArmor .. "/" .. char.Stats.MaxMagicArmor

    root.console_mc.abTxt_mc.visible = true
    root.console_mc.mabTxt_mc.visible = true
    root.console_mc.hbTxt_mc.visible = true

    StatusConsole.Toggle(true, "VanillaBehaviour")
end

---------------------------------------------
-- SETUP
---------------------------------------------
Ext.Events.SessionLoaded:Subscribe(function()
    if Client.IsUsingController() then return end
    StatusConsole.UI = Ext.UI.GetByType(Ext.UI.TypeID.statusConsole)
    StatusConsole.Root = StatusConsole.UI:GetRoot()

    StatusConsole.Root.originalNotificationPosY = 3000

    Ext.RegisterUICall(StatusConsole.UI, "pipStatusConsoleHealthUpdate", OnHealthBarUpdate)
    Ext.RegisterUICall(StatusConsole.UI, "pipStatusConsoleArmorUpdate", OnHealthBarUpdate)

    -- Update the position of the UI whenever the hotbar or viewport is updated.
    Client.UI.Hotbar:RegisterListener("Refreshed", function(_)
        StatusConsole.UpdatePosition()
    end)
    Client.Events.ViewportChanged:Subscribe(function (_)
        -- Needs to be a TickTimer of 1 rather than OnNextTick() - TODO where does the timing difference come from?
        Timer.StartTickTimer(1, function (_)
            StatusConsole.UpdatePosition()
        end)
    end)
end)