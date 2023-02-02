
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_AnimationCancelling : Feature
local AnimCancel = {
    NET_MESSAGE = "Epip_Feature_AnimationCancelling",
    DEFAULT_DELAY = 2, -- In ticks.

    ---@type table<string, number> Delay for specific skills - in seconds!.
    SKILL_DELAYS = {
        ["Projectile_StaffOfMagus"] = 0.5,
        ["Projectile_Multishot"] = 0.5,
    },
    BANNED_ARCHETYPES = Set.Create({
        "ProjectileStrike",
        "MultiStrike",
        "Jump",
    }),
    BANNED_SKILLS = Set.Create({
        "Projectile_Flight",
        "Projectile_ArrowSpray",
        "Target_DualWieldingAttack",
        "Target_Flurry",
        "Target_DaggersDrawn",
    }),

    TranslatedStrings = {
        Setting_Name = {
           Handle = "h3bf7ae10g24e1g4f50gbc69g71a8b95b1a51",
           Text = "Animation Cancelling",
           ContextDescription = "Setting name",
        },
        Setting_Tooltip = {
           Handle = "he5c3a752gd8bag48fagb611g35b5d23bef9d",
           Text = "Cancels your controlled character's spell animations after their effects execute.\n\n%s",
           ContextDescription = "Setting tooltip",
        },
        Setting_Warning = {
           Handle = "he9f82492g81f0g4e53g9eefg731a6f800db8",
           Text = "Experimental! May cause issues with certain skills. Please report any!",
           ContextDescription = "Setting warning",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetDelay = {}, ---@type Event<Feature_AnimationCancelling_Hook_GetDelay>
        IsSkillEligible = {}, ---@type Event<Feature_AnimationCancelling_Hook_IsSkillEligible>
    }
}
Epip.RegisterFeature("AnimationCancelling", AnimCancel)

---------------------------------------------
-- SETTINGS
---------------------------------------------

AnimCancel:RegisterSetting("Enabled", {
    Type = "Boolean",
    NameHandle = AnimCancel.TranslatedStrings.Setting_Name,
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

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Epip_Feature_AnimationCancelling : NetMessage
---@field SkillID string

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
---@field Stat StatsLib_Stat_Skill
---@field Eligible boolean Hookable. Defaults to true.

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
        Delay = 0,
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

-- Ban skills with certain keywords or archetypes.
AnimCancel.Hooks.IsSkillEligible:Subscribe(function (ev)
    local skillID = ev.SkillID
    local stat = ev.Stat

    if AnimCancel.BANNED_SKILLS:Contains(skillID) or AnimCancel.BANNED_ARCHETYPES:Contains(stat.SkillType) then
        ev.Eligible = false
    end
end)