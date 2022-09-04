
local Input = Client.Input

local ToggleableWorldTooltips = {
    active = false,

    INPUT_ACTION = "EpipEncounters_ToggleWorldTooltips",
}
Epip.RegisterFeature("ToggleableWorldTooltips", ToggleableWorldTooltips)

---------------------------------------------
-- METHODS
---------------------------------------------

function ToggleableWorldTooltips:IsEnabled()
    return ToggleableWorldTooltips.active and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Toggle the feature when the action is performed.
Client.UI.OptionsInput.Events.ActionExecuted:RegisterListener(function (action, _)
    if action == ToggleableWorldTooltips.INPUT_ACTION then
        ToggleableWorldTooltips.active = not ToggleableWorldTooltips.active

        -- Send an alt press/release when toggled.
        if ToggleableWorldTooltips:IsEnabled() then
            Input.Inject("Key", "lalt", "Pressed", 1, 1)
        else
            Input.Inject("Key", "lalt", "Released", 0, 0)
        end
    end
end)

-- Prevent releasing alt while the feature is toggled on.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if ev.InputID == "lalt" and ev.State == "Released" then
        if ToggleableWorldTooltips:IsEnabled() then
            ev:Prevent()
        end
    end
end)