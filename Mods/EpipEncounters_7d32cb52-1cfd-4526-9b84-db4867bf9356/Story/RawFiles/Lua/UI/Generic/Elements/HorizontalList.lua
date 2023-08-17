
---@class GenericUI
local Generic = Client.UI.Generic

---@class GenericUI_Element_HorizontalList : GenericUI_Element_VerticalList
local List = {}
Generic.Inherit(List, Generic.ELEMENTS.VerticalList)

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("HorizontalList", List)