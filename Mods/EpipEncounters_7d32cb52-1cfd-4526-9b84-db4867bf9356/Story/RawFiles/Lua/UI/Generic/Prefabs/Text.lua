
local Generic = Client.UI.Generic
local TextElement = Generic.ELEMENTS["Text"]
local TextLib = Text

---@class GenericUI_Prefab_Text : GenericUI_Prefab, GenericUI_Element_Text
local Text = {
    Element = nil, ---@type GenericUI_Element_Text

    ---@class GenericUI.Prefabs.Text.Events : GenericUI_Element_Text_Events
    Events = {
        TextEdited = {}, ---@type Event<GenericUI_Element_Text_Event_Changed>
        Focused = {}, ---@type Event<Empty>
        Unfocused = {}, ---@type Event<Empty>
    }
}
Generic.RegisterPrefab("GenericUI_Prefab_Text", Text)
InheritMultiple(Text, Generic:GetClass("GenericUI_Prefab"), TextElement) -- Inheritance with basic Text class works because all methods fetch the MC by ID

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_Text"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param text TextLib.String
---@param alignType GenericUI_Element_Text_Align
---@param size Vector2
---@return GenericUI_Prefab_Text
function Text.Create(ui, id, parent, text, alignType, size)
    local obj = Text:_Create(ui, id) ---@type GenericUI_Prefab_Text

    local textElement = ui:CreateElement(id, "GenericUI_Element_Text", parent)
    obj.Element = textElement

    textElement:SetType(alignType)
    textElement:SetSize(size[1], size[2])
    textElement:SetText(TextLib.Resolve(text))
    textElement:SetMouseEnabled(false)

    -- Forward events
    textElement.Events.Changed:Subscribe(function (ev)
        obj.Events.TextEdited:Throw(ev)
    end)
    textElement.Events.Focused:Subscribe(function (ev)
        obj.Events.Focused:Throw(ev)
    end)
    textElement.Events.Unfocused:Subscribe(function (ev)
        obj.Events.Unfocused:Throw(ev)
    end)

    -- Add Text element events, forward them
    for eventID,_ in pairs(textElement.Events) do
        obj.Events[eventID] = SubscribableEvent:New(eventID)
        textElement.Events[eventID]:Subscribe(function (ev)
            obj.Events[eventID]:Throw(ev)
        end)
    end

    return obj
end

---Sets the element's text.
---Note that the text will be culled if it doesn't fit the dimensions of the element.
---@param text TextLib.String
---@param setSize boolean? Defaults to `false`. If `true`, the element will be automatically resized to fit the new text.
function Text:SetText(text, setSize)
    self.Element:SetText(TextLib.Resolve(text), setSize)
end

function Text:GetMainElement()
    return self.Element
end