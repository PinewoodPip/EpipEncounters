
---------------------------------------------
-- Makes Region transition notifications's duration configurable, or lets you disable them entirely. Also controls item and ability shared notifications appearing as well as casting notifications.
---------------------------------------------

local NotificationUI = Client.UI.Notification
local EnemyHealthBar = Client.UI.EnemyHealthBar
local Hotbar = Client.UI.Hotbar

---@type Feature
local Notifs = {
    TSKHANDLE_LOREMASTER_SHARED = "h78e14d0fg27adg462cg9807gf5832c2133bd", -- "[1] shares lore with [2]"
}
Epip.RegisterFeature("Notifications", Notifs)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Move casting notifications to the bottom of the screen,
-- pushing the upwards based on how many hotbar rows are visible.
-- Also disables casting notifications if the setting is disabled.
NotificationUI.Hooks.ShowCastingNotification:Subscribe(function (ev)
    if Settings.GetSettingValue("Epip_Notifications", "CastingNotifications") == true then
        local barCount = Hotbar.GetBarCount()
        
        ev.PositionY = 915 - (barCount) * 65
    else
        ev:Prevent()
    end
end)

-- Hide item receival notifications.
NotificationUI.Hooks.ShowReceivalNotification:Subscribe(function (e)
    local isItemNotification = e.Sound == NotificationUI.SOUNDS.RECEIVE_ABILITY

    if isItemNotification and Settings.GetSettingValue("Epip_Notifications", "Notification_ItemReceival") == false then
        e.Prevent = true
        e:StopPropagation()
    end
end)

-- Hide "X has shared Z stat" notifications.
NotificationUI.Events.TextNotificationShown:Subscribe(function (ev)
    if not ev.IsScripted and Settings.GetSettingValue("Epip_Notifications", "Notification_StatSharing") == false then
        local sharedLabel = Text.GetTranslatedString(Notifs.TSKHANDLE_LOREMASTER_SHARED)

        -- In some languages the character names are not at the start & end;
        -- we must replace them with .- to do a pattern search, rather than merely removing them
        sharedLabel = Text.ReplaceLarianPlaceholders(sharedLabel, ".-")
        sharedLabel = Text.EscapePatternCharacters(sharedLabel) -- Certain languages (ex. Korean) use parenthesis within the string.
        sharedLabel = Text.Replace(sharedLabel, "%.%-", ".-") -- Undo our pattern being escaped

        if ev.Label:find(sharedLabel) then
            ev:Prevent()
        end
    end
end)

-- Set duration of region labels, or hide them immediately.
NotificationUI:RegisterInvokeListener("setRegionText", function(ev)
    local root = ev.UI:GetRoot()
    local label = ev.Args[1]
    local duration = Settings.GetSettingValue("Epip_Notifications", "RegionLabelDuration")

    root.setRegionText(label, duration)

    -- Hide immediately - we still need to call setRegionText for the UI to not "softlock"
    if duration == 0 then
        root.hideRegionMC()
    end

    ev:PreventAction()
end)

-- Hide region notification immediately when the HP bar is brought up
EnemyHealthBar.Events.Updated:Subscribe(function (_)
    NotificationUI:GetRoot().hideRegionMC()
end)