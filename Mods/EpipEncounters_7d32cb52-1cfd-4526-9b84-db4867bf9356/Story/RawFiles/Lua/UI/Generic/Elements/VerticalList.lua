
---@class GenericUI
local Generic = Client.UI.Generic

---@class GenericUI_Element_VerticalList : GenericUI_Element
local VerticalList = {

}
Inherit(VerticalList, Generic._Element)
local _VerticalList = VerticalList

---------------------------------------------
-- METHODS
---------------------------------------------

_VerticalList.Clear = Generic.ExposeFunction("Clear")
_VerticalList.RepositionElements = Generic.ExposeFunction("Reposition")
_VerticalList.SetTopSpacing = Generic.ExposeFunction("SetTopSpacing")
_VerticalList.SetElementSpacing = Generic.ExposeFunction("SetElementSpacing")
_VerticalList.SetSideSpacing = Generic.ExposeFunction("SetSideSpacing")
_VerticalList.SetRepositionAfterAdding = Generic.ExposeFunction("SetRepositionAfterAdding")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("VerticalList", VerticalList)