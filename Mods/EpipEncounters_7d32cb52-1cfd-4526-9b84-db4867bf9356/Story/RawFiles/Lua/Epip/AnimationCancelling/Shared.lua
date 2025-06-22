
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_AnimationCancelling : Feature
local AnimCancel = {
    NET_MESSAGE = "Epip_Feature_AnimationCancelling",
    NETMSG_ITEM_PICKUP = "Epip_Feature_AnimationCancelling_ItemPickUpEntered", -- Empty message.
    DEFAULT_DELAY = 0.05, -- In seconds.
    DEFAULT_DELAY_NO_AP = 0.25, -- Delay to use when at 0 AP, in seconds.
    PING_DELAY = 2, -- In ticks.

    ---@type table<string, number> Delays for cancelling specific skills, in seconds.
    SKILL_DELAYS = {},
    BANNED_ARCHETYPES = Set.Create({}), ---@type DataStructures_Set<SkillType> Add archetypes (ex. "Jump") to prevent them from being animation-cancelled.
    BANNED_SKILLS = Set.Create({}), ---@type DataStructures_Set<skill> Add skills to prevent them from being animation-cancelled.

    TranslatedStrings = {
        Label_FeatureName = {
           Handle = "h3bf7ae10g24e1g4f50gbc69g71a8b95b1a51",
           Text = "Animation Cancelling",
           ContextDescription = "Feature name; displayed in settings menu",
        },
        Label_Description = {
            Handle = "hb909e1ceg8636g48afg8672g2acc5a1ce44e",
            Text = "Animation Cancelling allows skill casts to end earlier by interrupting their animations after their effects execute, speeding up combat.",
            ContextDescription = [[Description shown in settings tab]],
        },
        Setting_CancelSkills_Name = {
           Handle = "h0a1e975egaf04g414cg9be0g559112d5284d",
           Text = "Cancel skill animations",
           ContextDescription = "Setting name",
        },
        Setting_CancelSkills_Description = {
           Handle = "he5c3a752gd8bag48fagb611g35b5d23bef9d",
           Text = "If enabled, your controlled character's skill animations will be cancelled after their effects execute, allowing you to perform consecutive actions quicker.",
           ContextDescription = "Setting tooltip",
        },
        Setting_CancelAttacks_Name = {
            Handle = "hbcafdc0cg81b6g4dd9g853fga0b42f636c1c",
            Text = "Cancel attack animations",
            ContextDescription = [[Setting name]],
        },
        Setting_CancelAttacks_Description = {
            Handle = "h1c66019dgac33g49f4g8c11gbbfe9d4dbf61",
            Text = "If enabled, attack animations will be cancelled once all of their hits and projectiles have fired, allowing you to perform consecutive actions quicker.",
            ContextDescription = [[Setting tooltip for "Cancel attack animations"]],
        },
        Setting_CancelNPCAnimations_Name = {
            Handle = "h4f7b80efgc4b8g43a5g9971gc7014c8c9a2c",
            Text = "Cancel NPC animations",
            ContextDescription = [[Setting name]],
        },
        Setting_CancelNPCAnimations_Description = {
            Handle = "h012184d6g4d40g4ad7g890bg5f9bad080a77",
            Text = "If enabled, skill and attack animations of NPCs will be cancelled after their effects execute.",
            ContextDescription = [[Setting tooltip for "Cancel NPC animations"]],
        },
        Blacklist_Name = {
           Handle = "ha50d50eag4185g4e10g82fdg19548a304b32",
           Text = "Blacklisted Skills",
           ContextDescription = "Name for blacklist setting",
        },
        Blacklist_Description = {
           Handle = "he043b9f9gfc52g4c39ga4f1gc53ea4fcd5ce",
           Text = "Add skill IDs to this setting to blacklist them from being animation-cancelled.<br>Only affects skills used by the player.",
           ContextDescription = "Tooltip for blacklist setting",
        },
        Setting_CancelWorldTooltipItemPickups_Name = {
           Handle = "hf832b7ceg2e16g454dg8b5cg2ac87a0f7681",
           Text = "Speed up world tooltip item pick-ups",
           ContextDescription = "Setting name",
        },
        Setting_CancelWorldTooltipItemPickups_Description = {
           Handle = "h8277c4cdg8990g406fga0b5gef3f0d386620",
           Text = "If enabled, the animation for picking up items through their world tooltip will be cancelled, allowing multiple items to be picked up faster.",
           ContextDescription = "Setting tooltip",
        },
    },
    Settings = {},

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    SupportedGameStates = _Feature.GAME_STATES.RUNNING_SESSION,

    Hooks = {
        GetDelay = {}, ---@type Event<Feature_AnimationCancelling_Hook_GetDelay>
        IsSkillEligible = {Context = "Client"}, ---@type Event<Feature_AnimationCancelling_Hook_IsSkillEligible>
        IsSkillStateFinished = {}, ---@type Event<Feature_AnimationCancelling_Hook_IsSkillStateFinished>
        CanCancelAnimation = {Context = "Client"}, ---@type Hook<Features.AnimationCancelling.Hooks.CanCancelAnimation>
    }
}
Epip.RegisterFeature("AnimationCancelling", AnimCancel)
local TSK = AnimCancel.TranslatedStrings

