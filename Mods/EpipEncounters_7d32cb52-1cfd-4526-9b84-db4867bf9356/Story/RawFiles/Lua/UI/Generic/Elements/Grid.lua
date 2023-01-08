
local Generic = Client.UI.Generic

---@class GenericUI_Element_Grid : GenericUI_ContainerElement
local Grid = {

}
Generic.Inherit(Grid, Generic._Element)

local _Grid = Grid ---@type GenericUI_Element_Grid Used to workaround an IDE issue with annotations pointing to ExposeFunction().

---------------------------------------------
-- METHODS
---------------------------------------------

_Grid.SetGridSize = Generic.ExposeFunction("SetGridSize")
_Grid.ClearElements = Generic.ExposeFunction("ClearElements")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Grid", Grid)