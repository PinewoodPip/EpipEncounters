
local Input = Client.Input
local MessageBox = Client.UI.MessageBox

local ToggleableWorldTooltips = {
    SHOW_WORLD_TOOLTIPS_INPUTEVENTID = 280,
    _LISTENERID_HOLD_KEY = "Features.ToggleableWorldTooltips.HoldKey",
    active = false,

    TranslatedStrings = {
        Warning_VanillaKeyNotBound = {
            Handle = "hdaeb81edg863bg492cgab09ged3a5d2470d7",
            Text = "Using toggleable world tooltips requires binding the vanilla key for them.",
            ContextDescription = "Message box shown if \"Show World Tooltips\" is not bound in vanilla input menu",
        },
    },

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
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == ToggleableWorldTooltips.INPUT_ACTION then
        local binding = Input.GetBinding(ToggleableWorldTooltips.SHOW_WORLD_TOOLTIPS_INPUTEVENTID, "Key")
        ToggleableWorldTooltips.active = not ToggleableWorldTooltips.active

        -- Send an alt press/release when toggled.
        -- TODO consider modifiers!
        if binding then
            local numericID = Input.GetRawInputNumericID(binding.InputID)

            if ToggleableWorldTooltips:IsEnabled() then
                Input.Inject("Key", binding.InputID, "Pressed", 1, 1)
                GameState.Events.Tick:Subscribe(function (_)
                    local manager = Ext.Input.GetInputManager()
                    local keyboardState = manager.InputStates[manager.PerDeviceData[1].DeviceId + 1] -- Assumes the first device is keyboard - not 100% if this is always the case?

                    local state = keyboardState.Inputs[numericID + 1]
                    if ToggleableWorldTooltips:IsEnabled() then
                        state.State = "Released" -- Pressed state will not work.
                        state.Value = 1
                        state.Value2 = 1
                    else
                        state.State = "Released"
                        state.Value = 0
                        state.Value2 = 0

                        -- Release by itself is not enough to stop the tooltips from showing.
                        Input.Inject("Key", binding.InputID, "Pressed", 1, 1)
                        Input.Inject("Key", binding.InputID, "Released", 0, 0)

                        GameState.Events.Tick:Unsubscribe(ToggleableWorldTooltips._LISTENERID_HOLD_KEY)
                    end
                end, {StringID = ToggleableWorldTooltips._LISTENERID_HOLD_KEY})
            end
        else -- Show warning that the vanilla key must be bound
            MessageBox.Open({
                Header = "",
                Message = ToggleableWorldTooltips.TranslatedStrings.Warning_VanillaKeyNotBound:GetString(),
            })
        end
    end
end)
