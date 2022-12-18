
---@class Feature_AnimationCancelling
local AnimCancel = Epip.GetFeature("Feature_AnimationCancelling")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for controlled player characters completing spellcasts.
Osiris.RegisterSymbolListener("PROC_AMER_Spells_SkillCast", 5, "after", function(charGUID, _, _, _, _)
    local char = Character.Get(charGUID)

    if Character.IsActive(char) then
        Net.PostToCharacter(char, AnimCancel.NET_MESSAGE)
    end
end)