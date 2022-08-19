
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_LabelledDropdown : GenericUI_Prefab
local Dropdown = {
    Label = nil, ---@type GenericUI_Element_Text
    ComboBox = nil, ---@type GenericUI_Element_ComboBox
}
Generic.RegisterPrefab("GenericUI_Prefab_LabelledDropdown", Dropdown)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@param opts GenericUI_Element_ComboBox_Option[]?
---@return GenericUI_Prefab_LabelledDropdown
function Dropdown.Create(ui, id, parent, label, opts)
    opts = opts or {}
    local obj = {ID = id, UI = ui} ---@type GenericUI_Prefab_LabelledDropdown
    Inherit(obj, Dropdown)
    obj:_Setup()

    local container = ui:CreateElement(obj:PrefixID("Container"), "GenericUI_Element_TiledBackground", parent)
    container:SetAlpha(0.2)

    local labelElement = container:AddChild(obj:PrefixID("Label"), "GenericUI_Element_Text")
    labelElement:SetType("Left")
    labelElement:SetText(label)

    local combo = container:AddChild(obj:PrefixID("Combo"), "GenericUI_Element_ComboBox")

    for _,option in ipairs(opts) do
        combo:AddOption(option.ID, option.Label)
    end

    obj.Label = labelElement
    obj.ComboBox = combo

    obj:SetSize(600, 50) -- Default size

    return obj
end

---@param width number
---@param height number
function Dropdown:SetSize(width, height)
    local labelElement = self.Label
    local combo = self.ComboBox
    local container = self:GetMainElement() ---@type GenericUI_Element_TiledBackground

    container:SetBackground("Black", width, height)

    labelElement:SetSize(width, 30)
    labelElement:SetPositionRelativeToParent("Left")

    combo:SetPositionRelativeToParent("Right")
end

---@param id string
function Dropdown:SelectOption(id)
    self.ComboBox:SelectOption(id)
end