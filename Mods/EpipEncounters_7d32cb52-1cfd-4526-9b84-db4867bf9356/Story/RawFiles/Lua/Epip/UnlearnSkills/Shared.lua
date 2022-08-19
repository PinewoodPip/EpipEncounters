
---@class Feature_UnlearnSkills : Feature
local Unlearn = {
    BLOCKED_SKILLS = {
        Summon_Cat = true,
        Shout_NexusMeditate = true,
        Shout_SourceInfusion = true,
    }
}
Epip.RegisterFeature("UnlearnSkills", Unlearn)