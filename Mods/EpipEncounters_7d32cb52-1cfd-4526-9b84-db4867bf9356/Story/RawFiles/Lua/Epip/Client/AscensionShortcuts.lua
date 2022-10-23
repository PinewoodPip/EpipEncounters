
local Shortcuts = {

}
Epip.AddFeature("AscensionShortcuts", "AscensionShortcuts", Shortcuts)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.GameMenu:RegisterHook("CanOpen", function(canOpen)
    if canOpen then
        canOpen = not Game.Ascension.IsMeditating()
    end

    return canOpen
end)

Client.Input.Events.KeyPressed:Subscribe(function (e)
    if e.InputID == "escape" and GameState.GetState() == "Running" and Game.Ascension.IsMeditating() then
        if Settings.GetSettingValue("EpipEncounters", "ESCClosesAmerUI") then
            Net.PostToServer("EPIPENCOUNTERS_Hotkey_Meditate", {
                NetID = Client.GetCharacter().NetID,
            })
        else -- Pop page
            Net.PostToServer("EPIP_AMERUI_GoBack", {NetID = Client.GetCharacter().NetID})
        end
    end
end)