
local Chat = Client.UI.ChatLog
local CommonStrings = Text.CommonStrings

---@class Feature_ChatNotificationSound : Feature
local Sound = {
    -- Indexes correspond to dropdown setting.
    SOUNDS = {
        "UI_Gen_BigButton_Click",
        "UI_Game_Craft_Click",
        "Synth_440tone_200ms",
    },
    USER_MESSAGE_PATTERN = "^<font size=16 color=#bbbbbb>.+:</font> <font size=16 color=#ffffff>.+</font>$",

    TranslatedStrings = {
        Setting_MessageSound_Name = {
            Handle = "h782c3c33g9b20g461cg9893g8ec4eb2d36b1",
            Text = "Message Sound",
            ContextDescription = "Chat message sound setting name",
        },
        Setting_MessageSound_Description = {
            Handle = "hb19e37acgd289g4ba3gb79ega89bab6ff0cc",
            Text = "Plays a sound effect when a message is received, so as to make it easier to notice.",
            ContextDescription = "Chat message sound setting tooltip",
        },
        Setting_MessageSound_Choice_Click = {
            Handle = "hc716b8ecg48f5g4339g97a0g5a67c7beccc8",
            Text = "Sound 1 (Click)",
            ContextDescription = [[Setting choice for "Message Sound"]],
        },
        Setting_MessageSound_Choice_HighPitchedClick = {
            Handle = "h49230cc3g7479g4139gb8e7ga5b6977f1149",
            Text = "Sound 2 (High-pitched click)",
            ContextDescription = [[Setting choice for "Message Sound"]],
        },
        Setting_MessageSound_Choice_Synth = {
            Handle = "h7bad9beeg9f1ag45e1gaa33gf655c350e702",
            Text = "Sound 3 (Synth)",
            ContextDescription = [[Setting choice for "Message Sound"]],
        },
    },
    Settings = {},
}
Epip.RegisterFeature("ChatNotificationSound", Sound)
local TSK = Sound.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

Sound.Settings.MessageSound = Sound:RegisterSetting("MessageSound", {
    Type = "Choice",
    Name = TSK.Setting_MessageSound_Name,
    Description = TSK.Setting_MessageSound_Description,
    DefaultValue = 1,
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = 1, NameHandle = CommonStrings.None.Handle},
        {ID = 2, NameHandle = TSK.Setting_MessageSound_Choice_Click.Handle},
        {ID = 3, NameHandle = TSK.Setting_MessageSound_Choice_HighPitchedClick.Handle},
        {ID = 4, NameHandle = TSK.Setting_MessageSound_Choice_Synth.Handle},
    },
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether a chat message comes from a user (as opposed to system messages).
---@param msg string
---@return boolean
function Sound.IsUserMessage(msg)
    return msg:match(Sound.USER_MESSAGE_PATTERN) ~= nil
end

---Plays the chat notification sound, if enabled.
---@param sound string? Defaults to using the setting.
function Sound.TryPlaySound(sound)
    if Sound:IsEnabled() then
        sound = sound or Sound.SOUNDS[Sound:GetSettingValue(Sound.Settings.MessageSound) - 1]

        Chat:PlaySound(sound)
    end
end

---@override
function Sound:IsEnabled()
    return Sound:GetSettingValue(Sound.Settings.MessageSound) > 1 and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Play the sound when a chat message is received from another user.
Chat.Events.MessageAdded:Subscribe(function (ev)
    if not ev.IsFromClient and Sound.IsUserMessage(ev.Text) then
        Sound.TryPlaySound()
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
