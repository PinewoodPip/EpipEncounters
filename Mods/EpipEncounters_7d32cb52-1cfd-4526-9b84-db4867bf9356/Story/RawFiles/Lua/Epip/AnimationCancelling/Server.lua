
---@class Feature_AnimationCancelling
local AnimCancel = Epip.GetFeature("Feature_AnimationCancelling")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for controlled player characters completing spellcasts to notify them that the animation can be cancelled.
Osiris.RegisterSymbolListener("SkillCast", 4, "after", function(charGUID, skillID, _, _)
    local char = Character.Get(charGUID)

    if Character.IsActive(char) then
        Net.PostToCharacter(char, AnimCancel.NET_MESSAGE, {SkillID = skillID, CharacterNetID = charGUID})
    end
end)