
local Shortcuts = Epip.GetFeature("Feature_AscensionShortcuts")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for escape key being pressed.
Client.Input.Events.KeyPressed:Subscribe(function (e)
    if e.InputID == "escape" and GameState.GetState() == "Running" and Game.Ascension.IsMeditating() then
        if Settings.GetSettingValue("EpipEncounters", "ESCClosesAmerUI") then
            Net.PostToServer("EPIPENCOUNTERS_Hotkey_Meditate", {
                NetID = Client.GetCharacter().NetID,
            })
        else -- Pop page
            Net.PostToServer(Shortcuts.POP_PAGE_NET_MSG, {CharacterNetID = Client.GetCharacter().NetID})
        end
    end
end)

-- Prevent the game menu from showing up. We want our escape press to be "consumed".
Client.UI.GameMenu:RegisterHook("CanOpen", function(canOpen)
    if canOpen then
        canOpen = not Game.Ascension.IsMeditating()
    end

    return canOpen
end)