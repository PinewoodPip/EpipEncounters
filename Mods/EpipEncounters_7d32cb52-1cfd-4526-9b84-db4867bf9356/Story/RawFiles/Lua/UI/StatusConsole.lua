
---------------------------------------------
-- Hooks for the StatusConsole UI (the healthbar above the hotbar)
---------------------------------------------

Client.UI.StatusConsole = {
    UI = nil,
    Root = nil,

    ---------------------------------------------
    -- INTERNAL VARIABLES - DO NOT SET
    ---------------------------------------------
    UITypeID = Client.UI.Data.UITypes.statusConsole,
    visible = true,
    modulesRequestingHide = {},
}
local StatusConsole = Client.UI.StatusConsole
Epip.InitializeUI(Client.UI.Data.UITypes.statusConsole, "StatsConsole", StatusConsole)

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

---------------------------------------------
-- LISTENERS
---------------------------------------------

StatusConsole:RegisterCallListener("pipMaxAPUpdated", function(ev, amount)
    local root = ev.UI:GetRoot()
    local apHolder = root.console_mc.ap_mc
    local list = apHolder.dividerList
    local listWidth = amount * 22

    list.EL_SPACING = -10
    list.x = -14.5
    list.y = -2
    list.positionElements()

    apHolder.x = (-7) - (listWidth / 2)
    apHolder.y = -92 + 6
end)

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

    Client.UI.Hotbar:RegisterListener("Refreshed", function(barAmount)
        StatusConsole.Root.y = -55 * (barAmount - 1)
    end)
end)