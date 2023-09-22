
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI.Prefabs.AnchoredText : GenericUI_Prefab, GenericUI_Prefab_Text
---@field _HTMLText string
---@field _CurrentHoveredAnchor GenericUI.Prefabs.AnchoredText.Events.AnchorEvent
local AnchoredText = {
    ---@class GenericUI.Prefabs.AnchoredText.Events : GenericUI_Element_Text_Events
    Events = {
        AnchorClicked = {}, ---@type Event<GenericUI.Prefabs.AnchoredText.Events.AnchorEvent>
        AnchorMouseOver = {}, ---@type Event<GenericUI.Prefabs.AnchoredText.Events.AnchorEvent>
        AnchorMouseOut = {}, ---@type Event<GenericUI.Prefabs.AnchoredText.Events.AnchorEvent>
    }
}
Generic.RegisterPrefab("GenericUI.Prefabs.AnchoredText", AnchoredText)
Inherit(AnchoredText, TextPrefab)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.AnchoredText"

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class GenericUI.Prefabs.AnchoredText.Events.AnchorEvent
---@field ID string
---@field Text string

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an AnchoredText.
---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param text string
---@param alignType GenericUI_Element_Text_Align
---@param size Vector2
---@return GenericUI.Prefabs.AnchoredText
function AnchoredText.Create(ui, id, parent, text, alignType, size)
    local obj = TextPrefab.Create(ui, id, parent, text, alignType, size) ---@type GenericUI.Prefabs.AnchoredText
    Inherit(obj, AnchoredText)

    -- Add events
    for eventID,_ in pairs(AnchoredText.Events) do
        obj.Events[eventID] = SubscribableEvent:New(eventID)
    end

    obj:SetText(text)
    obj:_SetupListeners()
    obj:SetMouseEnabled(true)

    return obj
end

---Sets the element's text.
---Note that the text will be culled if it doesn't fit the dimensions of the element.
---Keywords should use `<a href="event:myevent">` tags to enable anchor events on them.
---@param text string
---@param setSize boolean? Defaults to `false`. If `true`, the element will be automatically resized to fit the new text.
function AnchoredText:SetText(text, setSize)
    local parsedText = text
    local startIndex = 1
    local start, endIndex, content = parsedText:find("<a .->(.-)</a>", startIndex)
    local count = 1
    while start do -- Add an index attribute to each anchor tag.
        local attributes = Text.HTML.GetAttributes(parsedText:sub(start, endIndex))
        table.insert(attributes, {ID = "anchorindex", Param = count})
        parsedText = parsedText:sub(1, start - 1) .. Text.HTML.Tag(content, "a", attributes) .. parsedText:sub(endIndex + 1) -- Replace <a> tag with new one

        startIndex = endIndex
        count = count + 1
        start, endIndex, content = parsedText:find("<a .->(.-)</a>", startIndex)
    end

    self._OriginalText = text
    self._HTMLText = parsedText
    local colorizedText = self:_ColorizeText(parsedText)
    TextPrefab.SetText(self, colorizedText, setSize)
end

---Parses text and highlights selected anchors in a color specified by an `inactivecolor={hex color}` and `activecolor={hex color}` attributes in the anchor tag.
---The active color will be used if the tag is being hovered over; the inactive color will be used otherwise.
---Recursive; will search all tags and subtags.
---@param text string
---@return string
function AnchoredText:_ColorizeText(text)
    local currentSelection = self._CurrentHoveredAnchor
    local tags = Text.HTML.GetTags(text)

    for _,tag in ipairs(tags) do
        if tag.TagType == "a" then
            local eventID
            for _,attr in ipairs(tag.Attributes) do
                if attr.ID == "href" then
                    eventID = attr.Param:match("^event:(.*)$")
                end
            end

            if eventID then
                for _,attr in ipairs(tag.Attributes) do
                    if attr.ID == "inactivecolor" and (not currentSelection or currentSelection.ID ~= eventID) then -- TODO consider anchor indexes
                        text = Text.Replace(text, tag.Tag, Text.Format(tag.Tag, {Color = attr.Param}), 1)
                    elseif attr.ID == "activecolor" and currentSelection and currentSelection.ID == eventID then -- TODO consider anchor indexes
                        text = Text.Replace(text, tag.Tag, Text.Format(tag.Tag, {Color = attr.Param}), 1)
                    end
                end
            end
        end

        -- Colorize recursively
        local newTag = Text.HTML.Tag(self:_ColorizeText(tag.Content), tag.TagType, tag.Attributes)

        text = Text.Replace(text, tag.Tag, newTag, 1)
    end

    return text
