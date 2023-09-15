
---@class GenericUI
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
_Grid.SetRepositionAfterAdding = Generic.ExposeFunction("SetRepositionAfterAdding")
_Grid.RepositionElements = Generic.ExposeFunction("RepositionElements")

---Sets the spacing between elements.
---@param row number
---@param column number
function Grid:SetElementSpacing(row, column)
    local mc = self:GetMovieClip()

    mc.gridList.EL_SPACING = column
    mc.gridList.ROW_SPACING = row
end

---Returns the dimensions of the grid.
---@return integer, integer -- Rows, columns. `-1` indicates no restriction.
function Grid:GetGridSize()
    local mc = self:GetMovieClip()
    local rows, columns = mc.gridList.row, mc.gridList.col
    local undefined = 2^32 - 1 -- uint shenanigans lmao
    if columns >= undefined then columns = -1 end
    if rows >= undefined then rows = -1 end
    return rows, columns
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Grid", Grid)