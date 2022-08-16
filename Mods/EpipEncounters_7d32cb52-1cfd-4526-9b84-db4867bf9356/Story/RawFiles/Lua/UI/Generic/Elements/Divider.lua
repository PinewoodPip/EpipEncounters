
local Generic = Client.UI.Generic

---@class GenericUI_Element_Divider : GenericUI_Element
---@field SetType fun(self, dividerType:GenericUI_Element_Divider_Type)
---@field SetSize fun(self, width:number) Custom height not currently supported. TODO
Client.UI.Generic.ELEMENTS.Divider = {
    ---@enum GenericUI_Element_Divider_Type
    TYPES = {
        ELEGANT = "Elegant",
        LINE = "Line",
        BORDER = "Border",
    },
    Events = {},
}
local Divider = Generic.ELEMENTS.Divider
Generic.Inherit(Divider, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

Divider.SetType = Generic.ExposeFunction("SetType")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Divider", Divider)