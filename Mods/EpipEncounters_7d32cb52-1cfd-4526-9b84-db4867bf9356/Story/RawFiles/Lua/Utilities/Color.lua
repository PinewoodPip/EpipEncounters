
---------------------------------------------
-- Utility library for working with colors.
---------------------------------------------

---@class ColorLib
Color = {
    RGBColor = nil,

    -- Various color enums. These are not nested within another table so as to reduce verbosity and redundancy.

    PHYSICAL_ARMOR = "A8A8A8",
    MAGIC_ARMOR = "188EDE",

    BLACK = "000000",
    RED = "FF0000",
    GREEN = "00FF00",
    BLUE = "0000FF",
    WHITE = "FFFFFF",

    -- From https://docs.larian.game/UI_Colors_Reference_Sheet
    LARIAN = {
        BLUE = "0078FF",
        GREEN = "00F27D",
        RED = "FF0200",
        YELLOW = "FFFF00",
        DARK_GRAY = "454545",
        GRAY = "A8A8A8",
        LIGHT_GRAY = "DBDBDB",
        DARK_BLUE = "004672",
        LIGHT_BLUE = "CFECFF",
        POISON_GREEN = "00AA00",
        ORANGE = "FF9600",
        PINK = "FFC3C3",
        PURPLE = "7F00FF",
        BROWN = "B97A57",
        GOLD = "C7A758",
    },
    TEAM_PINEWOOD = {
        PIP_PURPLE = "7E72D6",
        LOGO_PURPLE = "5456A5",
        GREEN = "386900",
        LIGHT_GREEN = "74B52D",
    },

    TOOLTIPS = {
        MALUS = "DA2121",
        BONUS = "65C900",

        STAT_BLUE = "00547F",
        STAT_RED = "C80030",
    },

    AREA_INTERACT = "FFD400",
    ILLEGAL_ACTION = "CD1F1F",

    ALIGNMENTS = {
        PARTY = "00A2FD",
        ALLY = "11D77A",
        NEUTRAL = "F3D347",
        ENEMY = "D7001F",
    },

    SKILL_SCHOOLS = {
        AEROTHEURGE = "7478DC",
        GEOMANCER = "AA895B",
        PYROKINETIC = "C76537",
        NECROMANCER = "9A5085",
        POLYMORPH = "FFB811",
        HUNTSMAN = "5A9646",
        SCOUNDREL = "566C6C",
        SOURCERY = "6EB09D",
        SUMMONING = "9440B3",
        WARFARE = "A11919",
        HYDROSOPHIST = "579CCA",
    },
}

---------------------------------------------
-- RGBCOLOR INSTANCE
---------------------------------------------

---@class RGBColor
---@field Red integer In integer range [0-255]
---@field Green integer In integer range [0-255]
---@field Blue integer In integer range [0-255]
---@field Alpha integer In integer range [0-255]
---@operator add(RGBColor):RGBColor
---@operator sub(RGBColor):RGBColor
local RGBColor = {
    Red = 0,
    Green = 0,
    Blue = 0,
    Alpha = 255,

    __name = "RGBColor",
}
Color.RGBColor = RGBColor

---Returns the decimal representation of the color.
---Actionscript expects colors to be represented in this way.
---@param addAlpha boolean? Defaults to false.
---@return integer
function RGBColor:ToDecimal(addAlpha)
    local value

    if addAlpha then
        value = self.Alpha + self.Blue * 256 + self.Green * 256 ^ 2 + self.Red * 256 ^ 3
    else
        value = self.Blue + self.Green * 256 + self.Red * 256 ^ 2
    end

    return value  
end

---Unpacks the color's RGB values, alpha included.
---@return integer ...
function RGBColor:Unpack()
    return self.Red, self.Green, self.Blue, self.Alpha
end

---Returns the hexadecimal representation of the color.
---@param prefix boolean? Prefix the string with #. Defaults to false.
---@param addAlpha boolean? Defaults to false. If enabled, resulting color will be in the format `#RRGGBBAA`
---@return string
function RGBColor:ToHex(prefix, addAlpha)
    local valStr = string.format("%x", self:ToDecimal(addAlpha))
    
    while string.len(valStr) < 6 do
        valStr = "0" .. valStr
    end

    if prefix then
        valStr = "#" .. valStr
    end

    return valStr:upper()
