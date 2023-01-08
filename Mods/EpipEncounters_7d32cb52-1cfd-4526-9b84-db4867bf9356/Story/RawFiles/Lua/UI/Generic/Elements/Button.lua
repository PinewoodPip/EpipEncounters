
local Generic = Client.UI.Generic

---@class GenericUI_Element_Button : GenericUI_Element
---@field Events GenericUI_Element_Button_Events
local Button = {
    TYPES = {
        BROWN = "Brown",
        RED = "Red",
        RED_BIG = "RedBig",
        TEXT_EDIT = "TextEdit",
        STAT_MINUS = "StatMinus",
        STAT_PLUS = "StatPlus",
        CLOSE = "Close",
    },
}
local _Button = Button ---@type GenericUI_Element_Button Used to workaround an IDE issue with annotations pointing to ExposeFunction().

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_Button_Events : GenericUI_Element_Events
Button.Events = {
    Pressed = {}, ---@type Event<GenericUI_Element_Button_Event_Pressed>
}
Generic.Inherit(Button, Generic._Element)

---@class GenericUI_Element_Button_Event_Pressed

---------------------------------------------
-- METHODS
---------------------------------------------

_Button.SetText = Generic.ExposeFunction("SetText")
_Button.SetType = Generic.ExposeFunction("SetType")
_Button.SetEnabled = Generic.ExposeFunction("SetEnabled")
_Button.IsEnabled = Generic.ExposeFunction("GetEnabled")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Button", Button)