
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_Text : GenericUI_Prefab
local Text = {
    Element = nil, ---@type GenericUI_Element_Text
}
Generic.RegisterPrefab("GenericUI_Prefab_Text", Text)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param text string
---@param alignType integer
---@param size Vector2
---@return GenericUI_Prefab_Text
function Text.Create(ui, id, parent, text, alignType, size)
    local obj = {ID = id} ---@type GenericUI_Prefab_Text
    Inherit(obj, Text)
    obj:_Setup()

    local textElement = ui:CreateElement(obj:PrefixID("Text"), "GenericUI_Element_Text", parent)
    obj.Element = textElement

    textElement:SetType(alignType)
    textElement:SetSize(size[1], size[2])
    textElement:SetText(text)

    return obj
end

---@param text string
function Text:SetText(text)
    self.Element:SetText(text)
end

function Text:GetMainElement()
    return self.Element
end