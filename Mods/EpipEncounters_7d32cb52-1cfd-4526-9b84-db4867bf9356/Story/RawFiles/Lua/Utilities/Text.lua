
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")

---@class TextLib : Library
Text = {
    _RegisteredTranslatedHandles = {}, ---@type table<TranslatedStringHandle, TextLib_TranslatedString> Maps handle to original text.
    _TranslatedStrings = DefaultTable.Create({}), ---@type table<string, table<TranslatedStringHandle, string>> -- Maps language to table of TSK translations.
    ---@enum TextLib_Font

    LOCALIZATION_FILE_FORMAT_VERSION = 0,
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
        GUID = "(%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x)",
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

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetTranslationTemplateEntry = {}, ---@type Event<TextLib_Hook_GetTranslationTemplateEntry>
    },
}
Epip.InitializeLibrary("Text", Text)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class TextLib_TranslatedString
---@field Handle TranslatedStringHandle
---@field Text string
---@field ModTable ModTableID?
---@field StringKey string?
---@field ContextDescription string?
local _TranslatedString = {}

---@param data TextLib_TranslatedString
---@return TextLib_TranslatedString
function _TranslatedString.Create(data)
    Inherit(data, _TranslatedString)

    return data
end

---@return string
function _TranslatedString:GetString()
    return Text.GetTranslatedString(self.Handle, self.Handle)
end

---@alias FontAlign "center" | "right" | "left"

---@class TextFormatData
---@field FontType TextLib_Font
---@field Size number
---@field Color string
---@field Align FontAlign
---@field FormatArgs (any|TextFormatData)[]
---@field Text? string Used for formatting strings with recursive Text.Format calls.
---@field RemovePreviousFormatting boolean Defaults to false.
local _TextFormatData = {
    FormatArgs = {},
    RemovePreviousFormatting = false,
}

---@class TextLib_LocalizationTemplate_Entry
---@field ReferenceText string
---@field ReferenceKey string?
---@field TranslatedText string
---@field ContextDescription string?

---@class TextLib_LocalizationTemplate
---@field ModTable string
---@field FileFormatVersion integer
---@field TranslatedStrings table<TranslatedStringHandle, TextLib_LocalizationTemplate_Entry>

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class TextLib_Hook_GetTranslationTemplateEntry
---@field Entry TextLib_LocalizationTemplate_Entry Hookable. Set to nil to prevent an entry from getting exported.
---@field TranslatedString TextLib_TranslatedString

---------------------------------------------
-- METHODS
---------------------------------------------

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

---Joins two strings together.
---@param str1 string
---@param str2 string
---@param separator string? Defaults to ` `
---@overload fun(str:string[], separator:string?)
function Text.Join(str1, str2, separator)
    if type(str1) == "table" then separator = str2 end
    separator = separator or " "
    local newString

    if type(str1) == "table" then
        newString = ""

        for i,str in ipairs(str1) do
            newString = newString .. str

            if i ~= #str1 then
                newString = newString .. separator
            end
        end
    else
        newString = str1 .. separator .. str2
    end

    return newString
end

function Text.AppendLine(str1, str2)
    local separator = "\n"

    -- Do not append line break if str1 is empty.
    if str1 == "" then
        separator = ""
    end

    return Text.Join(str1, str2, separator)
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

