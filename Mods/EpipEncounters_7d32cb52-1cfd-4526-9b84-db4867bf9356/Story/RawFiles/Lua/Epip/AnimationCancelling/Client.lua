
local Minimap = Client.UI.Minimap
local WorldTooltip = Client.UI.WorldTooltip

---@class Feature_AnimationCancelling
local AnimCancel = Epip.GetFeature("Feature_AnimationCancelling")
AnimCancel.ITEM_PICKUP_CANCEL_DELAY = 0.1 -- In seconds.

---------------------------------------------
-- SETTINGS
---------------------------------------------

AnimCancel.Settings.Enabled = AnimCancel:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = AnimCancel.TranslatedStrings.Setting_Enabled_Name,
    Description = AnimCancel.TranslatedStrings.Setting_Enabled_Description,
    DefaultValue = false,
    Context = "Client",
})
AnimCancel.Settings.Blacklist = AnimCancel:RegisterSetting("Blacklist", {
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

---Cancels the current skill animation of the client character.
---Does nothing if a skill is not being used.
function AnimCancel.CancelSkillAnimation()
    local char = Client.GetCharacter()
    local skill = Character.GetCurrentSkill(char)
    if skill then
        local delay = AnimCancel.GetDelay(char, skill)
        Timer.Start(delay, AnimCancel.CancelAnimation)
    end
end

---Cancels the current animation of the client character.
function AnimCancel.CancelAnimation()
    AnimCancel:DebugLog("Cancelling animation")
    Minimap:ExternalInterfaceCall("pingButtonPressed")
    Timer.StartTickTimer(AnimCancel.PING_DELAY, function (_) -- Must be delayed.
        Minimap:ExternalInterfaceCall("pingButtonPressed")
    end)
end

---Require the setting to be enabled for the feature to be considered enabled client-side.
---@override
function AnimCancel:IsEnabled()
    return _Feature.IsEnabled(self) and self:GetSettingValue(AnimCancel.Settings.Enabled) == true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for skill cast notifications from the server to determine when it is safe to cancel animations.
Net.RegisterListener(AnimCancel.NET_MESSAGE, function (payload)
    if AnimCancel:IsEnabled() then
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
