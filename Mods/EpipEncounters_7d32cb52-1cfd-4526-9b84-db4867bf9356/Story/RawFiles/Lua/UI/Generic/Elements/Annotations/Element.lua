
---@meta

---@class GenericUI_Element
local Element = {}

---Sets the position of the element relative to its parent.
---@param position GenericUI_Element_RelativePosition
---@param horizontalOffset number?
---@param verticalOffset number?
function Element:SetPositionRelativeToParent(position, horizontalOffset, verticalOffset) end

---Moves the element a certain amount of pixels from its current position.
---@param x number
---@param y number
function Element:Move(x, y) end

---Returns the width of the element.
---@param considerOverrides boolean? If `true`, width overrides will be considered. Defaults to `true`.
---@return number
function Element:GetWidth(considerOverrides) end

---Returns the height of the element.
---@param considerOverrides boolean? If `true`, height overrides will be considered. Defaults to `true`.
---@return number
function Element:GetHeight(considerOverrides) end

---Returns the width of the element without considering its children.
---@return number
function Element:GetRawWidth() end

---Returns the height of the element without considering its children.
---@return number
function Element:GetRawHeight() end