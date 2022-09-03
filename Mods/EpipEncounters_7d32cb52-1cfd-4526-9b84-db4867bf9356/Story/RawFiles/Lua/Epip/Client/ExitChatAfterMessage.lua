
local Chat = Client.UI.ChatLog

---@class Feature_ExitChatAfterMessage : Feature
local Exit = {
    SETTING_ID = "Chat_ExitAfterSendingMessage",
}
Epip.RegisterFeature("ExitChatAfterMessage", Exit)

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function Exit:IsEnabled()
    return Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", Exit.SETTING_ID) and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Chat.Events.MessageSent:Subscribe(function (ev)
    -- Only do this if the message was not prevented; this is somewhat of a compatibility consideration for chat commands feature.
    if not ev.Prevented and Exit:IsEnabled() then
        Exit:DebugLog("Exiting chat")

        Client.Input.Inject("Key", "escape", "Pressed")
    end
end)