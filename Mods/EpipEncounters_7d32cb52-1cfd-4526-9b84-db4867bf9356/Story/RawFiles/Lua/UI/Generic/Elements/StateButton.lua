
local Generic = Client.UI.Generic

---@class GenericUI_Element_StateButton : GenericUI_Element
---@field Events GenericUI_Element_StateButton_Events
local StateButton = {
    ---@enum GenericUI_Element_StateButton_Type
    TYPES = {
        CHECKBOX = "CheckBox",
        LOCK = "Lock",
    },
}
local _StateButton = StateButton

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_StateButton_Events : GenericUI_Element_Events
StateButton.Events = {
    StateChanged = {}, ---@type Event<GenericUI_Element_StateButton_Event_StateChanged>
}
Generic.Inherit(StateButton, Generic._Element)

---@class GenericUI_Element_StateButton_Event_StateChanged
---@field Active boolean

---------------------------------------------
-- METHODS
---------------------------------------------

_StateButton.SetType = Generic.ExposeFunction("SetType")
_StateButton.SetActive = Generic.ExposeFunction("SetActiveState")
_StateButton.SetEnabled = Generic.ExposeFunction("SetEnabledState")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("StateButton", StateButton)