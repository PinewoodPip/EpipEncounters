
---------------------------------------------
-- Displays notices about festivities active when loading into a session.
---------------------------------------------

local MsgBox = Client.UI.MessageBox

---@type Feature
local FestivityNotifications = {
    TranslatedStrings = {
        MsgBox_Anniversary_Header = {
            Handle = "h63ffc273ga432g42ebga967g68305f09a451",
            Text = "It's Epiparty time!",
            ContextDescription = [[Message box header when loading into a session during Epip's anniversary]],
        },
        MsgBox_Anniversary_Body = {
            Handle = "ha8a2bad0gddadg4a92ga719gf1a688511678",
            Text = "It's Epip's Anniversary today! Party mode will be on today; watch out for mischievous shenanigans!",
            ContextDescription = [[Message box when loading into a session during Epip's anniversary]],
        },
    }
}
Epip.RegisterFeature("Features.FestivityNotifications", FestivityNotifications)
local TSK = FestivityNotifications.TranslatedStrings

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show anniversary message box when loading into a session.
GameState.Events.ClientReady:Subscribe(function (_)
    MsgBox.Open({
        Header = TSK.MsgBox_Anniversary_Header:GetString(),
        Message = TSK.MsgBox_Anniversary_Body:GetString(),
    })
end, {EnabledFunctor = function ()
    return Epip.IsAprilFools()
end})
