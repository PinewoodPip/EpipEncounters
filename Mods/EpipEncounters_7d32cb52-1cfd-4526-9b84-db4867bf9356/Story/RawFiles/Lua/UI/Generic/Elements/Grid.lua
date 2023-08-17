
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

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Grid", Grid)