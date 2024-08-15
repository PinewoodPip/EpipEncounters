
---@class GenericUI
local Generic = Client.UI.Generic

---@class GenericUI_Element_Slot : GenericUI_Element
---@field Events GenericUI_Element_Slot_Events
local Slot = {}

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_Slot_Events : GenericUI_Element_Events
Slot.Events = {
    DragStarted = {}, ---@type Event<GenericUI_Element_Slot_Event_DragStarted>
    Clicked = {}, ---@type Event<GenericUI_Element_Event_Clicked>
}
Generic.Inherit(Slot, Generic._Element)

---@class GenericUI_Element_Slot_Event_DragStarted
---@class GenericUI_Element_Event_Clicked

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether the slot is enabled. Disabled slots are greyed out.
---@return boolean
function Slot:IsEnabled()
    return self:GetMovieClip().enabled
end

Slot.SetCooldown = Generic.ExposeFunction("SetCooldown")
Slot.SetEnabled = Generic.ExposeFunction("SetEnabled")
Slot.SetLabel = Generic.ExposeFunction("SetLabel")
Slot.SetSourceBorder = Generic.ExposeFunction("SetSourceBorder")
Slot.SetWarning = Generic.ExposeFunction("SetWarning")
Slot.SetActive = Generic.ExposeFunction("SetActive")
Slot.SetHighlighted = Generic.ExposeFunction("SetHighlighted")

function Slot:_OnCreation()
    local mc = self:GetMovieClip()

    mc.frame_mc.x = -3
    mc.frame_mc.y = -3
    mc.source_frame_mc.x = -3
    mc.source_frame_mc.y = -3
    mc.bg_mc.x = -3
    mc.bg_mc.y = -3
    mc.highlight_mc.x, mc.highlight_mc.y = 1.5, 2
    mc.disable_mc.x, mc.disable_mc.y = 2, 2
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Slot", Slot)