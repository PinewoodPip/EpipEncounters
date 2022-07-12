
local Generic = Client.UI.Generic

---@class GenericUI_Element_ScrollList : GenericUI_Element_VerticalList
---@field SetFrame fun(self, width:number, height:number)
---@field SetMouseWheenEnabled fun(self, enabled:boolean)
---@field SetScrollbarSpacing fun(self, spacing:number) Must be called after SetFrame. TODO remove restriction

---@type GenericUI_Element_ScrollList
Client.UI.Generic.ELEMENTS.ScrollList = {

}
local List = Client.UI.Generic.ELEMENTS.ScrollList
Inherit(List, Generic.ELEMENTS.VerticalList)

---------------------------------------------
-- METHODS
---------------------------------------------

List.SetFrame = Generic.ExposeFunction("SetFrame")
List.SetMouseWheenEnabled = Generic.ExposeFunction("SetMouseWheenEnabled")
List.SetScrollbarSpacing = Generic.ExposeFunction("SetScrollbarSpacing")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("ScrollList", List)