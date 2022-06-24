
---------------------------------------------
-- This scripts implements machine learning and blockchain future-proof macrotechnologies to correct typos while entering character names into the CC UI.
---------------------------------------------
-- Uses TutorialBox
---------------------------------------------

Epip.Features.CharacterCreationTypoFixes = {
    TYPOS = {
        Derby = "It seems you have misspelled your character's name. Did you mean to type 'Bro' instead?",
        Derpy = "It seems you have misspelled your character's name. Did you mean to type 'Derby' instead?",

        Maya = "It seems you have misspelled your anime girlfriend's name. Did you mean to type 'Pipi-chan' instead?",
        Pip = "It seems you have misspelled your anime girlfriend's name. Did you mean to type 'Pipi-chan' instead?",
        ["Red Princess"] = "It seems you have misspelled your anime girlfriend's name. Did you mean to type 'Lusty Argonian Maid' instead?",
        Dragoslava = "It seems you have misspelled your anime girlfriend's name. Did you mean to type 'Dragoslav' instead?",
    }
}
local CharacterCreationTypoFixes = Epip.Features.CharacterCreationTypoFixes

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Listen for entering character name.
Ext.RegisterUITypeCall(Client.UI.Data.UITypes.characterCreation, "handleTextInput", function(ui, method, id, text)

    local ui = TutorialBox.ui
    local root = TutorialBox.root

    local message = CharacterCreationTypoFixes.TYPOS[text]
    
    if message then
        TutorialBox:ShowModal("PIP_MachineLearningTypoFix", {
            header = "TYPO DETECTED",
            description = message,
            checkboxText = "Unsubscribe from newsletter",
            acceptText = "Yep your're right"
        })
    end
end)