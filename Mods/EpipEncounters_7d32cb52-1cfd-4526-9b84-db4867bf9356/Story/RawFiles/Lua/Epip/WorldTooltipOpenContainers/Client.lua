
local WorldTooltip = Client.UI.WorldTooltip
local Notification = Client.UI.Notification
local Input = Client.Input

---@class Feature_WorldTooltipOpenContainers
local OpenContainers = Epip.GetFeature("WorldTooltipOpenContainers")
OpenContainers.SETTING_ID = "WorldTooltip_OpenContainers"
OpenContainers.TASK_FAILED_SOUND = "UI_Notification_ReceiveAbility"

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function OpenContainers:IsEnabled()
    return Settings.GetSettingValue("Epip_Tooltips", OpenContainers.SETTING_ID) and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for tooltips being clicked.
WorldTooltip.Events.TooltipClicked:Subscribe(function (ev)
    if ev.Item and Item.IsContainer(ev.Item) and OpenContainers:IsEnabled() then
        OpenContainers:DebugLog("Attempting to use", ev.Item.DisplayName)

        Net.PostToServer(OpenContainers.NETMSG_OPEN_CONTAINER, {
            CharacterNetID = Client.GetCharacter().NetID,
            ItemNetID = ev.Item.NetID,
        })

        ev:Prevent()
    end
end)

-- Request the move-and-use tasks to be cancelled when pressing right-click, left-click, or escape.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    local inputID = ev.InputID
    local requestCancel = false
    if (inputID == "right2" and ev.State == "Released") or (inputID == "escape") or inputID == "left2" then -- For right-click, the timing the game uses for cancelling regular movement is on-release.
        requestCancel = true
    end

    if requestCancel then
        local char = Client.GetCharacter()
        Net.PostToServer(OpenContainers.NETMSG_REQUEST_CANCEL, {CharacterNetID = char.NetID})

        -- Prevent pause menu from being brought up.
        if inputID == "escape" then
            ev:Prevent()
        end
    end
end, {EnabledFunctor = function ()
    return GameState.IsInRunningSession() and OpenContainers.IsTaskRunning(Client.GetCharacter())
end})

-- Listen for the task failing on the server.
Net.RegisterListener(OpenContainers.NETMSG_TASK_FAILED, function (_)
    Notification.ShowNotification(Text.GetTranslatedString(Notification.TSKHANDLES.CANT_REACH), nil, nil, OpenContainers.TASK_FAILED_SOUND)
end)
