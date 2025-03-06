
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
        Notification_Load_Error_WrongResolution = {
            Handle = "h17c93d66g67e5g418ag9a0bgf9235674e3f2",
            Text = "Image must be %dx%d pixels.",
            ContextDescription = [[Notification when loading images of wrong resolution. Params are expected image width and height.]],
        },
    },

}
Epip.RegisterFeature("Features.CustomPortraits", CustomPortraits)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.CustomPortraits.NetMsg.SetPortrait : NetLib_Message_Character
---@field ImageRawData string
