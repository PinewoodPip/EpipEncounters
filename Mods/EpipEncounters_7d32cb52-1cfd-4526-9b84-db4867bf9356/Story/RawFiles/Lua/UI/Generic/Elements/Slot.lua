
local Generic = Client.UI.Generic

---@class GenericUI_Element_Slot : GenericUI_Element_IggyIcon
---@field SetCooldown fun(self, cooldown:number, playRefreshAnimation:boolean?)
---@field SetEnabled fun(self, enabled:boolean)
---@field SetLabel fun(self, label:string)
---@field SetSourceBorder fun(self, enabled:boolean)
---@field SetWarning fun(self, enabled:boolean)

---@class GenericUI_Element_Slot
local Slot = {
    Events = { -- TODO improve inheritance
        ---@type SubscribableEvent<GenericUI_Element_Event_MouseUp>
        MouseUp = {},
        ---@type SubscribableEvent<GenericUI_Element_Event_MouseDown>
        MouseDown = {},
        ---@type SubscribableEvent<GenericUI_Element_Event_MouseOver>
        MouseOver = {},
        ---@type SubscribableEvent<GenericUI_Element_Event_MouseOut>
        MouseOut = {},
        ---@type SubscribableEvent<GenericUI_Element_Slot_Event_DragStarted>
        DragStarted = {},
        ---@type SubscribableEvent<GenericUI_Element_Event_Clicked>
        Clicked = {},
    }
}
Inherit(Slot, Generic.ELEMENTS.IggyIcon)

---------------------------------------------
-- EVENTS
---------------------------------------------

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

function Slot:_OnCreation()
    local mc = self:GetMovieClip()

    mc.iggy_mc.y = 1
    mc.iggy_mc.x = 1
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