
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_Text : GenericUI_Prefab, GenericUI_Element_Text
local Text = {
    Element = nil, ---@type GenericUI_Element_Text

    Events = {
        TextEdited = {}, ---@type Event<GenericUI_Element_Text_Event_Changed>
        Focused = {}, ---@type Event<EmptyEvent>
        Unfocused = {}, ---@type Event<EmptyEvent>
    }
}
Generic.RegisterPrefab("GenericUI_Prefab_Text", Text)
InheritMultiple(Text, Generic._Prefab, Generic.ELEMENTS.Text) -- Inheritance with basic Text class works because all methods fetch the MC by ID

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_Text"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param text string
---@param alignType GenericUI_Element_Text_Align
---@param size Vector2
---@return GenericUI_Prefab_Text
function Text.Create(ui, id, parent, text, alignType, size)
    local obj = Text:_Create(ui, id) ---@type GenericUI_Prefab_Text

    local textElement = ui:CreateElement(id, "GenericUI_Element_Text", parent)
    obj.Element = textElement

    textElement:SetType(alignType)
    textElement:SetSize(size[1], size[2])
    textElement:SetText(text)
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

    return obj
end

---@param text string
function Text:SetText(text)
    self.Element:SetText(text)
end

function Text:GetMainElement()
    return self.Element
end