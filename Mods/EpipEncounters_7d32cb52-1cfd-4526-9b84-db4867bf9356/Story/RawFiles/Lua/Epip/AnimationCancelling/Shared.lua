
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_AnimationCancelling : Feature
local AnimCancel = {
    NET_MESSAGE = "Epip_Feature_AnimationCancelling",
    NETMSG_ITEM_PICKUP = "Epip_Feature_AnimationCancelling_ItemPickUpEntered", -- Empty message.
    DEFAULT_DELAY = 0.05, -- In seconds.
    PING_DELAY = 2, -- In ticks.

    ---@type table<string, number> Delays for cancelling specific skills, in seconds.
    SKILL_DELAYS = {},
    BANNED_ARCHETYPES = Set.Create({}), ---@type DataStructures_Set<SkillType> Add archetypes (ex. "Jump") to prevent them from being animation-cancelled.
    BANNED_SKILLS = Set.Create({}), ---@type DataStructures_Set<skill> Add skills to prevent them from being animation-cancelled.

    TranslatedStrings = {
        Setting_Enabled_Name = {
           Handle = "h3bf7ae10g24e1g4f50gbc69g71a8b95b1a51",
           Text = "Animation Cancelling",
           ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
           Handle = "he5c3a752gd8bag48fagb611g35b5d23bef9d",
           Text = "If enabled, your controlled character's skill animations will be cancelled after their effects execute, allowing you to perform consecutive actions quicker.",
           ContextDescription = "Setting tooltip",
        },
        Blacklist_Name = {
           Handle = "ha50d50eag4185g4e10g82fdg19548a304b32",
           Text = "Blacklisted Skills",
           ContextDescription = "Name for blacklist setting",
        },
        Blacklist_Description = {
           Handle = "he043b9f9gfc52g4c39ga4f1gc53ea4fcd5ce",
           Text = "Add skill IDs to this setting to blacklist them from being animation-cancelled.",
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
        IsSkillEligible = {}, ---@type Event<Feature_AnimationCancelling_Hook_IsSkillEligible>
        IsSkillStateFinished = {}, ---@type Event<Feature_AnimationCancelling_Hook_IsSkillStateFinished>
    }
}
Epip.RegisterFeature("AnimationCancelling", AnimCancel)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_AnimationCancelling_Hook_GetDelay
---@field Character Character
---@field SkillID string
---@field Delay number Hookable. Defaults to 0 seconds.

---@class Feature_AnimationCancelling_Hook_IsSkillEligible
---@field Character Character
---@field SkillID string
---@field Stat StatsLib_StatsEntry_SkillData
---@field Eligible boolean Hookable. Defaults to true.

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Epip_Feature_AnimationCancelling : NetLib_Message_Character
---@field SkillID string

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char Character
---@param skillID string
---@return number -- In seconds.
function AnimCancel.GetDelay(char, skillID)
    local hook = AnimCancel.Hooks.GetDelay:Throw({
        Character = char,
        SkillID = skillID,
        Delay = AnimCancel.DEFAULT_DELAY,
    })

    return hook.Delay
end

---@param skillID string
---@param delay number In seconds.
function AnimCancel.SetSkillDelay(skillID, delay)
    AnimCancel.SKILL_DELAYS[skillID] = delay
end

---@param char Character
---@param skillID string
---@return boolean
function AnimCancel.IsEligible(char, skillID)
    local hook = AnimCancel.Hooks.IsSkillEligible:Throw({
        Character = char,
        SkillID = skillID,
        Stat = Stats.Get("SkillData", skillID),
        Eligible = true,
    })

    return hook.Eligible
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Use a time-based delay for certain skills.
AnimCancel.Hooks.GetDelay:Subscribe(function (ev)
    local timeDelay = AnimCancel.SKILL_DELAYS[ev.SkillID]

    if timeDelay then
        ev.Delay = timeDelay
    end
end)

-- Apply skill and archetype blacklists.
AnimCancel.Hooks.IsSkillEligible:Subscribe(function (ev)
    local skillID = ev.SkillID
    local stat = ev.Stat
    if AnimCancel.BANNED_SKILLS:Contains(skillID) or AnimCancel.BANNED_ARCHETYPES:Contains(stat.SkillType) then
        ev.Eligible = false
    end
end)
