
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")

---@class TextLib : Library
Text = {
    _RegisteredTranslatedHandles = {}, ---@type table<TranslatedStringHandle, TextLib_TranslatedString> Maps handle to original text.
    _TranslatedStrings = DefaultTable.Create({}), ---@type table<string, table<TranslatedStringHandle, string>> -- Maps language to table of TSK translations.

    CommonStrings = {},

    LOCALIZATION_FILE_FORMAT_VERSION = 0,

    ---@enum TextLib_Font
    FONTS = {
        BOLD = "Ubuntu Mono",
        ITALIC = "Averia Serif",
        NORMAL = "Nueva Std Cond",
        BIG_NUMBERS = "CollegiateBlackFLF",
        FALLBACK = "fb",
    },
    -- Languages that use the fallback font.
    -- Might be incomplete.
    ---@type set<language>
    FALLBACK_FONT_LANGUAGES = {
        ["Chinese"] = true,
        ["Chinesetraditional"] = true,
        ["Japanese"] = true,
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

---@alias TextLib_String TextLib_TranslatedString|string -- Legacy alias; use `TextLib.String` instead. TODO migrate all annotations
---@alias TextLib.String TextLib_String

---@class TextLib_TranslatedString
---@field Handle TranslatedStringHandle
---@field Text string
---@field ModTable ModTableID?
---@field StringKey string?
---@field ContextDescription string?
---@field FormatOptions TextFormatData? If present, after resolving, the string will be formatted. May be used to avoid formatting tags from being visible to translators.
local _TranslatedString = {}

---@param data TextLib_TranslatedString
---@return TextLib_TranslatedString
function _TranslatedString.Create(data)
    Inherit(data, _TranslatedString)

    return data
end

---Resolves and formats the string.
---Note that resolving the string already runs formatting via `FormatOptions`; this method will run afterwards and is intended for dynamic placeholder replacement.
---@param ... any|TextFormatData If using TextFormatData, only the first parameter will be used. Otherwise behaves as `string.format()`.
---@return string
function _TranslatedString:Format(...)
    local resolvedString = self:GetString()
    local param1 = ...
    if type(param1) == "table" then
        return Text.Format(resolvedString, param1)
    else
        return string.format(resolvedString, ...)
    end
end

---@return string
function _TranslatedString:GetString()
    local resolvedStr = Text.GetTranslatedString(self.Handle, self.Handle)
    if self.FormatOptions then
        resolvedStr = Text.Format(resolvedStr, self.FormatOptions)
    end
    return resolvedStr
end

---@alias FontAlign "center" | "right" | "left"

---@class TextFormatData
---@field FontType TextLib_Font?
---@field Size (number|string)? "+X" and "-X" are supported for relative sizes.
---@field Color string?
---@field Align FontAlign?
---@field FormatArgs (any|TextFormatData)[]?
---@field Text (string|TextLib_TranslatedString)? Used for formatting strings with recursive `Text.Format()` calls.
---@field RemovePreviousFormatting boolean? Defaults to `false`.
---@field Casing ("Unmodified"|"Lowercase"|"Uppercase")? Defaults to `"Unmodified"`. If using other options, be sure to first strip any formatting from the string.
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

    local pattern = "^(-?%d*)%.?(%d*)$"
    local wholeText, decimalsText = value:match(pattern)
    local output = wholeText

    if decimals > 0 and decimalsText and decimalsText:len() > 0 then
        decimalsText = string.sub(decimalsText, 1, decimals)
        output = output .. "." .. decimalsText

        output = Text.RemoveTrailingZeros(tonumber(output))
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
---@overload fun(str:string[], separator:string?):string
---@return string
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

---Joins two strings inserting a line break between them.
---@param str1 string The line break is not added if this string is empty.
---@param str2 string
---@return string
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

---Returns whether str contains the pattern.
---@param str string
---@param pattern pattern
function Text.Contains(str, pattern)
    return str:find(pattern) ~= nil
end

---Adds padding characters to a string to meet a minimum length.
---@param str string
---@param minLength integer
---@param paddingCharacter string? Defaults to `" "`
---@param direction ("front"|"back")? Defaults to `"front"`.
---@return string
function Text.AddPadding(str, minLength, paddingCharacter, direction)
    paddingCharacter = paddingCharacter or " "
    direction = direction or "front"

    while #str < minLength do
        if direction == "front" then
            str = paddingCharacter .. str
        else
            str = str .. paddingCharacter
        end
    end

    return str
end

---Replaces a plain string within text.
---@param text string
---@param str string
---@param replacement string
---@param count integer? Amount of ocurrences to replace. Defaults to `math.maxinteger`.
---@return string
function Text.Replace(text, str, replacement, count)
    count = count or math.maxinteger
    local startIndex, endIndex = text:find(str, nil, true)
    local replacedCount = 0
    while startIndex and replacedCount < count do
        text = text:sub(1, startIndex - 1) .. replacement .. text:sub(endIndex + 1)
        startIndex, endIndex = text:find(str, nil, true)
        replacedCount = replacedCount + 1
    end
    return text
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

---Turns the first letter of a string into lowercase.
---@param str string
---@return string
function Text.Uncapitalize(str)
    local result, _ = str:gsub("^%L", string.lower)
    return result
end

---Format a string.
---@param str string
---@param formatData TextFormatData
---@overload fun(str:TextFormatData)
---@return string 
function Text.Format(str, formatData)
    if getmetatable(formatData) == nil then
        setmetatable(formatData, {__index = _TextFormatData}) -- TODO is this even necessary?
    end

    -- FormatData-only overload.
    -- Passing a TSK as the only parameter is not supported - use GetString() instead.
    if type(str) == "table" then
        str, formatData = Text.Resolve(str.Text), formatData == nil and str or formatData
    end

    if formatData.RemovePreviousFormatting then
        str = Text.StripFontTags(str)
    end

    -- Apply casing changes
    -- This will break prior formatting of the string;
    -- there is no easy solution other than parsing the whole HTML tree (overkill, left up to the user).
    if formatData.Casing then
        if formatData.Casing == "Lowercase" then
            str = str:lower()
        elseif formatData.Casing == "Uppercase" then
            str = str:upper()
        end
    end

    -- Parse args, which can be a TextFormatData as well.
    local finalArgs = {}
    if formatData.FormatArgs then
        for _,arg in ipairs(formatData.FormatArgs) do
            if type(arg) == "table" then
                ---@cast arg TextFormatData|TextLib_TranslatedString
                table.insert(finalArgs, arg.Handle == nil and Text.Format(Text.Resolve(arg.Text), arg) or arg:GetString())
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

    local color = ""
    if formatData.Color then
        color = string.format(" color='%s'", formatData.Color)
    end

    local size = ""
    if formatData.Size then
        size = string.format(" size='%s'", formatData.Size)
    end

    if fontType ~= "" or color ~= "" or size ~= "" then
        str = string.format("<font%s%s%s>%s</font>", fontType, color, size, str)
    end

    -- Alignment requires <p> tag.
    if formatData.Align then
        str = Text.HTML.Tag(str, "p", {
            {
                ID = "align",
                Param = formatData.Align
            },
        })
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

---Splits up a pascal-case (ex. "PascalCase") string into words.
---Will split up consecutive uppercase characters.
---@param str string First letter will be automatically capitalized.
---@return string[]
function Text.SplitPascalCase(str)
    local words = {} ---@type string[]
    str = Text.Capitalize(str)

    for word in str:gmatch("(%u%l*)") do
        table.insert(words, word)
    end

    return words
end

---Resolves and formats a TSK that uses Larian's placeholder format ("[1]", "[2]" etc.).
---@param handle TranslatedStringHandle
---@param ... any
function Text.FormatLarianTranslatedString(handle, ...)
    return Text.ReplaceLarianPlaceholders(Text.GetTranslatedString(handle), {...})
end

---Replaces Larian placeholders (ex. "[1]", "[2]") within str.
---@param str string
---@param replacement (string|string[])? Defaults to empty string. If a list is passed and it's length is shorter than the amount of placeholders, the last placeholder will be used for the remaining replacements.
---@return string
function Text.ReplaceLarianPlaceholders(str, replacement)
    replacement = replacement or ""
    local replacements
    if type(replacement) ~= "table" then -- String overload.
        replacements = {replacement}
    else
        replacements = replacement
    end

    local replacementIndex = 1
    local placeholder = "[" .. tostring(replacementIndex) .. "]"
    while str:find(placeholder, nil, true) do
        str = Text.Replace(str, placeholder, replacements[replacementIndex] or replacements[#replacements]) -- Use last replacement available as fallback.
        replacementIndex = replacementIndex + 1
        placeholder = "[" .. tostring(replacementIndex) .. "]"
    end

    return str
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

---Returns whether a TSK handle was registered **through the Text library.**
---@param handle TranslatedStringHandle
---@return boolean
function Text.IsTranslatedStringRegistered(handle)
    return Text._RegisteredTranslatedHandles[handle] ~= nil
end

---Returns the string bound to a TranslatedStringHandle, or a key.
---@param handle TranslatedStringHandle|string|TextLib_TranslatedString Accepts handles or keys.
---@param fallBack string?
---@return string -- Defaults to the handle, or fallBack if specified.
function Text.GetTranslatedString(handle, fallBack)
    local str

    -- TSKs cannot be loaded during LoadModule due to a bug with TSKs that have a handle but do not exist within an lsx.
    -- Doing so causes them to be cleared.
    if GameState.GetState() == "LoadModule" and not Text.IsTranslatedStringRegistered(handle) then
        Text:LogError("GetTranslatedString", "Reading non-Epip TSKs during module load is not supported!", handle)
        return fallBack
    else
        -- Object overload.
        if type(handle) == "table" then
            str = handle:GetString()
        else
            str = Ext.L10N.GetTranslatedString(handle)
        end

        if not str or str == "" then
            str = Ext.L10N.GetTranslatedStringFromKey(handle)
        end

        -- Consider empty strings invalid and use fallback.
        if str == "" then
            str = fallBack or handle ---@type string
        end
    end

    return str
end

---Resolves a translated string, or returns the string itself if the passed parameter is already of string type.
---Useful to reduce verbosity in situations where a text variable might be a TSK or a raw lua string.
---@param str TextLib_TranslatedString|string
function Text.Resolve(str)
    return type(str) == "table" and str:GetString() or str
end

---Returns the handle for a string key.
---@param stringKey string
---@return TranslatedStringHandle?
function Text.GetStringKeyHandle(stringKey)
    local _, handle = Ext.L10N.GetTranslatedStringFromKey(stringKey)
    return handle
end

---Registers a translated string.
---@overload fun(data:TextLib_TranslatedString):TextLib_TranslatedString
---@param handle TranslatedStringHandle
---@param text string
---@return TextLib_TranslatedString
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

    return tsk
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
---@return TextLib_LocalizationTemplate, integer[]?, integer[]? -- Second param is new strings, third is outdated strings. Second param onwards is only returned while patching.
function Text.GenerateLocalizationTemplate(modTable, existingTemplate)
    ---@type TextLib_LocalizationTemplate
    local template = {
        ModTable = modTable or "EpipEncounters",
        FileFormatVersion = Text.LOCALIZATION_FILE_FORMAT_VERSION,
        TranslatedStrings = {},
    }
    local newStrings = {}

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
                table.insert(newStrings, handle)
            end
        end
    end

    local outdatedStrings = nil
    if existingTemplate then
        outdatedStrings = {}

        if existingTemplate.ModTable ~= modTable then
            Text:Error("GenerateLocalizationTemplate", "Generating a patched template with mismatched mod tables")
        end

        for handle,data in pairs(existingTemplate.TranslatedStrings or {}) do
            local templateEntry = template.TranslatedStrings[handle]

            -- Do not add in strings that are no longer used in the newly generated template.
            -- Also do not patch strings with outdated ReferenceText.
            if templateEntry then
                table.remove(newStrings, table.reverseLookup(newStrings, handle))

                -- Track outdated translations
                if data.ReferenceText ~= templateEntry.ReferenceText then
                    table.insert(outdatedStrings, handle)
                end

                template.TranslatedStrings[handle].TranslatedText = data.TranslatedText
            else -- Track removed strings
                table.insert(outdatedStrings, handle)
            end
        end
    else
        newStrings = nil
    end

    return template, newStrings, outdatedStrings
end

---Returns the language the game is set to.
---@param useOverride boolean? Whether to consider the Epip language override setting. Defaults to `true`.
---@return string
function Text.GetCurrentLanguage(useOverride)
    local language = Ext.Utils.GetGlobalSwitches().ChatLanguage
    local settingOverride = useOverride ~= false and IO.LoadFile("Epip/LanguageOverride.txt", "user", true) or ""
    if settingOverride and settingOverride ~= "" then
        language = settingOverride
    end
    return language
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
    if currentLanguage == language or (language == "English" and not Text.GetTranslatedStringTranslation(handle, currentLanguage)) then
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

---Returns the GUID passed by parameter with any prefixes removed.
---@param guid PrefixedGUID
---@return GUID
function Text.RemoveGUIDPrefix(guid)
    return guid:match(Text.PATTERNS.GUID)
end

---Formats a time in the format MM:SS, where M is minutes and S is seconds.
---@param time integer In seconds.
---@return string
function Text.FormatTime(time)
    local minutes = time // 60
    local seconds = math.ceil(time % 60)
    if seconds == 60 then -- Round up to a whole minute.
        minutes = minutes + 1
        seconds = 0
    end
    minutes, seconds = Text.RemoveTrailingZeros(minutes), tostring(seconds) -- RemoveTrailingZeros is necessary as even an integer division afterwards can produce ex. "1.0"
    return Text.Format("%s:%s", {
        FormatArgs = {
            Text.AddPadding(minutes, 2, "0", "front"),
            Text.AddPadding(seconds, 2, "0", "front"),
        },
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Append Feature ID to translation template entries.
-- TODO move this to Feature script
Text.Hooks.GetTranslationTemplateEntry:Subscribe(function (ev)
    local entry, tsk = ev.Entry, ev.TranslatedString

    ---@diagnostic disable undefined-field
    if tsk.FeatureID then -- TODO rename this field and adjust check below, as it is used by library classes too.
        entry.FeatureID = tsk.FeatureID

        -- Check for features whose TSKs are excluded from exports (ex. top-secret WIP features)
        local feature = Epip.GetFeature(tsk.ModTable, tsk.FeatureID)
        if feature and feature.DoNotExportTSKs then
            ev.Entry = nil
        end
    end
    ---@diagnostic enable undefined-field
end)
