
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---Base class for prefabs styled as a form element.
---@class GenericUI_Prefab_FormElement : GenericUI_Prefab
---@field Background GenericUI_Element_TiledBackground
---@field Label GenericUI_Prefab_Text
local Prefab = {}
Generic.RegisterPrefab("GenericUI_Prefab_FormElement", Prefab)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param size Vector2
---@return GenericUI_Prefab_FormElement
function Prefab.Create(ui, id, parent, size)
    local instance = Prefab:_Create(ui, id) ---@type GenericUI_Prefab_FormElement

    instance:__SetupBackground(parent, size)

    return instance
end

---Creates the background and label elements.
---@protected
---@param parent (GenericUI_Element|string)?
---@param size Vector2
function Prefab:__SetupBackground(parent, size)
    local bg = self:CreateElement("Background", "GenericUI_Element_TiledBackground", parent)
    local text = TextPrefab.Create(self.UI, self:PrefixID("Label"), bg, "", "Left", Vector.Create(size[1], 30))

    self.Background = bg
    self.Label = text

    self:SetBackgroundSize(size)
    text:SetPositionRelativeToParent("Left")
end

---Sets the size of the background.
---@param size Vector2
function Prefab:SetBackgroundSize(size)
    self.Background:SetBackground("Black", size:unpack())
    self.Background:SetAlpha(0.2)
end

---Sets the label.
---@param label string
function Prefab:SetLabel(label)
    self.Label:SetText(label)
end