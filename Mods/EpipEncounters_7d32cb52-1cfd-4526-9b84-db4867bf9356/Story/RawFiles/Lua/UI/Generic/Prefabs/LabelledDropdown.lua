
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
    container:SetBackground("Black", 600, 50)
    container:SetAlpha(0.2)

    local labelElement = container:AddChild(obj:PrefixID("Label"), "GenericUI_Element_Text")
    labelElement:SetSize(200, 50)
    labelElement:SetText(label)

    local combo = container:AddChild(obj:PrefixID("Combo"), "GenericUI_Element_ComboBox")
    combo:SetPositionRelativeToParent("Right")

    for _,option in ipairs(opts) do
        combo:AddOption(option.ID, option.Label)
    end

    obj.Label = labelElement
    obj.ComboBox = combo

    return obj
end

---@param id string
function Dropdown:SelectOption(id)
    self.ComboBox:SelectOption(id)
end