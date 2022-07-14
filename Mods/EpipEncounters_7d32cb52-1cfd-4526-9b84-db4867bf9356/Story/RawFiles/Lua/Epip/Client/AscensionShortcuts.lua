
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

Ext.Events.InputEvent:Subscribe(function(ev)
    if ev.Event.EventId == 223 and ev.Event.Release and not Client.IsUsingController() and Game.Ascension.IsMeditating() then
        if Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "ESCClosesAmerUI") then
            Net.PostToServer("EPIPENCOUNTERS_Hotkey_Meditate", {
                NetID = Client.GetCharacter().NetID,
            })
        else -- Pop page
            Net.PostToServer("EPIP_AMERUI_GoBack", {NetID = Client.GetCharacter().NetID})
        end
    end
end)