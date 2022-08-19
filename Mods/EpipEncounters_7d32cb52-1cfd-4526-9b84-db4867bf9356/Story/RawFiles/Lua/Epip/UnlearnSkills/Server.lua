
---@class Feature_UnlearnSkills
local Unlearn = Epip.GetFeature("UnlearnSkills")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_UnlearnSkill", function(payload)
    local char = Character.Get(payload.CharacterNetID)
    local skillID = payload.SkillID

    Osiris.CharacterRemoveSkill(char, skillID)
end)