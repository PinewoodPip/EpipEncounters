
local Generic = Client.UI.Generic

---@class GenericUI_Element_Slider : GenericUI_Element
---@field Events GenericUI_Element_Slider_Events
local Slider = {
    Events = {},
}

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_Slider_Events : GenericUI_Element_Events
Slider.Events = {
    HandleReleased = {}, ---@type Event<GenericUI_Element_Slider_Event_HandleReleased>
    HandleMoved = {}, ---@type Event<GenericUI_Element_Slider_Event_HandleMoved>
}
Generic.Inherit(Slider, Generic._Element)

---@class GenericUI_Element_Slider_Event_HandleReleased
---@field Value number

---@class GenericUI_Element_Slider_Event_HandleMoved
---@field Value number

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the current value selected in the slider.
---@return number
function Slider:GetValue()
    return self:GetMovieClip().value
end

---Sets the minimum value accepted by the slider.
---@param min number
function Slider:SetMin(min)
    self:GetMovieClip().minimum = min
end

---Sets the maximum value accepted by the slider.
---@param max number
function Slider:SetMax(max)
    self:GetMovieClip().maximum = max
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Slider", Slider)