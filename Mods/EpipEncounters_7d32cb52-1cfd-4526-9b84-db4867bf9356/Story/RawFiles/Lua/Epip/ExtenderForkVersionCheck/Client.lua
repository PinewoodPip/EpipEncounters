
---------------------------------------------
-- Verifies the version of the extender fork (if installed)
-- is high enough for this version of Epip,
-- and shows an error message to the user otherwise.
---------------------------------------------

---@type Feature
local VersionCheck = {
    TranslatedStrings = {
        Msg_OutdatedVersion = {
            Handle = "hc727866cg72b4g4e07gaa98g6c027a0c266f",
            Text = "Using Pip's Extender fork with this version of Epip requires a newer version of the fork; you have v%d, required is v%d+. Update it by redownloading it from the site.<br>https://www.pinewood.team/epip/extender",
            ContextDescription = [[Error message box. Params are current and required version numbers]],
        },
    },
}
Epip.RegisterFeature("Features.ExtenderForkVersionCheck", VersionCheck)

-- Verify fork version is up to date.
-- Done at root level to happen as soon as possible, even in main menu.
if Epip.IsPipFork() and Epip.GetPipForkVersion() < Epip.MIN_PIP_FORK_VERSION then
    Ext.Utils.ShowErrorAndExitGame(VersionCheck.TranslatedStrings.Msg_OutdatedVersion:Format(Epip.GetPipForkVersion(), Epip.MIN_PIP_FORK_VERSION))
end
