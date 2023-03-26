
local Hotbar = Client.UI.Hotbar

---@class Feature_HotbarPresistence
local HotbarPersistence = Epip.GetFeature("Feature_HotbarPersistence")

---------------------------------------------
-- METHODS
---------------------------------------------

function HotbarPersistence.LoadStates()
    local chars = Character.GetPartyMembers(Client.GetCharacter())

    for _,char in ipairs(chars) do
        HotbarPersistence.LoadState(char)
    end
end

---Loads the saved hotbar state for a character.
---@param char EclCharacter
function HotbarPersistence.LoadState(char)
    local savedState = HotbarPersistence.GetSavedState(char)

    if savedState then
        HotbarPersistence:DebugLog("Restoring state for", char.DisplayName)
        Hotbar.SetState(char, savedState)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for hotbar state changing to save it to user vars.
Hotbar.Events.StateChanged:Subscribe(function (ev)
    HotbarPersistence:DebugLog("Hotbar state changed for", ev.Character.DisplayName)

    HotbarPersistence:SetUserVariable(ev.Character, HotbarPersistence.USERVAR_HOTBAR_STATE, ev.State)
end)

GameState.Events.GameReady:Subscribe(function (_)
    HotbarPersistence.LoadStates()
end)

Ext.Events.ResetCompleted:Subscribe(function (_)
    HotbarPersistence.LoadStates()
end)