end

---Returns the RGBA values as floats in the range[0.0 - 1.0]
---@return number, number, number, number
function RGBColor:ToFloats()
    return self.Red / 255, self.Green / 255, self.Blue / 255, self.Alpha / 255
end

---Returns a new instance of RGBColor with the same values.
---@return RGBColor
function RGBColor:Clone()
    return RGBColor.Create(self.Red, self.Green, self.Blue, self.Alpha)
end

---Creates a color from a decimal value.
---Does not support alpha.
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

---Creates a color from RGBA values.
---Expected range is [0-255] and will be clamped.
---@param r integer?
---@param g integer?
---@param b integer?
---@param a integer? Defaults to 255.
---@return RGBColor
function RGBColor.Create(r, g, b, a)
    r = math.clamp(r or 0, 0, 255)
    g = math.clamp(g or 0, 0, 255)
    b = math.clamp(b or 0, 0, 255)
    a = math.clamp(a or 255, 0, 255)

    local color = {Red = r, Green = g, Blue = b, Alpha = a}
    Inherit(color, RGBColor)
    
    return color
end

---Creates a color from a hexadecimal value.
---Does not support alpha.
---@param hex string
---@return RGBColor
function RGBColor.CreateFromHex(hex)
    return Color.Create(tonumber(string.sub(hex, 1, 2), 16), tonumber(string.sub(hex, 3, 4), 16), tonumber(string.sub(hex, 5, 6), 16))
end

---Returns whether 2 colors have the same RGBA values.
---@param color RGBColor
---@return boolean
function RGBColor:Equals(color)
    return self.Red == color.Red and self.Green == color.Green and self.Blue == color.Blue and self.Alpha == color.Alpha
end

---__eq overload. Equivalent to calling RGBColor.Equals()
---@param color1 RGBColor
---@param color2 RGBColor
---@return boolean
function RGBColor.__eq(color1, color2)
    return RGBColor.Equals(color1, color2)
end

---__add overload. Adds the RGB values of both colors.
---@param color1 RGBColor
---@param color2 RGBColor
---@return RGBColor
function RGBColor.__add(color1, color2)
    local r = math.min(color1.Red + color2.Red, 255)
    local g = math.min(color1.Green + color2.Green, 255)
    local b = math.min(color1.Blue + color2.Blue, 255)

    return RGBColor.Create(r, g, b)
end

---__sub overload. Subtracts the RGB values.
---@param color1 RGBColor
---@param color2 RGBColor
---@return RGBColor
function RGBColor.__sub(color1, color2)
    local r = math.max(color1.Red - color2.Red, 0)
    local g = math.max(color1.Green - color2.Green, 0)
    local b = math.max(color1.Blue - color2.Blue, 0)

    return RGBColor.Create(r, g, b)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Alias for creating an RGBColor from RGBA values.
---@overload fun(color:RGBColor):RGBColor
---@param red integer?
---@param green integer?
---@param blue integer?
---@param alpha integer?
---@return RGBColor
function Color.Create(red, green, blue, alpha)
    -- Table overload.
    if type(red) == "table" then
        local tbl = red
        red, green, blue, alpha = tbl.Red, tbl.Green, tbl.Blue, tbl.Alpha
    end

    return Color.CreateFromRGB(red, green, blue, alpha)
end

---Creates a color from RGBA values. Expected range of values is [0-255].
---@param red integer?
---@param green integer?
---@param blue integer?
---@param alpha integer?
---@return RGBColor
function Color.CreateFromRGB(red, green, blue, alpha)
    return RGBColor.Create(red, green, blue, alpha)
end

---Creates a color from a decimal value.
---Does not support alpha.
---@param num integer
---@return RGBColor
function Color.CreateFromDecimal(num)
    return RGBColor.CreateFromDecimal(num)
end

---Creates a color from an html-format hex color code.
---Does not support alpha.
---@param hex string
---@return RGBColor
function Color.CreateFromHex(hex)
    return RGBColor.CreateFromHex(hex)
end

---Clones a color instance.
---@param color RGBColor
---@return RGBColor -- New instance with same values.
function Color.Clone(color)
    return RGBColor.Clone(color)
end