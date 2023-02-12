
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI_Prefab_LabelledTextField : GenericUI_Prefab_FormElement
---@field Text GenericUI_Prefab_Text
local Text = {
    Events = {
        TextEdited = {}, ---@type Event<GenericUI_Element_Text_Event_Changed>
    }
}
OOP.SetMetatable(Text, Generic.GetPrefab("GenericUI_Prefab_FormElement"))
Generic.RegisterPrefab("GenericUI_Prefab_LabelledTextField", Text)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@param size Vector2? Defaults to `DEFAULT_SIZE`
---@return GenericUI_Prefab_LabelledTextField
function Text.Create(ui, id, parent, label, size)
    size = size or Text.DEFAULT_SIZE
    local obj = Text:_Create(ui, id) ---@type GenericUI_Prefab_LabelledTextField
    obj:__SetupBackground(parent, size)
    obj:SetLabel(label)

    local text = TextPrefab.Create(ui, obj:PrefixID("Text"), obj:GetRootElement(), "", "Right", Vector.zero2)
    text:SetEditable(true)

    -- Forward events
    text.Events.TextEdited:Subscribe(function (ev)
        obj.Events.TextEdited:Throw(ev)
    end)

    obj.Text = text

    obj:SetSize(size:unpack())
    
    return obj
end

---@param width number
---@param height number
function Text:SetSize(width, height)
    self:SetBackgroundSize(Vector.Create(width, height))

    self.Label:SetSize(width, 30)
    self.Text:SetSize(width, 30)

    self.Label:SetPositionRelativeToParent("Left")
    self.Text:SetPositionRelativeToParent("Right")
end

---@param text string
function Text:SetText(text)
    self.Text:SetText(text)
end