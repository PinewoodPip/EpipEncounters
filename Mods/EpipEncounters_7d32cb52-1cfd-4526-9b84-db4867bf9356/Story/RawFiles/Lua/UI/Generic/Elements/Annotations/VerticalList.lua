
---@meta

---@class GenericUI_Element_VerticalList : GenericUI_Element
local VerticalList = {}

---Removes all elements from the container.
function VerticalList:Clear() end

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