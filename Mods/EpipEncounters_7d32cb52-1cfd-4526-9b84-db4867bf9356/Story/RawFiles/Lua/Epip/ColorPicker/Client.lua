
---------------------------------------------
-- Implements a color picker UI.
---------------------------------------------

---@class Features.ColorPicker : Feature
local ColorPicker = {
    _CurrentRequest = nil, ---@type string?

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        ColorRequested = {}, ---@type Event<Features.ColorPicker.Events.ColorRequested>
        RequestCancelled = {}, ---@type Event<{RequestID:string}>
        ColorPicked = {}, ---@type Event<Features.ColorPicker.Events.ColorPicked>
    },
}
Epip.RegisterFeature("Features.ColorPicker", ColorPicker)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.ColorPicker.Events.ColorRequested
---@field RequestID string
---@field DefaultColor RGBColor? The suggested default color for the user.

---@class Features.ColorPicker.Events.ColorPicked
---@field RequestID string
---@field Color RGBColor

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests the user to pick a color.
---@see Features.ColorPicker.Events.ColorRequested
---@param requestID string
---@param defaultColor RGBColor?
function ColorPicker.Request(requestID, defaultColor)
    -- Cancel any previous request.
    if ColorPicker._CurrentRequest then
        ColorPicker.Cancel()
    end

    ColorPicker._CurrentRequest = requestID
    ColorPicker.Events.ColorRequested:Throw({
        RequestID = requestID,
        DefaultColor = defaultColor,
    })
end

---Completes a request.
---@param requestID string
---@param color RGBColor
function ColorPicker.CompleteRequest(requestID, color)
    ColorPicker.Events.ColorPicked:Throw({
        RequestID = requestID,
        Color = color,
    })
    ColorPicker._CurrentRequest = nil
end

---Cancels the current picker request, if any.
function ColorPicker.Cancel()
    ColorPicker.Events.RequestCancelled:Throw({
        RequestID = ColorPicker._CurrentRequest,
    })
    ColorPicker._CurrentRequest = nil
end
