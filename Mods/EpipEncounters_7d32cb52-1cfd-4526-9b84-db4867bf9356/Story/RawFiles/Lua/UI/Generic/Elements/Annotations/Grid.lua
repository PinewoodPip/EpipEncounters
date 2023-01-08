
---@meta

---@class GenericUI_Element_Grid : GenericUI_ContainerElement
local Grid = {}

---Sets the size of the grid, in elements.
---@param columns integer Set to -1 for infinite.
---@param rows integer Set to -1 for infinite.
function Grid:SetGridSize(columns, rows) end