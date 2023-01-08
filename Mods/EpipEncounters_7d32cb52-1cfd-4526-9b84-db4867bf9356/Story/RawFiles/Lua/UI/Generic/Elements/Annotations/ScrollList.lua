
---@meta

---@class GenericUI_Element_ScrollList : GenericUI_Element_VerticalList
local ScrollList = {}

---Sets the size of the scroll list. Contents outside the rect will be culled.
---@param width number
---@param height number
function ScrollList:SetFrame(width, height) end

---Sets whether the scroll list can be scrolled with the mouse wheel.
---@param enabled boolean
function ScrollList:SetMouseWheelEnabled(enabled) end

---Sets the horizontal spacing for the scroll bar, relative to the right edge of the frame.
---Must be called after SetFrame. TODO remove restriction
---@param spacing number
function ScrollList:SetScrollbarSpacing(spacing) end