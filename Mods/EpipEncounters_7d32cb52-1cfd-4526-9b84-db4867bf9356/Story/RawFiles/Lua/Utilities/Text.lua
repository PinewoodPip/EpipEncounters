
---@class TextLib
Text = {
    ---@enum TextLib_Font
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
    UNKNOWN_HANDLE = "ls::TranslatedStringRepository::s_HandleUnknown",
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
---@alias FontAlign "center" | "right" | "left"

---@class TextFormatData
---@field FontType TextLib_Font
---@field Size number
---@field Color string
---@field Align FontAlign
---@field FormatArgs any[]
---@field Text? string Used for formatting strings with recursive Text.Format calls.
---@field RemovePreviousFormatting boolean Defaults to false.
local _TextFormatData = {
    FormatArgs = {},
    RemovePreviousFormatting = false,
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

---Concatenates 2 strings and adds enough whitespace padding inbetween them to ensure a specific length.
---@param str1 string
---@param str2 string
---@param space integer
---@return string
function Text.EqualizeSpace(str1, str2, space)
    local normalLength = #str1 + #str2 - 1
    local output = str1 .. " " -- minimum of 1 space

    while normalLength < space do
        output = output .. " "
        normalLength = normalLength + 1
    end

    return output .. str2
end

---Generate a random GUID.
---Source: https://gist.github.com/jrus/3197011
---@param pattern pattern? Defaults to GUID4 pattern.
---@return GUID
function Text.GenerateGUID(pattern)
    local template = pattern or "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

    local guid, _ = string.gsub(template, "[xy]", function (c)
        local v = (c == "x") and Ext.Random(0, 0xf) or Ext.Random(8, 0xb)
        return string.format("%x", v)
    end)

    return guid
end

---Generates a random handle in the format that Larian uses for TranslatedStringHandle.
---@return TranslatedStringHandle
function Text.GenerateTranslatedStringHandle()
    return Text.GenerateGUID("hxxxxxxxxgxxxxg4xxxgyxxxgxxxxxxxxxxxx") -- Prefixed with h, dashes replaced by g
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

-- WIP
function Text.Split_2(str, sep)
    local splitStrings = {}
    local newStr = ""
    local separatorLength = #sep

    local i = 1
    while i <= #str do
        local char = str:sub(i, i)

        if str:sub(i, i + separatorLength - 1) == sep then
            i = i + separatorLength

            table.insert(splitStrings, newStr)
            newStr = ""
        else
            newStr = newStr .. char

            i = i + 1
        end
    end

    table.insert(splitStrings, newStr)

    return splitStrings
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

    if formatData.RemovePreviousFormatting then
        str = Text.StripFontTags(str)
    end

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

---Removes all <font> tags from a string. WIP!
---@param str string
---@return string
function Text.StripFontTags(str)
    str = str:gsub("</br>", "<br>")

    local newStr = ""
    local length = string.len(str)
    local inTag = 0
    for i=1,length,1 do
        local char = str:sub(i, i)

        if char == "<" then -- TODO consider escapes
            inTag = inTag + 1

            local isBr = str:sub(i, i + 3) == "<br>"
            if isBr then
                newStr = newStr .. "<br>"

                i = i + 3
            end
        elseif char == ">" then
            inTag = inTag - 1
        elseif inTag == 0 then 
            newStr = newStr .. char
        end
    end

    return newStr
end

---Shorthand for Ext.DumpExport() which does not require you to explicitly define the default options (Beautify, StringifyInternalTypes, etc.)
---@param obj any
---@param opts unknown? TODO specify type
---@return string
function Text.Dump(obj, opts)
    -- Mimic default Ext.Dump() behaviour
    opts = opts or {}
    opts.Beautify = true
    opts.StringifyInternalTypes = true
    opts.IterateUserdata = true
    opts.AvoidRecursion = true
    opts.LimitDepth = opts.LimitDepth or 2

    return Ext.Json.Stringify(obj, opts)
end

---Returns the string bound to a TranslatedStringHandle, or a key.
---@param handle TranslatedStringHandle|string Accepts handles or keys.
---@param fallBack string?
---@return string Defaults to the handle, of fallBack if specified.
function Text.GetTranslatedString(handle, fallBack)
    local str = Ext.L10N.GetTranslatedString(handle)

    if not str or str == "" then
        str = Ext.L10N.GetTranslatedStringFromKey(handle)
    end

    return str or fallBack or handle
end

---Registers a translated string, optionally binding a key to it.
---@param text string
---@param handle TranslatedStringHandle
---@param key string?
---@return string -- The text passed as parameter, or the text the handle already pointed to, if already registered/localized.
function Text.RegisterTranslatedString(text, handle, key)
    local currentText = Text.GetTranslatedString(handle)

    -- Recreating the handle would remove existing localization.
    if not currentText or currentText == "" then
        Ext.L10N.CreateTranslatedStringHandle(handle, text)

        -- Bind handle to key
        if key then
            Ext.L10N.CreateTranslatedStringKey(key, handle)
        end
    else
        text = currentText
    end

    return text
end