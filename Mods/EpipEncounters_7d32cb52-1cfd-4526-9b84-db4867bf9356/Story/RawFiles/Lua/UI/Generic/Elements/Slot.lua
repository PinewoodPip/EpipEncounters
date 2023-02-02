
local Generic = Client.UI.Generic

---@class GenericUI_Element_Slot : GenericUI_Element
---@field Events GenericUI_Element_Slot_Events
local Slot = {
    
}

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
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------



---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Slot", Slot)