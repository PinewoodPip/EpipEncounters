
local Minimap = Client.UI.Minimap
local WorldTooltip = Client.UI.WorldTooltip

---@class Feature_AnimationCancelling
local AnimCancel = Epip.GetFeature("Feature_AnimationCancelling")
AnimCancel.ITEM_PICKUP_CANCEL_DELAY = 0.1 -- In seconds.

---------------------------------------------
-- SETTINGS
---------------------------------------------

-- Legacy ID, from before cancelling attack animations was supported.
AnimCancel.Settings.CancelSkills = AnimCancel:RegisterSetting("CancelSkills", {
    Type = "Boolean",
    Name = AnimCancel.TranslatedStrings.Setting_CancelSkills_Name,
    Description = AnimCancel.TranslatedStrings.Setting_CancelSkills_Description,
    DefaultValue = false,
    Context = "Client",
})
AnimCancel.Settings.CancelAttacks = AnimCancel:RegisterSetting("CancelAttacks", {
    Type = "Boolean",
    Name = AnimCancel.TranslatedStrings.Setting_CancelAttacks_Name,
    Description = AnimCancel.TranslatedStrings.Setting_CancelAttacks_Description,
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

---Returns whether char is eligible to have its action state cancelled.
---@see Feature_AnimationCancelling_Hook_IsSkillEligible
---@param char Character
---@param state EclActionState|EsvActionState|skill
---@return boolean
function AnimCancel.IsEligible(char, state)
    local eligible
    local skillID = type(state) == "string" and state or nil
    if type(state) ~= "string" and state.Type == "UseSkill" then -- State overload.
        if Ext.IsServer() then
            ---@cast state EsvASUseSkill
            skillID = Stats.RemoveLevelSuffix(state.Skill.SkillId)
        else
            skillID = Character.GetCurrentSkill(char)
        end
    end
    eligible = AnimCancel.Hooks.CanCancelAnimation:Throw({
        Character = char,
        CanCancel = false,
    }).CanCancel
    if eligible and skillID then -- Throw additional hook for skill states.
        eligible = AnimCancel.Hooks.IsSkillEligible:Throw({
            Character = char,
            SkillID = skillID,
            Stat = Stats.GetSkillData(skillID),
            Eligible = true,
        }).Eligible
    end
    return eligible
end

---Requests to cancel the current animation of the client character.
---@param delay number? In seconds. Defaults to `GetDelay()`.
function AnimCancel.CancelAnimation(delay)
    if delay == nil then
        local char = Client.GetCharacter()
        local skill = Character.GetCurrentSkill(char)
        local layer = char.ActionMachine.Layers[1]
        local state = layer and layer.State or nil
        delay = AnimCancel.GetDelay(char, skill or state)
    end
    Timer.Start(delay, AnimCancel._CancelAnimation)
end

---Cancels the current animation of the client character.
function AnimCancel._CancelAnimation()
    AnimCancel:DebugLog("Cancelling animation")
    Minimap:ExternalInterfaceCall("pingButtonPressed")
    Timer.StartTickTimer(AnimCancel.PING_DELAY, function (_) -- Must be delayed.
        Minimap:ExternalInterfaceCall("pingButtonPressed")
    end)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for skill cast notifications from the server to determine when it is safe to cancel animations.
Net.RegisterListener(AnimCancel.NET_MESSAGE, function (payload)
    -- Only perform cancelling if the character matches - we don't want to try to cancel if the client character has been switched in the meantime.
    local char = payload:GetCharacter()
    if char == Client.GetCharacter() then
        if AnimCancel.IsEligible(char, payload.SkillID or Character.GetActionState(char)) then
            AnimCancel.CancelAnimation()
        end
    end
end)

-- Apply setting preferences when deciding whether to cancel animations.
AnimCancel.Hooks.CanCancelAnimation:Subscribe(function (ev)
    local state = Character.GetActionState(ev.Character)
    if state.Type == "Attack" then
        ev.CanCancel = AnimCancel.Settings.CancelAttacks:GetValue() == true
    elseif Character.GetCurrentSkill(ev.Character) then
        ev.CanCancel = AnimCancel.Settings.CancelSkills:GetValue() == true
    end
end)

-- Do not cancel animations for blacklisted skills.
AnimCancel.Hooks.IsSkillEligible:Subscribe(function (ev)
    local blacklist = AnimCancel.Settings.Blacklist:GetValue() ---@type DataStructures_Set

    ev.Eligible = ev.Eligible and not blacklist:Contains(ev.SkillID)
end)

-- Apply skill and archetype blacklists.
AnimCancel.Hooks.IsSkillEligible:Subscribe(function (ev)
    local skillID = ev.SkillID
    local stat = ev.Stat
    if AnimCancel.BANNED_SKILLS:Contains(skillID) or AnimCancel.BANNED_ARCHETYPES:Contains(stat.SkillType) then
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
