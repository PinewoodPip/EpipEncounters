
local Generic = Client.UI.Generic

---@class GenericUI_Element_ScrollList : GenericUI_Element_VerticalList
---@field SetFrame fun(self, width:number, height:number)
---@field SetMouseWheelEnabled fun(self, enabled:boolean)
---@field SetScrollbarSpacing fun(self, spacing:number) Must be called after SetFrame. TODO remove restriction
Client.UI.Generic.ELEMENTS.ScrollList = {
    Events = {},
}
local List = Client.UI.Generic.ELEMENTS.ScrollList
Generic.Inherit(List, Generic.ELEMENTS.VerticalList)

---------------------------------------------
-- METHODS
---------------------------------------------

List.SetFrame = Generic.ExposeFunction("SetFrame")
List.SetMouseWheelEnabled = Generic.ExposeFunction("SetMouseWheelEnabled")
List.SetScrollbarSpacing = Generic.ExposeFunction("SetScrollbarSpacing")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("ScrollList", List)