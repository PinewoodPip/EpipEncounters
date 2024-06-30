
local Ascension = Game.Ascension

function StartGreatforge(char, item)
    local instance = Osi.DB_AMER_UI_UsersInUI:Get(nil, nil, char.MyGuid)[1][1]
    local map = Osi.DB_CurrentLevel:Get(nil)[1][1]
    Osi.QRY_AMER_UI_Greatforge_GetCraftObject(instance, char.MyGuid, map)

    local craftingObj = Osi.DB_AMER_UI_Greatforge_CraftObject_Reserved:Get(nil, nil)[1][2]

    Osi.DB_AMER_GEN_OUTPUT_Item:Delete(nil)
    Osi.DB_AMER_GEN_OUTPUT_Item(item.MyGuid)
    Osi.PROC_AMER_UI_Greatforge_ProcessCombine(char.MyGuid, 1)
end

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