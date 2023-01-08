
---@meta 

---@class GenericUI_Element_Divider : GenericUI_Element
local Divider = {}

---Sets the visual for the divider.
---@param dividerType GenericUI_Element_Divider_Type
function Divider:SetType(dividerType) end

---Sets the size of the divider.
---Custom height not currently supported. TODO
---@param width number
function Divider:SetSize(width) end