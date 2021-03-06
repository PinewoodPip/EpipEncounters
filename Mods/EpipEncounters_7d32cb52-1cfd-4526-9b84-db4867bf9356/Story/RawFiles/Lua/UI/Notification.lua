
local Notification = {
    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/notification.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/notification.swf",
    },
}
Client.UI.Notification = Notification
Epip.InitializeUI(Client.UI.Data.UITypes.notification, "Notification", Notification)

function OnUINotification(ui, method, str1, num1, num2)
    local root = Ext.UI.GetByType(Client.UI.Data.UITypes.notification):GetRoot()
    -- root.notCast_mc.y = 360
    -- root.notCast_mc.visible = root.showCastNots
    -- root.notCastY = 120
    -- root.hideCastNot(0)

    -- local notCast = root.notCast_mc
    -- local visible = root.showCastNots
    -- notCast.bgM_mc.visible = visible
    -- notCast.bg_mc.visible = visible
    -- notCast.text_txt.visible = visible
end

Client.UI.Hotbar:RegisterListener("Refreshed", function(barCount)
    if not notification.showCastNots then
        notification.root.notCastY = -545
        return nil
    end
    barAmount = (barCount - 1)
    
    notification.root.notCastY = notification.baseY + ((barAmount) * notification.offsetPerBar)
end)

notification = {
    ui = nil,
    root = nil,
    showCastNots = true,

    baseY = 850,
    offsetPerBar = -65,
}

Ext.Events.SessionLoaded:Subscribe(function()
    local notif = Ext.UI.GetByType(Client.UI.Data.UITypes.notification)
    local root = notif:GetRoot()

    notification.ui = notif
    notification.root = root

    root.showCastNots = Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "CastingNotifications")
    notification.showCastNots = Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "CastingNotifications")

    -- notification.offsetPerBar = -Ext.UI.GetByType(Client.UI.Data.UITypes.statusConsole):GetRoot().height

    Ext.RegisterUITypeInvokeListener(Client.UI.Data.UITypes.notification, "showCastNot", OnUINotification, "After")
end)