
---@class GenericUI
local Generic = Client.UI.Generic

---@class GenericUI_Element_Color : GenericUI_Element
local Color = {}
Generic.Inherit(Color, Generic._Element)

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets the color shown by the element.
---@param color RGBColor
function Color:SetColor(color)
    self:GetMovieClip().SetColor(color:ToDecimal(false))
end

---------------------------------------------
-- SETUP
---------------------------------------------

Generic.RegisterElementType("Color", Color)