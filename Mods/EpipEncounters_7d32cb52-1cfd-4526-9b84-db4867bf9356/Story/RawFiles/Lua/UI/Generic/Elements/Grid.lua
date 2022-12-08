
local Generic = Client.UI.Generic

---@class GenericUI_Element_Grid : GenericUI_Element
---@field SetGridSize fun(self:GenericUI_Element_Grid, columns:integer, rows:integer)
---@field ClearElements fun(self:GenericUI_Element_Grid)
local Grid = {

}
Generic.Inherit(Grid, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

Grid.SetGridSize = Generic.ExposeFunction("SetGridSize")
Grid.ClearElements = Generic.ExposeFunction("ClearElements")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Grid", Grid)