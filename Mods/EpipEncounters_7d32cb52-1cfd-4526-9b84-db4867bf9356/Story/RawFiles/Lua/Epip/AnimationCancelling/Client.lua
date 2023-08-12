
local CommonStrings = Text.CommonStrings
local Minimap = Client.UI.Minimap
local WorldTooltip = Client.UI.WorldTooltip

---@class Feature_AnimationCancelling
local AnimCancel = Epip.GetFeature("Feature_AnimationCancelling")
AnimCancel.ITEM_PICKUP_CANCEL_DELAY = 0.1 -- In seconds.

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
AnimCancel.Settings.CancelWorldTooltipItemPickups = AnimCancel:RegisterSetting("CancelWorldTooltipItemPickups", {
    Type = "Boolean",
    Context = "Client",
    Name = AnimCancel.TranslatedStrings.Setting_CancelWorldTooltipItemPickups_Name,
    Description = AnimCancel.TranslatedStrings.Setting_CancelWorldTooltipItemPickups_Description,
    DefaultValue = false,
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
function AnimCancel.IsModeEnabled(mode)
    local isInMode

    if mode == AnimCancel.MODE.OFF then -- Don't check feature enable in this case
        isInMode = AnimCancel:GetSettingValue(AnimCancel.Settings.Mode) == AnimCancel.MODE.OFF
    else
        isInMode = AnimCancel:GetSettingValue(AnimCancel.Settings.Mode) == mode and AnimCancel:IsEnabled()
    end

    return isInMode
end

---Cancels the current skill animation of the client character.
---Does nothing if a skill is not being used.
function AnimCancel.CancelSkillAnimation()
    local char = Client.GetCharacter()
    local skill = Character.GetCurrentSkill(char)

    if skill then
        local delay = AnimCancel.GetDelay(char, skill)

        AnimCancel:DebugLog("Cancelling animation")

        Timer.Start(delay, AnimCancel.CancelAnimation)
    end
end

---Cancels the current animation of the client character.
function AnimCancel.CancelAnimation()
    Minimap:ExternalInterfaceCall("pingButtonPressed")
    Timer.StartTickTimer(AnimCancel.PING_DELAY, function (_) -- Must be delayed.
        Minimap:ExternalInterfaceCall("pingButtonPressed")
    end)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for changes in the client character's skill state, for client-side animation cancelling.
Client.Events.SkillStateChanged:Subscribe(function (ev)
    local char = Client.GetCharacter()

    GameState.Events.RunningTick:Unsubscribe("Feature_AnimationCancelling_SkillState")

    AnimCancel:DebugLog("Skill state changed", ev.State)

    if AnimCancel.IsModeEnabled(AnimCancel.MODE.CLIENT_SIDE) and ev.State and AnimCancel.IsEligible(char, Character.GetCurrentSkill(char)) then
        GameState.Events.RunningTick:Subscribe(function (_)
            char = Client.GetCharacter()
            local state = Character.GetSkillState(char)

            ---@diagnostic disable-next-line: undefined-field
            if state and state.State.Value >= Ext.Enums.SkillStateType.CastFinished.Value then
                AnimCancel.CancelSkillAnimation()

                GameState.Events.RunningTick:Unsubscribe("Feature_AnimationCancelling_SkillState")
            end
        end, {StringID = "Feature_AnimationCancelling_SkillState"})
    end
end)

-- Listen for skill cast notifications from the server, for "server-side" animation cancelling.
Net.RegisterListener(AnimCancel.NET_MESSAGE, function (payload)
    if AnimCancel.IsModeEnabled(AnimCancel.MODE.SERVER_SIDE) then
        local char = payload:GetCharacter()

        -- Only perform cancelling if the character matches - we don't want to try to cancel if the client character has been switched in the meantime.
        if char == Client.GetCharacter() and AnimCancel.IsEligible(char, payload.SkillID) then
            AnimCancel.CancelSkillAnimation()
        end
    end
end)

-- Do not cancel animations for blacklisted skills.
AnimCancel.Hooks.IsSkillEligible:Subscribe(function (ev)
    local blacklist = AnimCancel.Settings.Blacklist:GetValue() ---@type DataStructures_Set

    ev.Eligible = ev.Eligible and not blacklist:Contains(ev.SkillID)
end)

-- Certain skills are blacklisted in server-side mode only.
AnimCancel.Hooks.IsSkillEligible:Subscribe(function (ev)
    if AnimCancel.IsModeEnabled(AnimCancel.MODE.SERVER_SIDE) and AnimCancel.SERVERSIDE_BANNED_SKILLS:Contains(ev.SkillID) then
        ev.Eligible = false
    end
end)

-- Cancel item pickup animations from world tooltips;
-- this allows the user to pick up items this way at a much faster rate.
-- Regular item pickups do not have a forced cooldown.
Net.RegisterListener(AnimCancel.NETMSG_ITEM_PICKUP, function (_)
    if WorldTooltip:IsVisible() and AnimCancel:GetSettingValue(AnimCancel.Settings.CancelWorldTooltipItemPickups) == true then
        Timer.Start(AnimCancel.ITEM_PICKUP_CANCEL_DELAY, function (_)
            AnimCancel.CancelAnimation()
        end)
    end
end)