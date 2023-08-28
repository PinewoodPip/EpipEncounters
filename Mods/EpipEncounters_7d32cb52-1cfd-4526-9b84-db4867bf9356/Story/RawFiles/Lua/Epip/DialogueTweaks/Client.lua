
---------------------------------------------
-- Plays a notification when another player joins a dialogue.
---------------------------------------------

local PlayerInfo = Client.UI.PlayerInfo
local Notification = Client.UI.Notification

---@type Feature
local DialogueTweaks = {
    NOTIFICATION_SOUND = "UI_Game_Journal_Expand",
    NOTIFICATION_DURATION = 1, -- In seconds.

    Settings = {},
    TranslatedStrings = {
        Notification_JoinedDialogue = {
           Handle = "hde6129e2g7b78g4b15gb1d1g2ef3dc9a4a47",
           Text = "%s has entered dialogue.",
           ContextDescription = "Notification popup. Param is character name.",
        },
        Setting_Enabled_Name = {
           Handle = "h6b736d31gc985g48b6g8752g9137186f3703",
           Text = "Dialogue Notifications",
           ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
           Handle = "haa1fa94dg26f6g4de2g9aa5g3223510da178",
           Text = "If enabled, a notification will be shown when characters controlled by other players join dialogues, to make them harder to miss.",
           ContextDescription = "Setting tooltip",
        },
    }
}
Epip.RegisterFeature("DialogueTweaks", DialogueTweaks)

---------------------------------------------
-- SETTINGS
---------------------------------------------

DialogueTweaks.Settings.Enabled = DialogueTweaks:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = DialogueTweaks.TranslatedStrings.Setting_Enabled_Name,
    Description = DialogueTweaks.TranslatedStrings.Setting_Enabled_Description,
    Context = "Client",
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function DialogueTweaks:IsEnabled()
    return self:GetSettingValue(DialogueTweaks.Settings.Enabled) == true and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

PlayerInfo.Hooks.UpdateInfos:Subscribe(function (ev)
    if DialogueTweaks:IsEnabled() and not Client.IsInDialogue() then -- Do not play notifications if client is already busy in a dialogue.
        for _,entry in ipairs(ev.Entries) do
            if entry.EntryTypeID == "SetActionState" then
                ---@cast entry UI.PlayerInfo.Entries.SetActionState
                if entry.State == PlayerInfo.ACTION_STATES.IN_DIALOGUE then
                    local char = Character.Get(entry.CharacterFlashHandle, true)
                    local element = PlayerInfo.GetPlayerElement(char)
                    if not element.controlled then -- Only do this for characters of other players.
                        DialogueTweaks:DebugLog(char.DisplayName, "went into dialogue")

                        Notification.ShowNotification(Text.Format(DialogueTweaks.TranslatedStrings.Notification_JoinedDialogue:GetString(), {
                            FormatArgs = {
                                char.DisplayName,
                            }
                        }), DialogueTweaks.NOTIFICATION_DURATION, nil, DialogueTweaks.NOTIFICATION_SOUND)
                    end
                end
            end
        end
    end
end, {StringID = "Features.DialogueTweaks.Notification"})