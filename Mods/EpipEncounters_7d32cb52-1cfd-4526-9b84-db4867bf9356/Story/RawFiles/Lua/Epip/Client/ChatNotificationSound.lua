
local Chat = Client.UI.ChatLog

---@class Feature_ChatNotificationSound : Feature
local Sound = {
    -- Indexes correspond to dropdown setting.
    SOUNDS = {
        "UI_Gen_BigButton_Click",
        "UI_Game_Craft_Click",
        "Synth_440tone_200ms",
    },
    SETTING_ID = "Chat_MessageSound",
    USER_MESSAGE_PATTERN = "^<font size=16 color=#bbbbbb>.+:</font> <font size=16 color=#ffffff>.+</font>$"
}
Epip.RegisterFeature("ChatNotificationSound", Sound)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param msg string
---@return boolean
function Sound.IsUserMessage(msg)
    return msg:match(Sound.USER_MESSAGE_PATTERN) ~= nil
end

---@param sound string? Defaults to using the setting.
function Sound.PlaySound(sound)
    if Sound:IsEnabled() then
        sound = sound or Sound.SOUNDS[Settings.GetSettingValue("Epip_Chat", Sound.SETTING_ID) - 1]

        Chat:PlaySound(sound)
    end
end

---@override
function Sound:IsEnabled()
    return Settings.GetSettingValue("Epip_Chat", Sound.SETTING_ID) > 1 and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Play the sound when a chat message is received from another user.
Chat.Events.MessageAdded:Subscribe(function (ev)
    if not ev.IsFromClient and Sound.IsUserMessage(ev.Text) then
        Sound.PlaySound()
    end
end)

---------------------------------------------
-- TESTS
---------------------------------------------

Testing.RegisterTest(Sound, {
    ID = "IsUserMessage",
    Function = function (_)
        local dummyMessage = "<font size=16 color=#bbbbbb>Pip:</font> <font size=16 color=#ffffff>Hello</font>"
        assert(Sound.IsUserMessage(dummyMessage), "User message check failed")

        dummyMessage = "Welcome to party chat"
        assert(not Sound.IsUserMessage(dummyMessage), "User message check failed")
    end
})
