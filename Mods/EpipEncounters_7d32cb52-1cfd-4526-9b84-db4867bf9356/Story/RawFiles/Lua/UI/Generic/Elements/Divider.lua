
---@class GenericUI
local Generic = Client.UI.Generic

---@class GenericUI_Element_Divider : GenericUI_Element
local Divider = {
    ---@enum GenericUI_Element_Divider_Type
    TYPES = {
        ELEGANT = "Elegant",
        LINE = "Line",
        BORDER = "Border",
    },
    Events = {},
}
Generic.Inherit(Divider, Generic._Element)
local _Divider = Divider ---@type GenericUI_Element_Divider Used to workaround an IDE issue with annotations pointing to ExposeFunction().

---------------------------------------------
-- METHODS
---------------------------------------------

_Divider.SetType = Generic.ExposeFunction("SetType")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Divider", Divider)