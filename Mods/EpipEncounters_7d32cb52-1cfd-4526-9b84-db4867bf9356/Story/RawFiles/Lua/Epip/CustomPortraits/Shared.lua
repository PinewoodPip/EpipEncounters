
---@class Features.CustomPortraits : Feature
local CustomPortraits = {
    PORTRAIT_SIZE = Vector.Create(80, 100), -- In pixels.

    NETMSG_SET_PORTRAIT = "Features.CustomPortraits.NetMsg.SetPortrait",

    TranslatedStrings = {
        Label_SetPortrait = {
            Handle = "h18a8fee4gdc22g411dgad89ge700c9c0a5d0",
            Text = "Set custom portrait...",
            ContextDescription = [[Context menu option in player portraits UI]],
        },
        Label_ApplyPortrait = {
            Handle = "h9dba55fag87efg4214g9f3egf3fafacc8565",
            Text = "Apply Portrait",
            ContextDescription = [[Button in the Assprite UI]],
        },
        Notification_Load_Error_WrongResolution = {
            Handle = "h17c93d66g67e5g418ag9a0bgf9235674e3f2",
            Text = "Image must be %dx%d pixels.",
            ContextDescription = [[Notification when loading images of wrong resolution. Params are expected image width and height.]],
        },
        MsgBox_NoFork_Title = {
            Handle = "h205ddda8gf9ccg44f1ga215g057d211ad70c",
            Text = "Extender fork required",
            ContextDescription = [[Header for message box when attempting to use the feature without it installed]],
        },
        MsgBox_NoFork_Body = {
            Handle = "h6005d151g64b3g4931gafbegb3ccb14a6754",
            Text = "This feature requires a special version of the script extender:<br>%s",
            ContextDescription = [[Message box when attempting to use the feature without having the extender fork installed. Param is URL to the download site]],
        },
        MsgBox_NotInitialized_Title = {
            Handle = "hb456dc72g31ffg4397g8316gc1340e7ee238",
            Text = "Custom Portraits Unavailable",
            ContextDescription = [[Header for message box when attempting to set a custom portrait for a character that doesn't support them]],
        },
        MsgBox_NotInitialized_Body = {
            Handle = "h42abf938g98bbg4686ga1c2g91a9fe239ea0",
            Text = "Due to technical limitations, this character must use the Magic Mirror at least once for Custom Portraits to be available to them.",
            ContextDescription = [[Message box when attempting to set a custom portrait for a character that doesn't support them]],
        },
    },

}
Epip.RegisterFeature("Features.CustomPortraits", CustomPortraits)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.CustomPortraits.NetMsg.SetPortrait : NetLib_Message_Character
---@field ImageRawData string

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether the feature is supported by the user's extender version.
---@return boolean
function CustomPortraits.IsSupported()
    local isSupported = Ext.Entity.SetPortrait ~= nil -- This function used to be exclusive to the fork.
    return isSupported
end