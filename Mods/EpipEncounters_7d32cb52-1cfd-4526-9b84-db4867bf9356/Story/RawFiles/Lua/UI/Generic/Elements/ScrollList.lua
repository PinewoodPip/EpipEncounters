
local Generic = Client.UI.Generic

---@class GenericUI_Element_ScrollList : GenericUI_Element_VerticalList
local ScrollList = {
    Events = {},
}
Generic.Inherit(ScrollList, Generic.ELEMENTS.VerticalList)

---------------------------------------------
-- METHODS
---------------------------------------------

ScrollList.SetFrame = Generic.ExposeFunction("SetFrame")
ScrollList.SetMouseWheelEnabled = Generic.ExposeFunction("SetMouseWheelEnabled")
ScrollList.SetScrollbarSpacing = Generic.ExposeFunction("SetScrollbarSpacing")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("ScrollList", ScrollList)