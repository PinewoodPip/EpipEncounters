
local Generic = Client.UI.Generic

---@class GenericUI_Element_Button : GenericUI_Element
---@field SetText fun(self, text:string, textY:number?)
---@field SetType fun(self, buttonType:"Brown"|"Red"|"RedBig"|"TextEdit"|"StatMinus"|"StatPlus"|"Close")
---@field SetEnabled fun(self, enabled:boolean)
---@field IsEnabled fun(self):boolean
---@field Events GenericUI_Element_Button_Events
Client.UI.Generic.ELEMENTS.Button = {
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
local Button = Client.UI.Generic.ELEMENTS.Button ---@class GenericUI_Element_Button

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GenericUI_Element_Button_Events : GenericUI_Element_Events
Button.Events = {
    Pressed = {}, ---@type SubscribableEvent<GenericUI_Element_Button_Event_Pressed>
}
Generic.Inherit(Button, Generic._Element)

---@class GenericUI_Element_Button_Event_Pressed

---------------------------------------------
-- METHODS
---------------------------------------------

Button.SetText = Generic.ExposeFunction("SetText")
Button.SetType = Generic.ExposeFunction("SetType")
Button.SetEnabled = Generic.ExposeFunction("SetEnabled")
Button.IsEnabled = Generic.ExposeFunction("GetEnabled")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Button", Button)