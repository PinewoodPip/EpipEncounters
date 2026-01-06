
local Input = Client.Input
local MessageBox = Client.UI.MessageBox

local ToggleableWorldTooltips = {
    SHOW_WORLD_TOOLTIPS_INPUTEVENTID = 280,
    _LISTENERID_HOLD_KEY = "Features.ToggleableWorldTooltips.HoldKey",
    active = false,
    _WasInDialogue = false,
    _ActiveUponEnteringDialogue = false,
    _IgnoreToggleRequests = false, -- Necessary to prevent stack overflows if the user binds both the vanilla keybind and the toggle keybind to the same key.

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

---Returns whether world tooltips are currently toggled on through this feature.
---@return boolean
function ToggleableWorldTooltips.IsActive()
    return ToggleableWorldTooltips.active
end

---Activates world tooltips.
function ToggleableWorldTooltips._Activate()
    if ToggleableWorldTooltips._IgnoreToggleRequests then return end
    local binding = Input.GetBinding(ToggleableWorldTooltips.SHOW_WORLD_TOOLTIPS_INPUTEVENTID, "Key")

    ToggleableWorldTooltips._IgnoreToggleRequests = true -- Prevent re-entry if both the vanilla & toggle keybinds are bound to the same key.
    Input.Inject("Key", binding.InputID, "Pressed", 1, 1)
    ToggleableWorldTooltips._IgnoreToggleRequests = false

    GameState.Events.Tick:Subscribe(function (_)
        local manager = Ext.Input.GetInputManager()
        local keyboardState = manager.InputStates[manager.PerDeviceData[1].DeviceId + 1] -- Assumes the first device is keyboard - not 100% if this is always the case?
        local numericID = Input.GetRawInputNumericID(binding.InputID)
        local state = keyboardState.Inputs[numericID + 1]

        if ToggleableWorldTooltips.active then
            state.State = "Released" -- Pressed state will not work.
            state.Value = 1
            state.Value2 = 1
        else
            GameState.Events.Tick:Unsubscribe(ToggleableWorldTooltips._LISTENERID_HOLD_KEY)
        end
    end, {StringID = ToggleableWorldTooltips._LISTENERID_HOLD_KEY})

    ToggleableWorldTooltips.active = true
end

---Deactivates world tooltips.
function ToggleableWorldTooltips._Deactivate()
    if ToggleableWorldTooltips._IgnoreToggleRequests then return end
    local manager = Ext.Input.GetInputManager()
    local keyboardState = manager.InputStates[manager.PerDeviceData[1].DeviceId + 1]
    local binding = Input.GetBinding(ToggleableWorldTooltips.SHOW_WORLD_TOOLTIPS_INPUTEVENTID, "Key")
    local numericID = Input.GetRawInputNumericID(binding.InputID)
    local state = keyboardState.Inputs[numericID + 1]

    state.State = "Released"
    state.Value = 0
    state.Value2 = 0

    -- Release by itself is not enough to stop the tooltips from showing;
    -- we must inject the press event as well.
    ToggleableWorldTooltips._IgnoreToggleRequests = true -- Prevent re-entry if both the vanilla & toggle keybinds are bound to the same key.
    Input.Inject("Key", binding.InputID, "Pressed", 1, 1)
    Input.Inject("Key", binding.InputID, "Released", 0, 0)
    ToggleableWorldTooltips._IgnoreToggleRequests = false

    ToggleableWorldTooltips.active = false
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Toggle the feature when the action is executed.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == ToggleableWorldTooltips.INPUT_ACTION then
        local binding = Input.GetBinding(ToggleableWorldTooltips.SHOW_WORLD_TOOLTIPS_INPUTEVENTID, "Key")

        if ToggleableWorldTooltips.active then
            ToggleableWorldTooltips._Deactivate()
        else
            if binding then
                ToggleableWorldTooltips._Activate()
            else -- Show warning that the vanilla key must be bound
                MessageBox.Open({
                    Header = "",
                    Message = ToggleableWorldTooltips.TranslatedStrings.Warning_VanillaKeyNotBound:GetString(),
                })
            end
        end
    end
end)

-- Toggle the feature off upon entering dialogue, and re-enable it afterwards, if it was previously active.
GameState.Events.RunningTick:Subscribe(function (_)
    local inDialogue = Client.IsInDialogue()
    local wasInDialogue = ToggleableWorldTooltips._WasInDialogue

    if inDialogue and not wasInDialogue and ToggleableWorldTooltips.IsActive() then
        ToggleableWorldTooltips._Deactivate()
        ToggleableWorldTooltips._ActiveUponEnteringDialogue = true
    elseif wasInDialogue and not inDialogue and ToggleableWorldTooltips._ActiveUponEnteringDialogue then
        ToggleableWorldTooltips._Activate()
        ToggleableWorldTooltips._ActiveUponEnteringDialogue = false
    end

    ToggleableWorldTooltips._WasInDialogue = inDialogue
end)
