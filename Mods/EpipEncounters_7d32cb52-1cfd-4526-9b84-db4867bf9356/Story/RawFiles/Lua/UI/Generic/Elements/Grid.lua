
local Generic = Client.UI.Generic

---@class GenericUI_Element_Grid : GenericUI_Element
---@field SetGridSize fun(self:GenericUI_Element_Grid, columns:integer, rows:integer)
local Grid = {

}
Generic.Inherit(Grid, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

Grid.SetGridSize = Generic.ExposeFunction("SetGridSize")

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Grid", Grid)