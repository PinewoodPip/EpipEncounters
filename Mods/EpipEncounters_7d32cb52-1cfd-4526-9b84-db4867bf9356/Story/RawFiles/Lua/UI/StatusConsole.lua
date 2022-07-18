
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
    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/statusConsole.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/statusConsole_rewritten.swf",
    },
}
if IS_IMPROVED_HOTBAR then
    Client.UI.StatusConsole.FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/statusConsole.swf"] = "Public/ImprovedHotbar_53cdc613-9d32-4b1d-adaa-fd97c4cef22c/GUI/statusConsole_rewritten.swf",
    }
end
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

---Updates position based on hotbar bar count.
function StatusConsole.UpdatePosition()
    StatusConsole:GetRoot().y = -55 * (Client.UI.Hotbar.GetBarCount() - 1)
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

StatusConsole:RegisterCallListener("pipMaxAPUpdated", function(ev, amount)
    amount = math.min(amount, 21)
    local root = ev.UI:GetRoot()
    local apHolder = root.console_mc.ap_mc
    local list = apHolder.dividerList
    local listWidth = amount * 22

    list.EL_SPACING = -10
    list.x = -14.5
    list.y = -2
    list.positionElements()

    if IS_IMPROVED_HOTBAR then -- TODO
        list.visible = false
    end

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
    apHolder.apOverflow_mc.visible = amount > 0
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

    Client.UI.Hotbar:RegisterListener("Refreshed", function(_)
        StatusConsole.UpdatePosition()
    end)
end)