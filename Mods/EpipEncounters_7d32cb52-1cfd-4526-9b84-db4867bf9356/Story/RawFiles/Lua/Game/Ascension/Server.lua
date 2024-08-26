
local Ascension = Game.Ascension

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Events for characters entering/exiting meditate
Ext.Osiris.RegisterListener("CharacterStatusApplied", 3, "after", function(char, status, _)
    if status ~= Ascension.MEDITATING_STATUS then return end

    Ascension:FireEvent("CharacterToggledMeditating", Ext.GetCharacter(char), true)
    Net.PostToCharacter(char, "EPIPENCOUNTERS_MeditateStateChanged", {State = true})
end)

Ext.Osiris.RegisterListener("CharacterStatusRemoved", 3, "after", function(char, status, _)
    if status ~= Ascension.MEDITATING_STATUS then return end

    Ascension:FireEvent("CharacterToggledMeditating", Ext.GetCharacter(char), false)
    Net.PostToCharacter(char, "EPIPENCOUNTERS_MeditateStateChanged", {State = false})
end)