
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_LabelledDropdown : GenericUI_Prefab_FormElement
---@field ComboBox GenericUI_Element_ComboBox
local Dropdown = {
    Events = {
        OptionSelected = {}, ---@type Event<GenericUI_Element_ComboBox_Event_OptionSelected>
    }
}
OOP.SetMetatable(Dropdown, Generic.GetPrefab("GenericUI_Prefab_FormElement"))
Generic.RegisterPrefab("GenericUI_Prefab_LabelledDropdown", Dropdown)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_LabelledDropdown"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier?
---@param label string
---@param opts GenericUI_Element_ComboBox_Option[]?
---@param size Vector2? Defaults to `DEFAULT_SIZE`
---@return GenericUI_Prefab_LabelledDropdown
function Dropdown.Create(ui, id, parent, label, opts, size)
    opts = opts or {}
    size = size or Dropdown.DEFAULT_SIZE
    local obj = Dropdown:_Create(ui, id) ---@cast obj GenericUI_Prefab_LabelledDropdown
    obj:__SetupBackground(parent, size)
    obj:SetLabel(label)

    local combo = obj:CreateElement("Combo", "GenericUI_Element_ComboBox", obj:GetRootElement())
    for _,option in ipairs(opts) do
        combo:AddOption(option.ID, option.Label)
    end
    obj.ComboBox = combo

    obj:SetSize(size:unpack())

    -- Forward events
    combo.Events.OptionSelected:Subscribe(function (ev)
        obj.Events.OptionSelected:Throw(ev)
    end)

    return obj
end

---@param width number
---@param height number
function Dropdown:SetSize(width, height)
    local labelElement = self.Label
    local combo = self.ComboBox

    self:SetBackgroundSize(Vector.Create(width, height))

    labelElement:SetSize(width, 30)
    labelElement:SetPositionRelativeToParent("Left", self.LABEL_SIDE_MARGIN, 0)

    combo:SetPositionRelativeToParent("Right")
end

---@param id string
function Dropdown:SelectOption(id)
    self.ComboBox:SelectOption(id)
end

---@override
function Dropdown:GetInteractableElement()
    return self.ComboBox
end
