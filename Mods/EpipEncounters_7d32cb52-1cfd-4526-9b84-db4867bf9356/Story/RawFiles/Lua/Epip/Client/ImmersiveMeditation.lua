
---------------------------------------------
-- Toggles the minimap and hotbar UIs
-- while the client is Meditating.
---------------------------------------------
local IM = {
    currentState = false,
}
local Ascension = Game.Ascension
Epip.AddFeature("ImmersiveMeditation", "ImmersiveMeditation", IM)

function IM.Update()
    if Client.IsUsingController() then return nil end
    local state = IM:ReturnFromHooks("GetState", false)

    if state == IM.currentState then return nil end

    IM.currentState = state

    if state then
        Client.UI.Minimap:Toggle(false, false)
        Client.UI.Hotbar.ToggleVisibility(false, "PIP_ImmersiveMeditation")
        Client.UI.StatusConsole.Toggle(false, "PIP_ImmersiveMeditation")
    else
        Client.UI.Hotbar.ToggleVisibility(true, "PIP_ImmersiveMeditation")
        Client.UI.StatusConsole.Toggle(true, "PIP_ImmersiveMeditation")

        -- Restore visibility based on settings.
        Client.UI.Minimap:ToggleFromSettings()
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Enable when we're in Ascension. Never enable immersive meditation if the option is off.
IM:RegisterHook("GetState", function(enabled)
    if not enabled and Game.AMERUI.ClientIsInUI() and Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "ImmersiveMeditation") and IM:IsEnabled() then
        enabled = true
    end

    return enabled
end)

-- Update state when client toggles meditation, the hotbar refreshes or the game is unpaused. The hotbar listener is needed for unpause
Ascension:RegisterListener("ClientToggledMeditating", function(state)
    IM.Update()
end)

Client.UI.Hotbar:RegisterListener("Refreshed", function()
    IM.Update()
end)

-- No timer necessary!
Utilities.Hooks.RegisterListener("GameState", "GameUnpaused", function()
    IM.Update()
end)