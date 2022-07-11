
local Generic = Client.UI.Generic

---@class GenericUI_Element_Divider : GenericUI_Element
---@field SetType fun(self, dividerType:integer)
---@field SetSize fun(self, width:number) Custom height not currently supported. TODO
---@field TYPES table<string, integer>

---@type GenericUI_Element_Divider
Client.UI.Generic.ELEMENTS.Divider = {
    BACKGROUND_TYPES = {
        BOX = 0,
        BLACK = 1,
    }
}
local Divider = Generic.ELEMENTS.Divider
Inherit(Divider, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

Divider.SetType = Generic.ExposeFunction("SetType")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Divider", Divider)