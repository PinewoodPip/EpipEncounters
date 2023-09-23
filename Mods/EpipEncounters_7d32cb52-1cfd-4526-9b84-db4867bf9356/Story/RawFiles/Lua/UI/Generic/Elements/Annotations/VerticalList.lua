
---@meta

---@class GenericUI_Element_VerticalList : GenericUI_Element
local VerticalList = {}

---Repositions all the elements within the container.
---Does not recursively reposition parented containers. TODO
function VerticalList:RepositionElements() end

---Sets a padding to be placed before the first element of the container.
---@param spacing number
function VerticalList:SetTopSpacing(spacing) end

---Sets the spacing between positioned elements.
---@param spacing number
function VerticalList:SetElementSpacing(spacing) end

---Sets a padding for the left side of the container.
---@param spacing number
function VerticalList:SetSideSpacing(spacing) end

---Sets whether all elements within the list should be repositioned after adding a new one.
---Default behaviour is to do so; disabling it offers far better performance when bulk-adding elements.
---@param reposition boolean
function VerticalList:SetRepositionAfterAdding(reposition) end
