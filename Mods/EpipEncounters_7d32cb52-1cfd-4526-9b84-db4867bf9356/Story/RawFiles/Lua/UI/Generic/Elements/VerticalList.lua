
local Generic = Client.UI.Generic

---@class GenericUI_Element_VerticalList : GenericUI_Element
---@field Clear fun() Removes all elements from the list.
---@field RepositionElements fun() Recalculates the positions of the list's elements.

---@type GenericUI_Element_VerticalList
Client.UI.Generic.ELEMENTS.VerticalList = {

}
local List = Client.UI.Generic.ELEMENTS.VerticalList
Inherit(List, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

List.Clear = Generic.ExposeFunction("Clear")
List.RepositionElements = Generic.ExposeFunction("Reposition")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("VerticalList", List)