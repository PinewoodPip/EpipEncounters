
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_Text : GenericUI_Prefab, GenericUI_Element_Text
local Text = {
    Element = nil, ---@type GenericUI_Element_Text

    Events = {
        TextEdited = {}, ---@type SubscribableEvent<GenericUI_Element_Text_Event_Changed>
    }
}
Generic.RegisterPrefab("GenericUI_Prefab_Text", Text)
InheritMultiple(Text, Generic._Prefab, Generic.ELEMENTS.Text)

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

    -- Forward events
    textElement.Events.Changed:Subscribe(function (ev)
        obj.Events.TextEdited:Throw(ev)
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