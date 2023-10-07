
---------------------------------------------
-- Plays a notification when another player joins a dialogue.
---------------------------------------------

local PlayerInfo = Client.UI.PlayerInfo
local Notification = Client.UI.Notification
local V = Vector.Create

---@type Feature
local DialogueTweaks = {
    NOTIFICATION_SOUND = "UI_Game_Journal_Expand",
    NOTIFICATION_DURATION = 1, -- In seconds.
    AUTOLISTEN_TIMEOUT = 0.5, -- In seconds.

    Settings = {},
    TranslatedStrings = {
        Notification_JoinedDialogue = {
           Handle = "hde6129e2g7b78g4b15gb1d1g2ef3dc9a4a47",
           Text = "%s has entered dialogue.",
           ContextDescription = "Notification popup. Param is character name.",
        },
        Notification_AutoListened = {
            Handle = "h81560a4dg3324g4c62g971cg75855b8a1672",
            Text = "Auto-listening to %s's dialogue.",
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
        Setting_AutoListen_Name = {
            Handle = "h079a4fc9g48b4g4bc6gbf71gad47fa4acb61",
            Text = "Auto-Listen Dialogues",
            ContextDescription = "Setting name",
        },
        Setting_AutoListen_Description = {
            Handle = "ha6a00a9ag10b2g4ac0g9be8gfc8bac919cf1",
            Text = "If enabled, your character will automatically listen in on dialogues that other players enter, if they are within the range limit.",
            ContextDescription = "Setting tooltip",
        },
        Setting_AutoListenRangeLimit_Name = {
            Handle = "hd8095efage554g41b7gafedg33447556533e",
            Text = "Auto-Listen Range Limit",
            ContextDescription = "Setting name",
        },
        Setting_AutoListenRangeLimi_Description = {
            Handle = "h5efb42cag481bg466dg9089g55793976612a",
            Text = "Determines the maximum distance (in meters) that other players's characters can be at for their dialogues to be auto-listened to, if \"Auto-Listen Range Limit\" is enabled.",
            ContextDescription = "Setting tooltip",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        CanAutoListen = {}, ---@type Hook<Features.DialogueTweaks.Hooks.CanAutoListen>
    },
}
Epip.RegisterFeature("DialogueTweaks", DialogueTweaks)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.DialogueTweaks.Hooks.CanAutoListen
---@field Character EclCharacter
---@field CanAutoListen boolean Hookable. Defaults to `true`.

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

DialogueTweaks.Settings.AutoListen = DialogueTweaks:RegisterSetting("AutoListen", {
    Type = "Boolean",
    Name = DialogueTweaks.TranslatedStrings.Setting_AutoListen_Name,
    Description = DialogueTweaks.TranslatedStrings.Setting_AutoListen_Description,
    Context = "Client",
    DefaultValue = false,
    RequiresPipFork = true,
})
DialogueTweaks.Settings.AutoListenRangeLimit = DialogueTweaks:RegisterSetting("AutoListenRangeLimit", {
    Type = "ClampedNumber",
    NameHandle = DialogueTweaks.TranslatedStrings.Setting_AutoListenRangeLimit_Name,
    DescriptionHandle = DialogueTweaks.TranslatedStrings.Setting_AutoListenRangeLimi_Description,
    Min = 0,
    Max = 50,
    Step = 1,
    HideNumbers = false,
    DefaultValue = 15,
    RequiresPipFork = true,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether a character's dialogue can be auto-listened.
---@see Features.DialogueTweaks.Hooks.CanAutoListen
---@param targetChar EclCharacter
---@return boolean
function DialogueTweaks.CanAutoListen(targetChar)
    return DialogueTweaks.Hooks.CanAutoListen:Throw({
        Character = targetChar,
        CanAutoListen = true,
    }).CanAutoListen
end

---Causes the client character to start listening to targetChar's dialogue.
---@param targetChar EclCharacter Must be in the same party as client character.
function DialogueTweaks._ListenToPlayer(targetChar)
    local targetCharHandle = targetChar.Handle
    local flashHandle = Ext.UI.HandleToDouble(targetChar.Handle)
    targetChar = Character.Get(targetCharHandle)
    local requestStartTime = Ext.Utils.MonotonicTime()

    PlayerInfo:ExternalInterfaceCall("onCharOver", flashHandle)

    GameState.Events.RunningTick:Subscribe(function (_)
        local timeElapsed = (Ext.Utils.MonotonicTime() - requestStartTime) / 1000
        local playerState = Ext.UI.GetUIObjectManager().PlayerStates[1]
        playerState.ActiveUIObjectHandle = PlayerInfo:GetUI():GetHandle()
        playerState.UIUnderMouseCursor = true
        PlayerInfo:ExternalInterfaceCall("onCharOver", flashHandle)
        targetChar = Character.Get(targetCharHandle)

        local pointerChar = Pointer.GetCurrentCharacter()
        if pointerChar and pointerChar.Handle == targetCharHandle then
            Client.Input.Inject("Mouse", "left2", "Pressed")
            Client.Input.Inject("Mouse", "left2", "Released")

            -- Show notification
            Notification.ShowNotification(DialogueTweaks.TranslatedStrings.Notification_AutoListened:Format(targetChar.DisplayName), DialogueTweaks.NOTIFICATION_DURATION, nil, DialogueTweaks.NOTIFICATION_SOUND)
            GameState.Events.RunningTick:Unsubscribe("Features.DialogueTweaks.AutoListen")
        elseif timeElapsed > DialogueTweaks.AUTOLISTEN_TIMEOUT then -- Stop attempting to listen if we weren't able to select the character quickly.
            GameState.Events.RunningTick:Unsubscribe("Features.DialogueTweaks.AutoListen")
        end
    end, {StringID = "Features.DialogueTweaks.AutoListen"})
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for player characters entering the in-dialogue state.
PlayerInfo.Hooks.UpdateInfos:Subscribe(function (ev)
    if not Client.IsInDialogue() then -- Do not play notifications or auto-listen if client is already busy in a dialogue.
        for _,entry in ipairs(ev.Entries) do
            if entry.EntryTypeID == "SetActionState" then
                ---@cast entry UI.PlayerInfo.Entries.SetActionState
                if entry.State == PlayerInfo.ACTION_STATES.IN_DIALOGUE then
                    local char = Character.Get(entry.CharacterFlashHandle, true)
                    local element = PlayerInfo.GetPlayerElement(char)
                    if not element.controlled then -- Only do this for characters of other players.
                        DialogueTweaks:DebugLog(char.DisplayName, "went into dialogue")

                        -- Auto-listen to the dialogue
                        if DialogueTweaks:GetSettingValue(DialogueTweaks.Settings.AutoListen) == true and DialogueTweaks.CanAutoListen(char) then
                            DialogueTweaks._ListenToPlayer(char)
                        elseif DialogueTweaks:GetSettingValue(DialogueTweaks.Settings.Enabled) == true then -- Show notification.
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
    end
end, {StringID = "Features.DialogueTweaks"})

-- Default implementation of CanAutoListen.
DialogueTweaks.Hooks.CanAutoListen:Subscribe(function (ev)
    local char = ev.Character
    local canListen = ev.CanAutoListen
    local clientChar = Client.GetCharacter()

    -- Auto-listening requires having the Pip fork installed (due to the fields being written being RO otherwise)
    canListen = canListen and Epip.IsPipFork()

    -- Auto-listening has a maximum distance range.
    local distance = Vector.GetLength(V(char.WorldPos) - V(clientChar.WorldPos))
    canListen = canListen and distance <= DialogueTweaks:GetSettingValue(DialogueTweaks.Settings.AutoListenRangeLimit)

    -- Cannot listen while using a skill or in combat.
    canListen = canListen and not Character.GetSkillState(clientChar)
    canListen = canListen and not Character.IsInCombat(clientChar)

    ev.CanAutoListen = canListen
end, {StringID = "DefaultImplementation"})
