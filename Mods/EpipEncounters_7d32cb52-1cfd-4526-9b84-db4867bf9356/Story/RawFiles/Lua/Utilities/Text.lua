
---@class TextLib
Text = {
    FONTS = {
        BOLD = "Ubuntu Mono",
        ITALIC = "Averia Serif",
        NORMAL = "Nueva Std Cond",
        BIG_NUMBERS = "CollegiateBlackFLF",
        FALLBACK = "fb",
    },
    LUA_PATTERN_CHARACTERS = {
        ["^"] = "%^",
        ["$"] = "%$",
        ["("] = "%(",
        [")"] = "%)",
        ["%"] = "%%",
        ["."] = "%.",
        ["["] = "%[",
        ["]"] = "%]",
        ["*"] = "%*",
        ["+"] = "%+",
        ["-"] = "%-",
        ["?"] = "%?",
        ["\0"] = "%z",
    },
    PATTERNS = {
        FONT_SIZE = 'size="([0-9]+)"',
        FONT_COLOR = 'color="(#......)"',
        STATUSES = {
            SOURCE_INFUSING = "AMER_SOURCEINFUSION_(%d+)",
            BATTERED = "^BATTERED_(%d+)$",
            HARRIED = "^HARRIED_(%d+)$",
            SOURCE_GENERATION = "^AMER_SOURCEGEN_DISPLAY_(%d+)$",
        },
    },
    TEMPLATES = {
        FONT_SIZE = 'size="%d"',
    },
}

---@alias Font "Bold" | "Italic" | "Normal"
---@alias FontAlign "center" | "right" | "left"

---@class TextFormatData
---@field FontType Font
---@field Size number
---@field Color string
---@field Align FontAlign
---@field FormatArgs any[]
---@field Text? string Used for formatting strings with recursive Text.Format calls.

---@class TextFormatData
local _TextFormatData = {
    FormatArgs = {},
}

---Returns a string representation of a number, rounded.
---@param value number
---@param decimals? integer Defaults to 0.
---@return string
function Text.Round(value, decimals)
    value = tostring(value)
    decimals = decimals or 0
    
    local pattern = "^(%d*)%.?(%d*)$"
    local wholeText, decimalsText = value:match(pattern)
    local output = wholeText

    if decimals > 0 and decimalsText and decimalsText:len() > 0 then
        decimalsText = string.sub(decimalsText, 1, decimals)
        output = output .. "." .. decimalsText

        output = Text.RemoveTrailingZeros(output)
    end

    return output
end

---Returns a string with spaces inserted inbetween PascalCase words.
---@param str string
---@return string
function Text.SeparatePascalCase(str)
    str = str:gsub("(%l)(%u%a*)", "%1 %2") 

    if str:find("(%l)(%u%a*)") then
        str = Text.SeparatePascalCase(str)
    end

    return str
end

---Removes trailing zeros from a number and returns it as string.
---@param num number
---@return string
function Text.RemoveTrailingZeros(num)
    local str = tostring(num):gsub("%.[1-9]*(0+)$", "")

    str = str:gsub("%.$", "")

    return str
end

---Escapes characters that have a special meaning in lua patterns.
---Source: https://github.com/lua-nucleo/lua-nucleo/blob/v0.1.0/lua-nucleo/string.lua#L245-L267
---@param str string
---@return string
function Text.EscapePatternCharacters(str)
    return (str:gsub(".", Text.LUA_PATTERN_CHARACTERS))
end

---@param str string
---@param pattern pattern
function Text.Contains(str, pattern)
    return str:find(pattern) ~= nil
end

---Split a string by delimiter. Source: https://stackoverflow.com/questions/1426954/split-string-in-lua
---@param inputstr string
---@param sep string
---@return string[]
function Text.Split(inputstr, sep) 
    sep=sep or '%s'
    local t={} 

    local pattern = "([^"..sep.."]*)("..sep.."?)"

    -- TODO fix
    if string.len(sep) > 1 then
        pattern = ""
        for i=1,#sep,1 do
            local char = string.sub(sep, i, i)

            pattern = pattern .. "([^"..char.."]*)("..char.."?)"
        end
    end

    for field,s in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do 
        table.insert(t,field) 
    end
    
    return t
end

---Capitalizes the first letter of the string.
---https://stackoverflow.com/a/2421746
---@param str string
---@return string
function Text.Capitalize(str)
    str = str:gsub("^%l", string.upper)

    return str
end

-- function Text.Split(s, sep)
--     local fields = {}
    
--     local sep = sep or " "
--     local pattern = string.format("([^%s]+)", sep)
--     string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    
--     return fields
-- end

---Format a string.
---@param str string | TextFormatData
---@param formatData TextFormatData
---@return string 
function Text.Format(str, formatData)
    setmetatable(formatData, {__index = _TextFormatData})

    -- Parse args, which can be a TextFormatData as well.
    local finalArgs = {}

    if formatData.FormatArgs then
        for i,arg in ipairs(formatData.FormatArgs) do
            if type(arg) == "table" then
                table.insert(finalArgs, Text.Format(arg.Text, arg))
            elseif type(arg) == "number" then
                table.insert(finalArgs, Text.RemoveTrailingZeros(arg))
            else
                table.insert(finalArgs, arg)
            end
        end
    end

    if #finalArgs > 0 then
        str = string.format(str, table.unpack(finalArgs))
    end

    -- Font, color, size
    local fontType = ""
    if formatData.FontType then
        fontType = string.format(" face='%s'", formatData.FontType)
    end

    local align = ""
    if formatData.Align then
        align = string.format(" align='%s'", formatData.Align)
    end
    
    local color = ""
    if formatData.Color then
        color = string.format(" color='%s'", formatData.Color)
    end

    local size = ""
    if formatData.Size then
        size = string.format(" size='%d'", formatData.Size)
    end

    str = string.format("<font%s%s%s%s>%s</font>", fontType, color, size, align, str)

    return str
end