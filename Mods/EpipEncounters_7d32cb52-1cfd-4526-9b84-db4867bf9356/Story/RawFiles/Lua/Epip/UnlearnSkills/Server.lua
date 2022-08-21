
---@class Feature_UnlearnSkills
local Unlearn = Epip.GetFeature("UnlearnSkills")

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EsvCharacter
---@param skillID string
function Unlearn.UnlearnSkill(char, skillID)
    Osiris.CharacterRemoveSkill(char, skillID)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_UnlearnSkill", function(payload)
    local char = Character.Get(payload.CharacterNetID)
    local skillID = payload.SkillID

    Unlearn.UnlearnSkill(char, skillID)
end)