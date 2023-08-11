
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
    self._HTMLText = text

    TextPrefab.SetText(self, text, setSize)
end

---Returns the starting and end indexes of anchors within the text.
---@return {Event:string, Text:string, StartIndex:integer, Length:integer}[]
function AnchoredText:_GetAnchorIndexes()
    local htmlText = self._HTMLText
    local tag = "<a href=\"event:(.-)\">(.-)</a>"
    local startIndex, endIndex, eventName, capturedText = htmlText:find(tag)
    local indexes = {} ---@type {Event:string, Text:string, StartIndex:integer, Length:integer}[]

    while startIndex do
        local realTextStartIndex = 1
        local tagCount = 0
        for i=1,startIndex,1 do
            local char = htmlText:sub(i, i)
            -- print(char)
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
        })

        startIndex, endIndex, eventName, capturedText = htmlText:find(tag, endIndex)
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
            self.Events.AnchorMouseOver:Throw(tagEvent)
        elseif not tagEvent and self._CurrentHoveredAnchor then -- Only throw event if hovering out of a tag.
            self.Events.AnchorMouseOut:Throw(self._CurrentHoveredAnchor)
            self._CurrentHoveredAnchor = nil
        end
    end)

    -- Clear hovered tag when we hover out of the element entirely,
    -- as in this case MouseMove does not fire.
    self.Element.Events.MouseOut:Subscribe(function (_)
        if self._CurrentHoveredAnchor then
            self.Events.AnchorMouseOut:Throw(self._CurrentHoveredAnchor)
            self._CurrentHoveredAnchor = nil
        end
    end)
end