---Adds padding characters to the front of a string to meet a minimum length.
---@param str string
---@param minLength integer
---@param paddingCharacter string? Defaults to `""`
---@return string
function Text.AddPadding(str, minLength, paddingCharacter)
    paddingCharacter = paddingCharacter or ""

    while #str < minLength do
        str = paddingCharacter .. str
    end

    return str
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

    for field,_ in string.gmatch(inputstr, "([^"..sep.."]*)("..sep.."?)") do 
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
---@param str string
---@param formatData TextFormatData
---@overload fun(str:TextFormatData)
---@return string 
function Text.Format(str, formatData)
    setmetatable(formatData, {__index = _TextFormatData})

    if type(str) == "table" then
        str, formatData = str.Text, str
    end

    if formatData.RemovePreviousFormatting then
        str = Text.StripFontTags(str)
    end

    -- Parse args, which can be a TextFormatData as well.
    local finalArgs = {}
    if formatData.FormatArgs then
        for _,arg in ipairs(formatData.FormatArgs) do
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

    if fontType ~= "" or align ~= "" or color ~= "" or size ~= "" then
        str = string.format("<font%s%s%s%s>%s</font>", fontType, color, size, align, str)
    end

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
---@param handle TranslatedStringHandle|string|TextLib_TranslatedString Accepts handles or keys.
---@param fallBack string?
---@return string -- Defaults to the handle, of fallBack if specified.
function Text.GetTranslatedString(handle, fallBack)
    local str

    -- Object overload.
    if type(handle) == "table" then
        str = handle:GetString()
    else
        str = Ext.L10N.GetTranslatedString(handle)
    end

    if not str or str == "" then
        str = Ext.L10N.GetTranslatedStringFromKey(handle)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return str or fallBack or handle
end

---Registers a translated string.
---@overload fun(data:TextLib_TranslatedString)
---@param handle TranslatedStringHandle
---@param text string
function Text.RegisterTranslatedString(handle, text)
    local tsk ---@type TextLib_TranslatedString

    -- Table overload.
    if type(handle) == "table" then
        tsk = handle
    else
        tsk = {
            Handle = handle,
            Text = text,
        }
    end

    if Text._RegisteredTranslatedHandles[tsk.Handle] ~= nil then
        Text:Error("RegisterTranslatedString", "A TSK with the handle", tsk.Handle, "has already been registered.")
    elseif tsk.Handle:sub(1, 1) ~= "h" then
        Text:Error("RegisterTranslatedString", "Handle does not start with h - possibly malformed?")
    end

    tsk = _TranslatedString.Create(tsk)
    Text._RegisteredTranslatedHandles[tsk.Handle] = tsk

    -- Only set the handle's text if it hasn't been set already.
    if not Text.GetTranslatedStringTranslation(tsk.Handle, "English") then
        Text.SetTranslatedStringTranslation(tsk.Handle, "English", tsk.Text)
    end

    -- Bind handle to key
    if tsk.StringKey then
        Text.SetStringKey(tsk.StringKey, tsk.Handle)
    end
end

---Sets the text of a translated string.
---@param handle TranslatedStringHandle
---@param text string
function Text.SetTranslatedString(handle, text)
    Ext.L10N.CreateTranslatedStringHandle(handle, text)
end

---Binds a TSK to a string key.
---@param key string
---@param handle TranslatedStringHandle
function Text.SetStringKey(key, handle)
    Ext.L10N.CreateTranslatedStringKey(key, handle)
end

