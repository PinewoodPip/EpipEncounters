
---@class Feature_GreatforgeEngrave : Feature
local Engrave = {
    OPTION_ID = "PIP_Engrave",
    OPTION_NAME = Text.Format("Engrave", {Color = "ebc808", Size = 30}),
    OPTION_DESCRIPTION = Text.Format("Carve a name onto the item to signify the special bond between yourself and it.<br><font color=\"a8a8a8\" size=\"21\" face=\"Averia Serif\">Purely cosmetic.</font>", {}),
}
Epip.AddFeature("GreatforgeEngrave", "GreatforgeEngrave", Engrave)

---------------------------------------------
-- SETUP
---------------------------------------------

-- TODO make localizable
Ext.L10N.CreateTranslatedString("AMER_UI_Greatforge_Title_PIP_Engrave", Engrave.OPTION_NAME)
Ext.L10N.CreateTranslatedString("AMER_UI_Greatforge_Desc_PIP_Engrave", Engrave.OPTION_DESCRIPTION)