
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_LabelledCheckbox : GenericUI_Prefab
local Checkbox = {
    Checkbox = nil, ---@type GenericUI_Element_StateButton
    Label = nil, ---@type GenericUI_Element_Text
}
Generic.RegisterPrefab("GenericUI_Prefab_LabelledCheckbox", Checkbox)

---------------------------------------------
-- EVENTS
---------------------------------------------

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@return GenericUI_Prefab_LabelledCheckbox
function Checkbox.Create(ui, id, parent, label)
    local obj = Checkbox:_Create(ui, id) ---@type GenericUI_Prefab_LabelledCheckbox

    local container = ui:CreateElement(obj:PrefixID("Container"), "GenericUI_Element_TiledBackground", parent)
    container:SetAlpha(0.2)

    local text = container:AddChild("Label", "GenericUI_Element_Text")
    text:SetType("Left")
    text:SetText(label)

    local checkbox = container:AddChild("Checkbox", "GenericUI_Element_StateButton")
    checkbox:SetType("CheckBox")

    obj.Checkbox = checkbox
    obj.Label = text

    obj:SetSize(600, 50)

    return obj
end

---@param active boolean
function Checkbox:SetState(active)
    self.Checkbox:SetActive(active)
end

-- TODO
-- function Checkbox:IsTicked()
--     return self.Checkbox
-- end

---@param width number
---@param height number
function Checkbox:SetSize(width, height)
    local container = self:GetMainElement() ---@type GenericUI_Element_TiledBackground

    container:SetBackground("Black", width, height)

    self.Label:SetSize(width, 30)

    self.Label:SetPositionRelativeToParent("Left")
    self.Checkbox:SetPositionRelativeToParent("Right")
end