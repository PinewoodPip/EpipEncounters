
local Ascension = Game.Ascension

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Events for characters entering/exiting meditate
Ext.Osiris.RegisterListener("CharacterStatusApplied", 3, "after", function(charGUID, status, _)
    if status ~= Ascension.MEDITATING_STATUS then return end
    Ascension:FireEvent("CharacterToggledMeditating", Character.Get(charGUID), true)
    Net.PostToCharacter(charGUID, "EPIPENCOUNTERS_MeditateStateChanged", {State = true})
end)

Ext.Osiris.RegisterListener("CharacterStatusRemoved", 3, "after", function(charGUID, status, _)
    if status ~= Ascension.MEDITATING_STATUS then return end
    Ascension:FireEvent("CharacterToggledMeditating", Character.Get(charGUID), false)
    Net.PostToCharacter(charGUID, "EPIPENCOUNTERS_MeditateStateChanged", {State = false})
end)