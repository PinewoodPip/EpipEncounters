
---@class TextLib
local Text = Text
local HTML = {}
Text.HTML = HTML

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class TextLib.HTML.Attribute
---@field ID string
---@field Param string|number

---------------------------------------------
-- METHODS
---------------------------------------------

---Wraps text in an anchor tag with an `href="event:{event}"` attribute.
---@param text string
---@param event string
---@param attributes TextLib.HTML.Attribute[]?
---@return string
function HTML.Anchor(text, event, attributes)
    attributes = attributes or {}
    table.insert(attributes, 1, {ID = "href", Param = "event:" .. event})
    return HTML.Tag(text, "a", attributes)
end

---Returns the top-level HTML tags of a text.
---Nested tags may be acquired by recursively calling the method on `Content` of each tag.
---@param text string
---@return {TagType:string, Tag:string, Attributes:TextLib.HTML.Attribute[], Content:string, StartIndex:integer, EndIndex:integer}[]
function HTML.GetTags(text)
    local tagStartPattern = "<([^ />]+).->"
    local tags = {} ---@type {Tag:string, Attributes:TextLib.HTML.Attribute[], Content:string}[]
    local searchLimitCounter = 0

    local startIndex, endIndex, currentTag = text:find(tagStartPattern)
    while startIndex do
        searchLimitCounter = searchLimitCounter + 1
        if searchLimitCounter > 200 then Text:Error("HTML.GetTags", "Tag search limit reached - possible infinite loop bug?") end

        local matchLength, match, tagEndPattern, endStartIndex, endEndIndex
        local content, openCount, open, close, i
        if currentTag == "br" then -- Fuck it, no support for others like this
            matchLength = 4
            goto Continue
        end

        tagEndPattern = string.format("</%s.->", currentTag)
        endStartIndex, endEndIndex = text:find(tagEndPattern, endIndex)
        while endStartIndex do
            if text:find(tagEndPattern, endEndIndex) then
                endStartIndex, endEndIndex = text:find(tagEndPattern, endEndIndex)
            else
                break
            end
        end
        content = text:sub(endIndex + 1, endStartIndex - 1)
        openCount = 0
        open = string.format("<%s", currentTag)
        close = string.format("</%s", currentTag)
        i = 1
        while i <= #content do -- Find the correct closing tag; there may be nested tags of the same type that we must ignore
            local isOpen = content:sub(i, #currentTag + i) == open
            local isClose = content:sub(i, 1 + #currentTag + i) == close

            if isOpen then
                openCount = openCount + 1
            elseif isClose then
                openCount = openCount - 1
                if openCount < 0 then
                    break
                end
            end
            i = i + 1
        end
        endStartIndex = i
        endEndIndex = i + 2 + #currentTag + endIndex

        match = text:sub(startIndex, endEndIndex)
        if match then
            matchLength = #match
            table.insert(tags, {
                TagType = currentTag,
                Tag = match,
                Attributes = HTML.GetAttributes(match),
                Content = match:match("^<.->(.*)</.->$"),
                StartIndex = startIndex,
                EndIndex = startIndex + #match,
            })
        else
            Text:Error("HTML.GetTags", "Failed to find closing tag - HTML invalid or bug?", "Finding tag", currentTag, "in string", text:sub(startIndex))
        end
        ::Continue::
        startIndex, endIndex, currentTag = text:find(tagStartPattern, startIndex + matchLength)
    end

    return tags
end

---Returns the attributes of a tag.
---@param tag string
---@return TextLib.HTML.Attribute[] --Params will always be in string type.
function HTML.GetAttributes(tag)
    local attributes = {} ---@type TextLib.HTML.Attribute[]
    local attributesText = tag:match("<[^ ]- (.-)>.*</.->") ---@type string

    if attributesText then
        for id,param in attributesText:gmatch("([^ ]-)=\"?\'?([^ \"\']+)") do
            param = param:match("^\"(.-)\"$") or param -- Strip trailing quotation marks
            param = param:match("^\'(.-)\'$") or param
            table.insert(attributes, {ID = id, Param = param})
        end
    end

    return attributes
end

---Wraps text in an HTML tag.
---@param text string
---@param tag string
---@param attributes TextLib.HTML.Attribute[]?
---@return string
function HTML.Tag(text, tag, attributes)
    local parsedAttributes = {} ---@type table|string
    for i,attribute in pairs(attributes or {}) do
        parsedAttributes[i] = string.format("%s=\"%s\"", attribute.ID, attribute.Param)
    end
    if parsedAttributes[1] then
        parsedAttributes = " " .. Text.Join(parsedAttributes, " ")
    else
        parsedAttributes = ""
    end

    return string.format("<%s%s>%s</%s>", tag, parsedAttributes, text, tag)
end