end

---Returns the starting and end indexes of anchors within the text.
---@return {Event:string, Text:string, StartIndex:integer, Length:integer, AnchorIndex:integer}[]
function AnchoredText:_GetAnchorIndexes()
    local htmlText = self._HTMLText
    local tag = "<a href=\"event:(.-)\".-anchorindex=\"(.-)\".->(.-)</a>"
    local startIndex, endIndex, eventName, anchorIndex, capturedText = htmlText:find(tag)
    local indexes = {} ---@type {Event:string, Text:string, StartIndex:integer, Length:integer}[]

    while startIndex do
        local realTextStartIndex = 1
        local tagCount = 0
        for i=1,startIndex,1 do
            local char = htmlText:sub(i, i)
            if char == "<" then
                tagCount = tagCount + 1
            elseif char == ">" then
                tagCount = tagCount - 1
            elseif tagCount == 0 then
                realTextStartIndex = realTextStartIndex + 1
            end
        end

        table.insert(indexes, {
            Event = eventName,
            StartIndex = realTextStartIndex,
            Length = #capturedText,
            Text = capturedText,
            AnchorIndex = tonumber(anchorIndex),
        })

        startIndex, endIndex, eventName, anchorIndex, capturedText = htmlText:find(tag, endIndex)
    end

    return indexes
end

---Sets up event listeners.
function AnchoredText:_SetupListeners()
    self:SetMouseMoveEventEnabled(true)

    -- Listen for mouse clicks on tags
    self.Element.Events.MouseUp:Subscribe(function (_)
        local events = self:_GetAnchorIndexes()
        for _,eventTag in ipairs(events) do
            if self:IsMouseWithinRange(eventTag.StartIndex, eventTag.Length) then
                self.Events.AnchorClicked:Throw({
                    ID = eventTag.Event,
                    Text = eventTag.Text,
                })
            end
        end
    end)

    -- Listen for tags being hovered into or out of.
    self.Element.Events.MouseMove:Subscribe(function (_)
        local events = self:_GetAnchorIndexes()
        local tagEvent = nil
        for _,eventTag in ipairs(events) do
            if self:IsMouseWithinRange(eventTag.StartIndex, eventTag.Length) then
                tagEvent = {
                    ID = eventTag.Event,
                    Text = eventTag.Text,
                }
                break
            end
        end

        if tagEvent and (self._CurrentHoveredAnchor == nil or self._CurrentHoveredAnchor.ID ~= tagEvent.ID) then -- Only throw event if previous hovered tag was nil, or different.
            self._CurrentHoveredAnchor = tagEvent
            self:SetText(self._OriginalText)
            self.Events.AnchorMouseOver:Throw(tagEvent)
        elseif not tagEvent and self._CurrentHoveredAnchor then -- Only throw event if hovering out of a tag.
            self.Events.AnchorMouseOut:Throw(self._CurrentHoveredAnchor)
            self._CurrentHoveredAnchor = nil
            self:SetText(self._OriginalText)
        end
    end)

    -- Clear hovered tag when we hover out of the element entirely,
    -- as in this case MouseMove does not fire.
    self.Element.Events.MouseOut:Subscribe(function (_)
        if self._CurrentHoveredAnchor then
            self._CurrentHoveredAnchor = nil
            self:SetText(self._OriginalText)
            self.Events.AnchorMouseOut:Throw(self._CurrentHoveredAnchor)
        end
    end)
end