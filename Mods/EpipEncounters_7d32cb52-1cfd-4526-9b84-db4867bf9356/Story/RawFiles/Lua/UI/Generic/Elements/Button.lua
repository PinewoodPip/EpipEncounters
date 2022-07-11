
local Generic = Client.UI.Generic

---@class GenericUI_Element_Button : GenericUI_Element
---@field SetText fun(self, text:string)
---@field SetType fun(self, buttonType:integer)
---@field SetEnabled fun(self, enabled:boolean)
---@field IsEnabled fun(self):boolean

---@type GenericUI_Element_Button
Client.UI.Generic.ELEMENTS.Button = {
    TYPES = {
        BROWN = 0,
        RED = 1,
        RED_BIG = 2,
        TEXT_EDIT = 3,
        STAT_MINUS = 4,
        STAT_PLUS = 5,
        CLOSE = 6,
    },
    EVENT_TYPES = {
        PRESSED = "Button_Pressed",
    },
}
local Button = Client.UI.Generic.ELEMENTS.Button
Inherit(Button, Generic._Element)

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