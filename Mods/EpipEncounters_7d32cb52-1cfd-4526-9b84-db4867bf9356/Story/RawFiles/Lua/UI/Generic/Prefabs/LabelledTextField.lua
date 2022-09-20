
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI_Prefab_LabelledTextField : GenericUI_Prefab
local Text = {
    Label = nil, ---@type GenericUI_Prefab_Text
    Text = nil, ---@type GenericUI_Prefab_Text

    Events = {
        TextEdited = {}, ---@type Event<GenericUI_Element_StateButton_Event_StateChanged>
    }
}
Generic.RegisterPrefab("GenericUI_Prefab_LabelledTextField", Text)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@return GenericUI_Prefab_LabelledTextField
function Text.Create(ui, id, parent, label)
    local obj = Text:_Create(ui, id) ---@type GenericUI_Prefab_LabelledTextField

    local container = ui:CreateElement(obj:PrefixID("Container"), "GenericUI_Element_TiledBackground", parent)
    container:SetAlpha(0.2)

    local labelElement = TextPrefab.Create(ui, obj:PrefixID("Label"), container, label, "Left", Vector.zero2)
    local text = TextPrefab.Create(ui, obj:PrefixID("Text"), container, "", "Right", Vector.zero2)
    text:SetEditable(true)

    -- Forward events
    text.Events.TextEdited:Subscribe(function (ev)
        obj.Events.TextEdited:Throw(ev)
    end)

    obj.Text = text
    obj.Label = labelElement

    obj:SetSize(600, 50)
    
    return obj
end

---@param width number
---@param height number
function Text:SetSize(width, height)
    local container = self:GetMainElement() ---@type GenericUI_Element_TiledBackground

    container:SetBackground("Black", width, height)

    self.Label:SetSize(width, 30)
    self.Text:SetSize(width, 30)

    self.Label:SetPositionRelativeToParent("Left")
    self.Text:SetPositionRelativeToParent("Right")
end

---@param text string
function Text:SetText(text)
    self.Text:SetText(text)
end