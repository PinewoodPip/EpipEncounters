
local Generic = Client.UI.Generic

---@class GenericUI_Element_VerticalList : GenericUI_Element
---@field Clear fun() Removes all elements from the list.
---@field RepositionElements fun() Recalculates the positions of the list's elements.
---@field SetTopSpacing fun(self, spacing:number)
---@field SetElementSpacing fun(self, spacing:number)
---@field SetSideSpacing fun(self, spacing:number)

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
List.SetTopSpacing = Generic.ExposeFunction("SetTopSpacing")
List.SetElementSpacing = Generic.ExposeFunction("SetElementSpacing")
List.SetSideSpacing = Generic.ExposeFunction("SetSideSpacing")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("VerticalList", List)