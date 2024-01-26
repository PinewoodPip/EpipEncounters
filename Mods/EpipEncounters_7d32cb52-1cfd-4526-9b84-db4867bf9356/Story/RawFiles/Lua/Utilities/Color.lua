
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

    -- Source: https://www.krishnamani.in/color-codes-for-rainbow-vibgyor-colours/
    ---@type htmlcolor[]
    VIBGYOR_RAINBOW = {
        "9400D3", -- Purple
        "4B0082", -- Dark purple
        "0000FF", -- Deep blue
        "00FF00", -- Deep green
        "FFFF00", -- Yellow
        "FF7F00", -- Orange
        "FF0000", -- Deep red
    },

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

        -- Colors used in SkillSchool tooltip elements (the footer in skill tooltips)
        SKILL_SCHOOLS = {
            WARFARE = "DA2512",
            HUNTSMAN = "81AB00",
            SCOUNDREL = "639594",
            PYROKINETIC = "FE6E27",
            HYDROSOPHIST = "4197E2",
            AEROTHEURGE = "7D71D9",
            GEOMANCER = "7F3D00",
            NECROMANCER = "B823CB",
            SUMMONING = "7F25D4",
            SPECIAL = "C9AA58",
            SOURCERY = "46B195",
        },
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

    -- Indexes of colors within `GlobalSwitches.OverlayColors`. 1-based.
    OVERLAY_COLOR_INDEXES = {
        SKILL_PREPARE_SPECIAL = 6,
        TACTICAL_HIGHLIGHTS_ACTIVE_CHARACTER = 8,
        SELECTOR_FORCE_ATTACK = 11,
        OUTLINE_FORBIDDEN_ITEM = 16,
        SELECTOR_DOTS = 18,
        SELECTOR_OUTER_CIRCLE = 19,
        SELECTOR_INNER_CROSS = 20,
        OUTLINE_CORPSE = 22,
        OUTLINE_ITEM = 25,
        SKILL_PREPARE_AEROTHEURGE = 30,
        SKILL_PREPARE_GEOMANCER = 31,
        SKILL_PREPARE_PYROKINETIC = 32,
        SKILL_PREPARE_NECROMANCER = 33,
        SKILL_PREPARE_POLYMORPH = 34,
        SKILL_PREPARE_HUNTSMAN = 35,
        SKILL_PREPARE_SCOUNDREL = 36,
        SKILL_PREPARE_SOURCERY = 37,
        SKILL_PREPARE_SUMMONING = 38,
        SKILL_PREPARE_WARFARE = 39,
        SKILL_PREPARE_HYDROSOPHIST = 40,
        TACTICAL_HIGHLIGHTS_CONTROLLED_ALLY = 41,
        OUTLINE_SKILL_PREPARE_CHARACTER_IN_RANGE = 42,
        TACTICAL_HIGHLIGHTS_ALLY = 43,
        TACTICAL_HIGHLIGHTS_NEUTRAL = 45,
        OUTLINE_SKILL_PREPARE_TARGET = 46,
        TACTICAL_HIGHLIGHTS_ENEMY = 47,
        OUTLINE_ATTACK_TARGET = 48,
    }
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
    r, g, b, a = math.floor(r), math.floor(g), math.floor(b), math.floor(a)

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

---__eq overload. Equivalent to calling RGBColor:Equals()
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
---@overload fun(color:htmlcolor):RGBColor
---@overload fun(color:integer):RGBColor
---@param red integer?
---@param green integer?
---@param blue integer?
---@param alpha integer?
---@return RGBColor
function Color.Create(red, green, blue, alpha)
    local color ---@type RGBColor

    -- Table overload.
    if type(red) == "table" then
        local tbl = red
        red, green, blue, alpha = tbl.Red, tbl.Green, tbl.Blue, tbl.Alpha
        color = Color.CreateFromRGB(red, green, blue, alpha)
    elseif type(red) == "string" then -- HTML color string overload.
        color = Color.CreateFromHex(red)
    elseif type(red) == "number" and green == nil then -- Decimal overload.
        color = Color.CreateFromDecimal(red)
    else
        color = Color.CreateFromRGB(red, green, blue, alpha)
    end

    return color
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

---Creates a new color whose RGB components are linearly interpolated from one to another.
---Uses the alpha of the target color.
---@param startColor RGBColor
---@param targetColor RGBColor
---@param progress number Expected values are from 0.0 to 1.0.
function Color.Lerp(startColor, targetColor, progress)
    local r = math.lerp(startColor.Red, targetColor.Red, progress)
    local g = math.lerp(startColor.Green, targetColor.Green, progress)
    local b = math.lerp(startColor.Blue, targetColor.Blue, progress)

    return Color.CreateFromRGB(r, g, b, targetColor.Alpha)
end
