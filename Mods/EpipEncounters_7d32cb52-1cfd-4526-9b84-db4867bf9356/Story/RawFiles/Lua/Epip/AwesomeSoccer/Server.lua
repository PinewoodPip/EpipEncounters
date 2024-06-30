
---------------------------------------------
-- Server scripting for the Awesome Soccer minigame.
---------------------------------------------

local Soccer = {
    -- RootTemplate that opens the UI when interacted with.
    TEMPLATE = "PIP_MISC_AwesomeSoccerball_00c11ea6-27af-40d7-b169-c6f9d64c5d3c",
}
Epip.RegisterFeature("AwesomeSoccer", Soccer)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open the UI when interacting with a compatible item.
Ext.Osiris.RegisterListener("CharacterUsedItemTemplate", 3, "after", function(char, template, _)
    if template == Soccer.TEMPLATE then
        Net.PostToCharacter(char, "EPIPENCOUNTERS_OpenSoccer")
        Osi.CharacterPlayHUDSound(char, "Item_Generic_Use")
    end
end)