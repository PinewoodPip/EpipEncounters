
local Generic = Client.UI.Generic

---@class GenericUI_Element_HorizontalList : GenericUI_Element_VerticalList
Client.UI.Generic.ELEMENTS.HorizontalList = {
    Events = {},
}
local List = Client.UI.Generic.ELEMENTS.HorizontalList
Generic.Inherit(List, Generic.ELEMENTS.VerticalList)

---------------------------------------------
-- METHODS
---------------------------------------------


---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("HorizontalList", List)