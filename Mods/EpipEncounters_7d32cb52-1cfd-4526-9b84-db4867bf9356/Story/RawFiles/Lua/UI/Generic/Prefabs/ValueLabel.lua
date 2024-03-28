
---------------------------------------------
-- A prefab consisting of two labels positioned at the opposite edges of the container.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI.Prefabs.ValueLabel : GenericUI_Prefab, GenericUI_I_Elementable
---@field Root GenericUI_Element_Empty
---@field Label GenericUI_Prefab_Text
---@field ValueLabel GenericUI_Prefab_Text
local ValueLabel = {}
Generic:RegisterClass("GenericUI.Prefabs.ValueLabel", ValueLabel, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI.Prefabs.ValueLabel", ValueLabel)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI.Prefabs.ValueLabel"

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a ValueLabel.
---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier?
---@param size Vector2
---@param label string
---@param valueLabel string
---@return GenericUI.Prefabs.ValueLabel
function ValueLabel.Create(ui, id, parent, size, label, valueLabel)
    local instance = ValueLabel:_Create(ui, id) ---@cast instance GenericUI.Prefabs.ValueLabel
    local root = instance:CreateElement("Root", "GenericUI_Element_Empty", parent)
    instance.Root = root

    local labelElement = TextPrefab.Create(ui, instance:PrefixID("Label"), root, label, "Left", size)
    instance.Label = labelElement

    local valueLabelElement = TextPrefab.Create(ui, instance:PrefixID("ValueLabel"), root, valueLabel, "Right", size)
    instance.ValueLabel = valueLabelElement

    return instance
end

---@override
function ValueLabel:GetRootElement()
    return self.Root
end
