
local PlayerInfo = Client.UI.PlayerInfo
local CharacterSheet = Client.UI.CharacterSheet

---@class Feature_SummonControlFix : Feature
local Fix = {
    ignoreNextSelect = false,

    CHARACTER_SWITCH_INPUT_EVENTS = {
        [218] = true,
        [219] = true,
    }
}
Epip.AddFeature("SummonControlFix", "SummonControlFix", Fix)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

CharacterSheet:RegisterCallListener("selectCharacter", function(_, _)
    Fix.ignoreNextSelect = true
end)

Ext.Events.InputEvent:Subscribe(function(ev)
    local inputEvent = ev.Event

    if Fix.CHARACTER_SWITCH_INPUT_EVENTS[inputEvent.EventId] then
        Fix.ignoreNextSelect = true
    end
end)

-- Listen for turn being ended. We have to ignore next swap since Client.IsActiveCombatant() is not currently 100% reliable.
Client.UI.StatusConsole.Events.TurnEnded:Subscribe(function (_)
    Fix:DebugLog("End Turn requested")

    Fix.ignoreNextSelect = true
end)

PlayerInfo.Events.ActiveCharacterChanged:Subscribe(function (e)
    local newChar = e.NewCharacter
    local prevChar = e.PreviousCharacter

    -- Ignore manual character changes
    if newChar and prevChar and not e.Manual and not Fix.ignoreNextSelect then

        -- Only swap if it is not the new char's turn
        if Client.IsInCombat() and not Client.IsActiveCombatant() then
            local previousCharacter = Character.Get(prevChar.Handle)

            Fix:DebugLog("Restoring control to previous character", previousCharacter.DisplayName)

            PlayerInfo.SelectCharacter(previousCharacter.Handle)
        end
    end

    Fix.ignoreNextSelect = false
end)