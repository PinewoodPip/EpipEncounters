
---------------------------------------------
-- Displays a warning about Epip's lack of splitscreen support.
---------------------------------------------

local MsgBoxC = Client.UI.Controller.MessageBox

---@type Feature
local Warning = {
    TranslatedStrings = {
        MsgBox_Warning_Body = {
            Handle = "h1193ef69g784ag4286ga539g154b40c7db32",
            Text = "Epip does not currently support local co-op. Most features will not work correctly or only work for the first player. It is recommended to disable the mod.",
            ContextDescription = [[Message box when starting splitscreen]],
        },
    },
}
Epip.RegisterFeature("Features.LocalCoopSupportWarning", Warning)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show warning when local co-op starts.
Client.Events.LocalCoopStarted:Subscribe(function (_)
    MsgBoxC.Open({
        Header = Text.CommonStrings.Warning,
        Body = Warning.TranslatedStrings.MsgBox_Warning_Body,
    })
end, {EnabledFunctor = function ()
    return not Epip.IsDeveloperMode(true) and GameState.IsInSession() -- The message box will get stuck if opened while loading (ex. reloading while in local co-op). Don't show this message while working on the mod itself.
end})
