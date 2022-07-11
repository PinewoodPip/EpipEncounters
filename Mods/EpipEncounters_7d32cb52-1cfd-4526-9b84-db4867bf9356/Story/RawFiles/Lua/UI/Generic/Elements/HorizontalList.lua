
local Generic = Client.UI.Generic

---@class GenericUI_Element_HorizontalList : GenericUI_Element_VerticalList

---@type GenericUI_Element_HorizontalList
Client.UI.Generic.ELEMENTS.HorizontalList = {

}
local List = Client.UI.Generic.ELEMENTS.HorizontalList
Inherit(List, Generic.ELEMENTS.VerticalList)

---------------------------------------------
-- METHODS
---------------------------------------------


---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("HorizontalList", List)