
---------------------------------------------
-- Prefab for text elements that animate their text appearing one character at a time.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI.Prefabs.TypewriterText : GenericUI_Prefab, GenericUI_Prefab_Text
---@field _CurrentIndex integer
---@field _CurrentTimer TimerLib_Entry
local TypewriterText = {
    CHARACTERS_PER_SECOND = 30,

    ---@class GenericUI.Prefabs.TypewriterText.Events : GenericUI_Element_Text_Events
    Events = {
        AnimationFinished = {}, ---@type Event<Empty>
    }
}
Generic.RegisterPrefab("GenericUI.Prefabs.TypewriterText", TypewriterText)
Inherit(TypewriterText, TextPrefab)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.TypewriterText"

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a TypewriterText prefab.
---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier?
---@param text string
---@param alignType GenericUI_Element_Text_Align
---@param size Vector2
---@return GenericUI.Prefabs.TypewriterText
function TypewriterText.Create(ui, id, parent, text, alignType, size)
    local obj = TextPrefab.Create(ui, id, parent, text, alignType, size) ---@type GenericUI.Prefabs.TypewriterText
    Inherit(obj, TypewriterText)
    obj._CurrentIndex = 1

    -- Add events
    for eventID,_ in pairs(TypewriterText.Events) do
        obj.Events[eventID] = SubscribableEvent:New(eventID)
    end

    return obj
end

---Sets the element's text and resets the animation.
---@param text string
function TypewriterText:SetText(text)
    if self._CurrentTimer then
        self._CurrentTimer:Cancel()
    end

    -- Reset animation
    local textLength = self:_GetTextVisibleCharacters(text)
    TextPrefab.SetText(self, "")
    self._CurrentIndex = 1

    -- Create timer for showing characters
    local updateTimer = Timer.Start(1 / self.CHARACTERS_PER_SECOND, function(_)
        local visibleText = Text.StripFontTags(text):sub(1, self._CurrentIndex) -- TODO support formatting tags
        TextPrefab.SetText(self, visibleText)

        self._CurrentIndex = self._CurrentIndex + 1

        -- Throw event once animation is finished
        if self._CurrentIndex >= textLength then
            self.Events.AnimationFinished:Throw()
        end
    end)
    updateTimer:SetRepeatCount(#text)
    self._CurrentTimer = updateTimer
end

---Returns the number of visible characters in the text, excluding HTML tags.
---@param text string
---@return integer
function TypewriterText:_GetTextVisibleCharacters(text)
    return #Text.StripFormatting(text)
end
