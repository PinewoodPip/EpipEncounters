
---------------------------------------------
-- Makes Region transition notifications's duration configurable, or lets you disable them entirely. Also controls item notifications appearing.
---------------------------------------------

local NotificationUI = Client.UI.Notification

local Notifs = {
    -- Not used.
    -- BEGIN_REGION_Y = 30,
    -- END_REGION_Y = 40,
}
Epip.AddFeature("Notifications", "Notifications", Notifs)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

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
    if not ev.IsScripted and ev.Label:match(" shares ") and not Settings.GetSettingValue("Epip_Notifications", "Notification_StatSharing") then
        ev:Prevent()
    end
end)

-- Set duration of region labels, or hide them immediately.
NotificationUI:RegisterInvokeListener("setRegionText", function(ev)
    local root = ev.UI:GetRoot()
    local label = ev.Args[1]
    local duration = Settings.GetSettingValue("Epip_Notifications", "RegionLabelDuration")

    -- Change Y location of the notification
    -- root.beginRegionY = Notifs.BEGIN_REGION_Y
    -- root.endRegionY = Notifs.END_REGION_Y

    root.setRegionText(label, duration)

    -- Hide immediately - we still need to call setRegionText for the UI to not "softlock"
    if duration == 0 then
        root.hideRegionMC()
    end

    ev:PreventAction()
end)

-- Hide region notification immediately when the HP bar is brought up
Client.UI.EnemyHealthBar.Events.Updated:Subscribe(function (_)
    NotificationUI:GetRoot().hideRegionMC()
end)