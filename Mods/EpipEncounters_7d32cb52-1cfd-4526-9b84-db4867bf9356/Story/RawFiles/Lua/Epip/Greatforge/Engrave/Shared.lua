
---@class Feature_GreatforgeEngrave : Feature
local Engrave = {
    OPTION_ID = "PIP_Engrave",
    NETMSG_ENGRAVE_CONFIRM = "Feature_GreatforgeEngrave_NetMsg_Confirm",
    NETMSG_ENGRAVE_START = "Feature_GreatforgeEngrave_NetMsg_Start",

    TranslatedStrings = {
        Option_Name = {
           Handle = "h66c830b8geefbg42afgb501g0942d3a13036",
           Text = Text.Format("Engrave", {Color = "ebc808"}),
           StringKey = "AMER_UI_Greatforge_Title_PIP_Engrave",
           ContextDescription = "Greatforge option name",
        },
        Option_Description = {
           Handle = "h3a1fa582g7217g4722gbcc5gc835c482d94a",
           Text = Text.Format([[Carve a name onto the item to signify the special bond between yourself and it. <font color="a8a8a8" size="21" face="Averia Serif">Purely cosmetic.</font>]], {Align = "left"}),
           StringKey = "AMER_UI_Greatforge_Desc_PIP_Engrave",
           ContextDescription = "Greatforge option description",
        },
        MsgBox_Title = {
           Handle = "hbe7cf1d7g91cfg4b67g8c53g5b15843eaf46",
           Text = "Engrave Item",
           ContextDescription = "Message box title",
        },
        MsgBox_Body = {
           Handle = "h083f5e98g18e2g4708gae54g82b7697923b0",
           Text = "Choose a name to engrave.",
           ContextDescription = "Message box body",
        },
    }
}
Epip.RegisterFeature("GreatforgeEngrave", Engrave)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Feature_GreatforgeEngrave_NetMsg_Start : NetLib_Message_Character, NetLib_Message_Item

---@class Feature_GreatforgeEngrave_NetMsg_Confirm : NetLib_Message_Item
---@field NewItemName string