
local Generic = Client.UI.Generic

---@class GenericUI_Element_StateButton : GenericUI_Element
---@field SetType fun(self, buttonType:integer)
---@field SetActive fun(self, active:boolean) Will not fire the StateChanged event.
---@field SetEnabled fun(self, enabled:boolean)

---@type GenericUI_Element_StateButton
Client.UI.Generic.ELEMENTS.StateButton = {
    TYPES = {
        CHECKBOX = 0,
        LOCK = 1,
    },
    EVENT_TYPES = {
        STATE_CHANGED = "StateButton_StateChanged",
    },
}
local Button = Client.UI.Generic.ELEMENTS.StateButton
Inherit(Button, Generic._Element)

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