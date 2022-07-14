
---@meta Library: Color, ContextShared, Color

---------------------------------------------
-- Utility library for working with colors.
---------------------------------------------

Color = {
    RGBColor = nil,

    COLORS = {
        PHYSICAL_ARMOR = "#A8A8A8",
        MAGIC_ARMOR = "#188EDE",
    },
}

---------------------------------------------
-- RGBCOLOR INSTANCE
---------------------------------------------

---@class RGBColor
---@field Red integer
---@field Green integer
---@field Blue integer

---@type RGBColor
local RGBColor = {
    Red = 0, Green = 0, Blue = 0
}
Color.RGBColor = RGBColor

---@return integer
function RGBColor:ToDecimal()
    return self.Blue + self.Green * 256 + self.Red * 256 ^ 2
end

---@param prefix boolean? Prefix the string with #. Defaults to false.
---@return string
function RGBColor:ToHex(prefix)
    local valStr = string.format("%x", self:ToDecimal())
    
    while string.len(valStr) < 6 do
        valStr = "0" .. valStr
    end

    if prefix then
        valStr = "#" .. valStr
    end

    return valStr:upper()
end

---@param color RGBColor
---@return RGBColor
function RGBColor.Clone(color)
    return RGBColor.Create(color.Red, color.Green, color.Blue)
end

---@param num integer
---@return RGBColor
function RGBColor.CreateFromDecimal(num)

    -- TODO alpha field
    if num >= 256 ^ 3 then
        num = num % (256 ^ 3)
    end

    local red = num // (256 ^ 2)
    local green = (num // 256) % 256
    local blue = num % 256

    return Color.Create(red, green, blue)
end

---@return RGBColor
function RGBColor.Create(r, g, b)
    local color = {Red = r or 0, Green = g or 0, Blue = b or 0}
    Inherit(color, RGBColor)
    
    return color
end

---@return RGBColor
function RGBColor.CreateFromHex(hex)
    return Color.Create(tonumber(string.sub(hex, 1, 2), 16), tonumber(string.sub(hex, 3, 4), 16), tonumber(string.sub(hex, 5, 6), 16))
end

---@param color RGBColor
---@return boolean
function RGBColor:Equals(color)
    return self.Red == color.Red and self.Green == color.Green and self.Blue == color.Blue
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Alias for creating an RGBColor from RGB values.
---@param red integer
---@param green integer
---@param blue integer
---@return RGBColor
function Color.Create(red, green, blue)
    return Color.CreateFromRGB(red, green, blue)
end

---@param red integer
---@param green integer
---@param blue integer
---@return RGBColor
function Color.CreateFromRGB(red, green, blue)
    return RGBColor.Create(red, green, blue)
end

---@param num integer
---@return RGBColor
function Color.CreateFromDecimal(num)
    return RGBColor.CreateFromDecimal(num)
end

---@param hex string
---@return RGBColor
function Color.CreateFromHex(hex)
    return RGBColor.CreateFromHex(hex)
end

---@param color RGBColor
---@return RGBColor New instance with same values.
function Color.Clone(color)
    return RGBColor.Clone(color)
end