---Generates a template file for localizing strings registered through this library.
---@param modTable string? Defaults to "EpipEncounters"
---@param existingTemplate TextLib_LocalizationTemplate? If present, translated strings from this template will be patched into the new one, if the reference text is still up-to-date.
---@return TextLib_LocalizationTemplate, integer?, integer? -- Second param is amount of new strings, third is amount of outdated strings. Second param onwards is only returned while patching.
function Text.GenerateLocalizationTemplate(modTable, existingTemplate)
    ---@type TextLib_LocalizationTemplate
    local template = {
        ModTable = modTable or "EpipEncounters",
        FileFormatVersion = Text.LOCALIZATION_FILE_FORMAT_VERSION,
        TranslatedStrings = {},
    }
    local newStrings = 0

    for handle,data in pairs(Text._RegisteredTranslatedHandles) do
        if data.ModTable == modTable then
            local key = data.StringKey
            local text = data.Text
            local contextInfo = data.ContextDescription

            ---@type TextLib_LocalizationTemplate_Entry
            local entry = {
                ReferenceKey = key,
                ReferenceText = text,
                TranslatedText = "",
                ContextDescription = contextInfo,
            }

            -- Throw an event to allow other scripts to append metadata.
            entry = Text.Hooks.GetTranslationTemplateEntry:Throw({
                TranslatedString = data,
                Entry = entry,
            }).Entry

            if entry then
                template.TranslatedStrings[handle] = entry
                newStrings = newStrings + 1
            end
        end
    end

    local outdatedStrings = nil
    if existingTemplate then
        outdatedStrings = 0

        if existingTemplate.ModTable ~= modTable then
            Text:Error("GenerateLocalizationTemplate", "Generating a patched template with mismatched mod tables")
        end

        for handle,data in pairs(existingTemplate.TranslatedStrings or {}) do
            local templateEntry = template.TranslatedStrings[handle]

            -- Do not add in strings that are no longer used in the newly generated template.
            -- Also do not patch strings with outdated ReferenceText.
            if templateEntry then
                newStrings = newStrings - 1
                
                if data.ReferenceText == templateEntry.ReferenceText then
                    template.TranslatedStrings[handle].TranslatedText = data.TranslatedText
                else
                    outdatedStrings = outdatedStrings + 1
                end
            else
                outdatedStrings = outdatedStrings + 1
            end
        end
    else
        newStrings = nil
    end

    return template, newStrings, outdatedStrings
end

---Returns the language the game is set to.
---@return string
function Text.GetCurrentLanguage()
    return Ext.Utils.GetGlobalSwitches().ChatLanguage
end

---Sets the translation of a TSK.
---The handle's bound text will be updated if the game's language matches.
---@param handle TranslatedStringHandle
---@param language string
---@param text string
function Text.SetTranslatedStringTranslation(handle, language, text)
    local currentLanguage = Text.GetCurrentLanguage()

    Text._TranslatedStrings[language][handle] = text

    -- Update TSK if the language matches.
    if currentLanguage == language then
        Text.SetTranslatedString(handle, text)
    end
end

---Returns the translation for a handle.
---@param handle TranslatedStringHandle
---@param language string? Defaults to current language.
---@return string? --`nil` if the handle is not translated
function Text.GetTranslatedStringTranslation(handle, language)
    language = language or Text.GetCurrentLanguage()

    return Text._TranslatedStrings[language][handle]
end

---Loads a localization file. Must be in the format generated by GenerateLocalizationTemplate()
---@param language string
---@param filePath string
function Text.LoadLocalization(language, filePath)
    local file = IO.LoadFile(filePath, "data") ---@type TextLib_LocalizationTemplate

    if file and file.FileFormatVersion == Text.LOCALIZATION_FILE_FORMAT_VERSION then
        for handle,data in pairs(file.TranslatedStrings) do
            Text.SetTranslatedStringTranslation(handle, language, data.TranslatedText)
        end
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Append Feature ID to translation template entries.
-- TODO move this to Feature script
Text.Hooks.GetTranslationTemplateEntry:Subscribe(function (ev)
    local entry, tsk = ev.Entry, ev.TranslatedString

    ---@diagnostic disable undefined-field
    if tsk.FeatureID then
        local feature = Epip.GetFeature(tsk.ModTable, tsk.FeatureID)

        if feature.DoNotExportTSKs then
            ev.Entry = nil
        else
            entry.FeatureID = tsk.FeatureID
        end
    end
    ---@diagnostic enable undefined-field
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Automatically load localization files from mod folders.
local mods = Ext.Mod.GetLoadOrder()
for _,guid in ipairs(mods) do
    local mod = Ext.Mod.GetMod(guid)
    local currentLanguage = Text.GetCurrentLanguage()
    local modID = mod.Info.Directory

    -- Load localization override for each mod with a ModTable
    for modTableID,_ in pairs(Mods) do
        local path = string.format('Mods/%s/Localization/Epip/%s/%s.json', modID, currentLanguage, modTableID)

        Text.LoadLocalization(currentLanguage, path)
    end
end