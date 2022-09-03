
---@class NotificationUI : UI
local Notification = {

    SOUNDS = {
        RECEIVE_ABILITY = "UI_Notification_ReceiveAbility",
        RECEIVE_SKILL = "UI_Notification_ReceiveSkill",
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        TextNotificationShown = {Preventable = true}, ---@type PreventableEvent<NotificationUI_Event_TextNotificationShown>
    },
    Hooks = {
        ShowReceivalNotification = {}, ---@type SubscribableEvent<NotificationUI_Hook_ShowReceivalNotification>
    },

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/notification.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/notification.swf",
    },
}
Client.UI.Notification = Notification
Epip.InitializeUI(Client.UI.Data.UITypes.notification, "Notification", Notification)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class NotificationUI_Event_TextNotificationShown : PreventableEventParams
---@field Label string
---@field Sound string
---@field Duration number In seconds.
---@field IsNormal boolean If false, the notification will be a warning-style one.
---@field Unused1 number
---@field IsScripted boolean True if the notification came from a lua script.


---@class NotificationUI_Hook_ShowReceivalNotification
---@field Sound string
---@field Name string
---@field Description string
---@field Prevent boolean Defaults to false.

---------------------------------------------
-- METHODS
---------------------------------------------

---@param text string
---@param duration number? Defaults to 2 (seconds)
---@param isWarning boolean? If true, the notification will use a simpler style with yellow text.
---@param sound string?
function Notification.ShowNotification(text, duration, isWarning, sound)
    duration = duration or 2
    sound = sound or ""
    if isWarning == nil then isWarning = false end

    local success = Notification._FireTextNotificationEvent(text, sound, duration, not isWarning, nil, true)

    if success then
        Notification:GetRoot().setNotification(text, "", duration, not isWarning)

        -- Done here as the warning-style notification type does not call it in the swf.
        if sound ~= "" then
            Notification:PlaySound(sound)
        end
    end
end

---@param text string
---@param icon string
---@param subTitle string?
---@param title string? Appears above the toast (ex. "New Skill")
---@param hint string? Appears below the toast (ex. "Press K to view") with a descending tween.
---@param sound string?
function Notification.ShowIconNotification(text, icon, subTitle, title, hint, sound)
    local root = Notification:GetRoot()
    sound = sound or ""
    subTitle = subTitle or ""
    title = title or ""
    hint = hint or ""

    if not icon then Notification:LogError("ShowIconNotification(): no icon provided.") return nil end

    Notification:GetUI():SetCustomIcon("si", icon, 50, 50)

    root.setLabel(0, title)
    root.setLabel(1, hint)
    root.showNewSkill(text, subTitle, sound)

    -- Clear custom icon once the notification ends.
    Timer.Start(3.1, function (_)
        Notification:GetUI():ClearCustomIcon("si")
    end, "NotificationUI_ClearIggy_si")
end

---@param text string
---@param duration number? Defaults to 2 (seconds)
---@param sound string?
function Notification.ShowWarning(text, duration, sound)
    Notification.ShowNotification(text, duration, true, sound)
end

---@param label string
---@param sound string
---@param duration number
---@param isNormal boolean
---@param unused1 number?
---@param isScripted boolean? Defaults to false.
---@return boolean True if the event was not prevented.
function Notification._FireTextNotificationEvent(label, sound, duration, isNormal, unused1, isScripted)
    return not Notification.Events.TextNotificationShown:Throw({
        Label = label,
        Sound = sound,
        Duration = duration,
        IsNormal = isNormal,
        Unused1 = unused1 or 0,
        IsScripted = isScripted or false,
    }).Prevented
end

---------------------------------------------
-- OLD CODE
---------------------------------------------

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
end)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for regular toasts.
Notification:RegisterInvokeListener("setNotification", function (ev, label, sound, duration, isWarning, unused1) -- Last param is unused.
    if not Notification._FireTextNotificationEvent(label, sound, duration, not isWarning, unused1, false) then
        ev:PreventAction()

        -- Call notif done - this is done so as not to confuse the notification queue in the engine.
        Timer.Start("", 0.5, function()
            Notification:ExternalInterfaceCall("notificationDone")
        end)
    end
end)

-- Listen for skill/item notifications.
Notification:RegisterInvokeListener("showNewSkill", function(ev, name, description, sound)
    ---@type NotificationUI_Hook_ShowReceivalNotification
    local event = {
        Name = name,
        Description = description,
        Sound = sound,
        Prevent = false,
    }

    Notification.Hooks.ShowReceivalNotification:Throw(event)

    -- Prevent action.
    if event.Prevent then
        ev:PreventAction()

        Timer.Start("", 0.5, function()
            Notification:ExternalInterfaceCall("notificationDone")
        end)
    end
end)