
---------------------------------------------
-- Makes Region transition notifications's duration configurable, or lets you disable them entirely.
---------------------------------------------

local Notifs = {
    -- Not used.
    -- BEGIN_REGION_Y = 30,
    -- END_REGION_Y = 40,
}
Epip.AddFeature("Notifications", "Notifications", Notifs)

local NotificationUI = Client.UI.Notification

NotificationUI:RegisterInvokeListener("setRegionText", function(ev)
    local root = ev.UI:GetRoot()
    local label = ev.Args[1]
    local duration = Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "RegionLabelDuration")

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

Client.UI.EnemyHealthBar:RegisterListener("updated", function(char, item)
    -- Hide region notification immediately when the HP bar is brought up
    NotificationUI:GetRoot().hideRegionMC()
end)