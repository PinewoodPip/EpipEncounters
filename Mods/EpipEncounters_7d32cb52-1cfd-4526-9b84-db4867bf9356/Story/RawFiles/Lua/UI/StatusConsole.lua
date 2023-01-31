
---------------------------------------------
-- Hooks for the StatusConsole UI (the healthbar above the hotbar)
---------------------------------------------

---@class StatusConsoleUI : UI
local StatusConsole = {
    UI = nil,
    Root = nil,
    
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
        Utilities.LogWarning("StatusConsole", "Toggle() must be passed a request ID to track when the UI should be turned back on in case of multiple sources hiding it.")
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
            StatusConsole.modulesRequestingHide[requestID] = false
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
    for module,status in pairs(StatusConsole.modulesRequestingHide) do
        if status then
            return false
        end
    end
    return true
end

---Updates position based on hotbar bar count.
function StatusConsole.UpdatePosition()
    StatusConsole:GetRoot().y = -55 * (Client.UI.Hotbar.GetBarCount() - 1)
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

StatusConsole:RegisterCallListener("pipMaxAPUpdated", function(ev, amount)
    amount = math.min(amount, 21)
    local character = Client.GetCharacter()
    local root = ev.UI:GetRoot()
    local apHolder = root.console_mc.ap_mc
    local list = apHolder.dividerList
    local listWidth = amount * 22

    list.EL_SPACING = -10
    list.x = -14.5
    list.y = -2
    list.positionElements()

    apHolder.x = (-7) - math.floor(listWidth / 2)
    apHolder.y = -92 + 6

    local apList = apHolder.apList
    local extraX = 0
    local SPACING = 2
    local SPACING_AFTER_DIVIDER = 1

    apList.positionElements()

    for i=0,#apList.content_array-1,1 do
        if i % 4 == 0 and i > 0 then
            extraX = extraX + SPACING 
        end

        local orb = apList.content_array[i]
        local divider = list.content_array[i]

        divider.x = divider.x + extraX
        if i % 4 == 0 and i > 0 then
            extraX = extraX + SPACING + SPACING_AFTER_DIVIDER
        end
        orb.x = orb.x + extraX

        if i == #apList.content_array-1 then
            divider = list.content_array[i + 1]
            divider.x = divider.x + extraX
        end

    end
    apHolder.x = apHolder.x - extraX // 2
    apHolder.apGlow_mc.visible = false
    apHolder.apOverflow_mc.x = 503
    apHolder.apOverflow_mc.y = -7
    apHolder.apOverflow_mc.overflow_txt.x = -15
    apHolder.apOverflow_mc.visible = character and character.Stats.CurrentAP > 20

    local shadowList = apHolder.shadowList
    shadowList.positionElements()
    shadowList.x = -7
    shadowList.y = -13
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

local function OnHealthBarUpdate(uiObj, method, param3, num1, str1, bool1)
    local root = uiObj:GetRoot()
    local char = Ext.GetCharacter(uiObj:GetPlayerHandle())

    root.console_mc.abTxt_mc.htmlText = char.Stats.CurrentArmor .. "/" .. char.Stats.MaxArmor
    root.console_mc.mabTxt_mc.htmlText = char.Stats.CurrentMagicArmor .. "/" .. char.Stats.MaxMagicArmor

    root.console_mc.abTxt_mc.visible = true
    root.console_mc.mabTxt_mc.visible = true
    root.console_mc.hbTxt_mc.visible = true

    root.turnNotice_mc.visible = false -- todo fix properly. we might be using an outdated version of the swf?
    root.turnNotice_mc.x = 8000

    StatusConsole.Toggle(true, "VanillaBehaviour")

end

---------------------------------------------
-- SETUP
---------------------------------------------
Ext.Events.SessionLoaded:Subscribe(function()
    StatusConsole.UI = Ext.UI.GetByType(Client.UI.Data.UITypes.statusConsole)
    StatusConsole.Root = StatusConsole.UI:GetRoot()

    StatusConsole.Root.originalNotificationPosY = 3000

    Ext.RegisterUICall(StatusConsole.UI, "pipStatusConsoleHealthUpdate", OnHealthBarUpdate)
    Ext.RegisterUICall(StatusConsole.UI, "pipStatusConsoleArmorUpdate", OnHealthBarUpdate)

    Client.UI.Hotbar:RegisterListener("Refreshed", function(_)
        StatusConsole.UpdatePosition()
    end)
end)