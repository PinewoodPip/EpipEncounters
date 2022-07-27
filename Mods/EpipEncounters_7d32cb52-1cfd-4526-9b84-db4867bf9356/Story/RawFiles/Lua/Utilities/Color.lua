
---@meta Library: Color, ContextShared, Color

---------------------------------------------
-- Utility library for working with colors.
---------------------------------------------

Color = {
    RGBColor = nil,

    COLORS = {
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
        }

    },
}

---------------------------------------------
-- RGBCOLOR INSTANCE
---------------------------------------------

---@class RGBColor
---@field Red integer
---@field Green integer
---@field Blue integer

---@class RGBColor
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