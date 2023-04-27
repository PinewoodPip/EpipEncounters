
local CommonStrings = Text.CommonStrings
local Minimap = Client.UI.Minimap

---@class Feature_AnimationCancelling
local AnimCancel = Epip.GetFeature("Feature_AnimationCancelling")

---@enum Feature_AnimationCancelling_Mode
AnimCancel.MODE = {
    OFF = 1,
    CLIENT_SIDE = 2,
    SERVER_SIDE = 3,
}

---------------------------------------------
-- SETTINGS
---------------------------------------------

AnimCancel:RegisterSetting("Mode", {
    Type = "Choice",
    Name = AnimCancel.TranslatedStrings.Setting_Name,
    Description = Text.Format(AnimCancel.TranslatedStrings.Setting_Tooltip:GetString(), {
        FormatArgs = {
            {
                Text = AnimCancel.TranslatedStrings.Setting_Warning:GetString(),
                Color = Color.LARIAN.YELLOW,
            },
        },
    }),
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = AnimCancel.MODE.OFF, NameHandle = CommonStrings.Off.Handle},
        {ID = AnimCancel.MODE.CLIENT_SIDE, NameHandle = CommonStrings.ClientSide.Handle},
        {ID = AnimCancel.MODE.SERVER_SIDE, NameHandle = CommonStrings.ServerSide.Handle},
    },
    DefaultValue = AnimCancel.MODE.OFF,
    Context = "Client",
})
AnimCancel:RegisterSetting("Blacklist", {
    Type = "Set",
    Name = AnimCancel.TranslatedStrings.Blacklist_Name,
    Description = AnimCancel.TranslatedStrings.Blacklist_Description,
    Context = "Client",
    ElementsAreSkills = true, -- For settings menu.
})

---------------------------------------------
-- METHODS
---------------------------------------------

-- Require setting to be enabled.
function AnimCancel:IsEnabled()
    return _Feature.IsEnabled(self) and self:GetSettingValue(AnimCancel.Settings.Mode) ~= AnimCancel.MODE.OFF
end

---Returns whether the feature is set to a particular mode.
---If the mode is not `OFF`, the feature must be enabled as well for `true` to be returned.
---@param mode Feature_AnimationCancelling_Mode
---@return boolean
function AnimCancel:IsModeEnabled(mode)
    local isInMode

    if mode == AnimCancel.MODE.OFF then -- Don't check feature enable in this case
        isInMode = self:GetSettingValue(AnimCancel.Settings.Mode) == AnimCancel.MODE.OFF
    else
        isInMode = self:GetSettingValue(AnimCancel.Settings.Mode) == mode and self:IsEnabled()
    end

    return isInMode
end

---Cancels the current animation of the client character.
function AnimCancel:CancelAnimation()
    local char = Client.GetCharacter()
    local skill = Character.GetCurrentSkill(char)

    if skill then
        local delay = AnimCancel.GetDelay(char, skill)
    
        local func = function (_)
            Minimap:ExternalInterfaceCall("pingButtonPressed")
    
            Timer.StartTickTimer(AnimCancel.PING_DELAY, function (_)
                Minimap:ExternalInterfaceCall("pingButtonPressed")
            end)
        end

        AnimCancel:DebugLog("Cancelling animation")
    
        Timer.Start(delay, func)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for changes in the client character's skill state, for client-side animation cancelling.
Client.Events.SkillStateChanged:Subscribe(function (ev)
    local char = Client.GetCharacter()

    GameState.Events.RunningTick:Unsubscribe("Feature_AnimationCancelling_SkillState")

    AnimCancel:DebugLog("Skill state changed", ev.State)

    if AnimCancel:IsModeEnabled(AnimCancel.MODE.CLIENT_SIDE) and ev.State and AnimCancel.IsEligible(char, Character.GetCurrentSkill(char)) then
        GameState.Events.RunningTick:Subscribe(function (_)
            char = Client.GetCharacter()
            local state = Character.GetSkillState(char)

            ---@diagnostic disable-next-line: undefined-field
            if state and state.State.Value >= Ext.Enums.SkillStateType.CastFinished.Value then
                AnimCancel:CancelAnimation()

                GameState.Events.RunningTick:Unsubscribe("Feature_AnimationCancelling_SkillState")
            end
        end, {StringID = "Feature_AnimationCancelling_SkillState"})
    end
end)

-- Listen for skill cast notifications from the server, for "server-side" animation cancelling.
Net.RegisterListener(AnimCancel.NET_MESSAGE, function (payload)
    if AnimCancel:IsModeEnabled(AnimCancel.MODE.SERVER_SIDE) then
        local char = payload:GetCharacter()

        -- Only perform cancelling if the character matches - we don't want to try to cancel if the client character has been switched in the meantime.
        if char == Client.GetCharacter() then
            AnimCancel:CancelAnimation()
        end
    end
end)

-- Do not cancel animations for blacklisted skills.
AnimCancel.Hooks.IsSkillEligible:Subscribe(function (ev)
    local blacklist = AnimCancel.Settings.Blacklist:GetValue() ---@type DataStructures_Set

    ev.Eligible = ev.Eligible and not blacklist:Contains(ev.SkillID)
end)