
local Generic = Client.UI.Generic

---@class GenericUI_Element_StateButton : GenericUI_Element
---@field SetType fun(self, buttonType:GenericUI_Element_StateButton_Type)
---@field SetActive fun(self, active:boolean) Will not fire the StateChanged event.
---@field SetEnabled fun(self, enabled:boolean)
---@field Events GenericUI_Element_StateButton_Events
Client.UI.Generic.ELEMENTS.StateButton = {
    ---@enum GenericUI_Element_StateButton_Type
    TYPES = {
        CHECKBOX = "CheckBox",
        LOCK = "Lock",
    },
}
local Button = Client.UI.Generic.ELEMENTS.StateButton

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_StateButton_Events : GenericUI_Element_Events
Button.Events = {
    StateChanged = {}, ---@type SubscribableEvent<GenericUI_Element_StateButton_Event_StateChanged>
}
Generic.Inherit(Button, Generic._Element)

---@class GenericUI_Element_StateButton_Event_StateChanged
---@field Active boolean

---------------------------------------------
-- METHODS
---------------------------------------------

Button.SetType = Generic.ExposeFunction("SetType")
Button.SetActive = Generic.ExposeFunction("SetActiveState")
Button.SetEnabled = Generic.ExposeFunction("SetEnabledState")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("StateButton", Button)