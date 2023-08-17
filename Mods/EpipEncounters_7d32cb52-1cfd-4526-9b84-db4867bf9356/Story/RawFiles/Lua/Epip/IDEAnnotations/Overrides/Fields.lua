
---@type table<string, table<string, Features.IDEAnnotations.Function.Parameter>>
local fields = {
    ["EclSkill"] = {
        ["ActiveCooldown"] = {
            Comment = "Cooldown remaining, in seconds.",
        },
        ["CauseListSize"] = {
            Comment = "Amount of external sources of this skill currently active (ex. equipped items or statuses)",
        },
        ["IsActivated"] = {
            Comment = "Whether the skill is learnt.",
        },
        ["IsLearned"] = {
            Comment = "Whether this skill is memorized.",
        },
        ["Type"] = {
            Comment = "Skill archetype.",
        },
    }
}

return fields