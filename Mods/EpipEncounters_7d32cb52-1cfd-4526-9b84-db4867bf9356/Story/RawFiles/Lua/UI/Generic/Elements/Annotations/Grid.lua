
---@meta

---@class GenericUI_Element_Grid : GenericUI_ContainerElement
local Grid = {}

---Sets the size of the grid, in elements.
---@param columns integer Set to -1 for infinite.
---@param rows integer Set to -1 for infinite.
function Grid:SetGridSize(columns, rows) end

---Sets whether all elements within the list should be repositioned after adding a new one.
---Default behaviour is to do so; disabling it offers far better performance when bulk-adding elements.
---@param reposition boolean
function Grid:SetRepositionAfterAdding(reposition) end

---Repositions the elements of the grid.
function Grid:RepositionElements() end