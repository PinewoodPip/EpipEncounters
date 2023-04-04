
local Minimap = Client.UI.Minimap

---@class Feature_AnimationCancelling
local AnimCancel = Epip.GetFeature("Feature_AnimationCancelling")

---------------------------------------------
-- SETTINGS
---------------------------------------------

AnimCancel:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = AnimCancel.TranslatedStrings.Setting_Name,
    Description = Text.Format(AnimCancel.TranslatedStrings.Setting_Tooltip:GetString(), {
        FormatArgs = {
            {
                Text = AnimCancel.TranslatedStrings.Setting_Warning:GetString(),
                Color = Color.LARIAN.YELLOW,
            },
        },
    }),
    DefaultValue = false,
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
    return _Feature.IsEnabled(self) and self:GetSettingValue(AnimCancel.Settings.Enabled) == true
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

-- Listen for changes in the client character's skill state.
Client.Events.SkillStateChanged:Subscribe(function (ev)
    local char = Client.GetCharacter()

    GameState.Events.RunningTick:Unsubscribe("Feature_AnimationCancelling_SkillState")

    AnimCancel:DebugLog("Skill state changed", ev.State)

    if AnimCancel:IsEnabled() and ev.State and AnimCancel.IsEligible(char, Character.GetCurrentSkill(char)) then
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

-- Do not cancel animations for blacklisted skills.
AnimCancel.Hooks.IsSkillEligible:Subscribe(function (ev)
    local blacklist = AnimCancel.Settings.Blacklist:GetValue() ---@type DataStructures_Set

    ev.Eligible = ev.Eligible and not blacklist:Contains(ev.SkillID)
end)