---------------------------------------------
-- SETTINGs
---------------------------------------------

AnimCancel.Settings.CancelNPCAnimations = AnimCancel:RegisterSetting("CancelNPCAnimations", {
    Type = "Boolean",
    Context = "Host",
    Name = TSK.Setting_CancelNPCAnimations_Name,
    Description = TSK.Setting_CancelNPCAnimations_Description,
    DefaultValue = false,
})

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_AnimationCancelling_Hook_GetDelay
---@field Character Character
---@field SkillID string? `nil` for non-skill states.
---@field Delay number Hookable. Defaults to 0 seconds.

---Client-only.
---@class Feature_AnimationCancelling_Hook_IsSkillEligible
---@field Character Character
---@field SkillID string
---@field Stat StatsLib_StatsEntry_SkillData
---@field Eligible boolean Hookable. Defaults to true.

---Client-only.
---@class Features.AnimationCancelling.Hooks.CanCancelAnimation
---@field Character EclCharacter
---@field CanCancel boolean Hookable. Defaults to `false`.

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Epip_Feature_AnimationCancelling : NetLib_Message_Character
---@field ActionType ActionStateType
---@field SkillID string? Only for `UseSkill` actions.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the delay for cancelling a state.
---@see Feature_AnimationCancelling_Hook_GetDelay
---@param char Character
---@param state EclActionState|EsvActionState|skill
---@return number -- In seconds.
function AnimCancel.GetDelay(char, state)
    local delay = AnimCancel.DEFAULT_DELAY
    local skillID = type(state) == "string" and state or nil
    if type(state) ~= "string" and state.Type == "UseSkill" then
        if Ext.IsServer() then
            ---@cast state EsvASUseSkill
            skillID = Stats.RemoveLevelSuffix(state.Skill.SkillId)
        else
            skillID = Character.GetCurrentSkill(char)
        end
    end
    delay = AnimCancel.Hooks.GetDelay:Throw({
        Character = char,
        SkillID = skillID,
        Delay = AnimCancel.DEFAULT_DELAY,
    }).Delay
    return delay
end

---@param skillID string
---@param delay number In seconds.
function AnimCancel.SetSkillDelay(skillID, delay)
    AnimCancel.SKILL_DELAYS[skillID] = delay
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Use a time-based delay for certain skills.
AnimCancel.Hooks.GetDelay:Subscribe(function (ev)
    if ev.SkillID then
        local timeDelay = AnimCancel.SKILL_DELAYS[ev.SkillID]
        if timeDelay then
            ev.Delay = timeDelay
        end
    end
end)

-- Delay animation cancelling if the character is at 0AP.
-- Workaround for an issue with executioner where
-- the character's turn can end prematurely.
AnimCancel.Hooks.GetDelay:Subscribe(function (ev)
    local ap, _ = Character.GetActionPoints(ev.Character)
    if ap <= 0 then
        ev.Delay = AnimCancel.DEFAULT_DELAY_NO_AP
    end
end)
