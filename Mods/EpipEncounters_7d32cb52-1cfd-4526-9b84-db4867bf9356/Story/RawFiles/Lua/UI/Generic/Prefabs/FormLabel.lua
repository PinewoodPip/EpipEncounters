
---------------------------------------------
-- Form prefab for a readonly, right-aligned value label field.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI.Prefabs.FormLabel : GenericUI_Prefab_FormElement, GenericUI_I_Elementable
---@field ValueLabel GenericUI_Prefab_Text
local FormLabel = {
    FIELD_SIZE = Vector.Create(250, 50),
    FIELD_ALPHA = {
        FOCUSED = 0.9,
        UNFOCUSED = 0.5,
    },
}
Generic:RegisterClass("GenericUI.Prefabs.FormLabel", FormLabel, {"GenericUI_Prefab_FormElement", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI.Prefabs.FormLabel", FormLabel)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.FormLabel"

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a new FormLabel.
---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier?
---@param label string
---@param size Vector2? Defaults to `DEFAULT_SIZE`
---@param valueLabel string?
---@return GenericUI.Prefabs.FormLabel
function FormLabel.Create(ui, id, parent, label, size, valueLabel)
    size = size or FormLabel.DEFAULT_SIZE
    local instance = FormLabel:_Create(ui, id) ---@type GenericUI.Prefabs.FormLabel
    instance:__SetupBackground(parent, size)
    instance:SetLabel(label)

    local valueText = TextPrefab.Create(ui, instance:PrefixID("ValueLabel"), instance.Background, "", "Right",  Vector.Create(size[1], 30))
    valueText:SetPositionRelativeToParent("Right", -instance.LABEL_SIDE_MARGIN)
    instance.ValueLabel = valueText
    instance:SetValue(valueLabel or "")

    return instance
end

---Sets the value label displayed.
---@param value string
function FormLabel:SetValue(value)
    self.ValueLabel:SetText(value)
    self.ValueLabel:SetPositionRelativeToParent("Right")
end
