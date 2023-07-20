
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---Base class for prefabs styled as a form element.
---@class GenericUI_Prefab_FormElement : GenericUI_Prefab
---@field Background GenericUI_Element_TiledBackground
---@field Label GenericUI_Prefab_Text
local Prefab = {
    DEFAULT_SIZE = Vector.Create(600, 50),
}
Generic.RegisterPrefab("GenericUI_Prefab_FormElement", Prefab)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_FormElement"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param size Vector2
---@return GenericUI_Prefab_FormElement
function Prefab.Create(ui, id, parent, size)
    local instance = Prefab:_Create(ui, id) ---@cast instance GenericUI_Prefab_FormElement

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
    text:SetWordWrap(false)

    self.Background = bg
    self.Label = text

    Prefab.SetBackgroundSize(self, size) -- Ignore overrides
    text:SetPositionRelativeToParent("Left")
end

---@return GenericUI_Element_TiledBackground
function Prefab:GetRootElement()
    return self.Background
end

---Sets the size of the background.
---@param size Vector2
function Prefab:SetBackgroundSize(size)
    local root = self:GetRootElement()

    root:SetBackground("Black", size:unpack())
    root:SetAlpha(0.2)
end

---Returns the label of the element.
---@return string
function Prefab:GetLabel()
    return self.Label:GetMovieClip().text_txt.htmlText
end

---Sets the label.
---@param label string
function Prefab:SetLabel(label)
    self.Label:SetText(label)
end

---Sets whether the element should be centered in lists.
---@param center boolean
function Prefab:SetCenterInLists(center)
    self:GetRootElement():SetCenterInLists(center)
end

---Sets the tooltip of the element.
---@param type TooltipLib_TooltipType
---@param tooltip any TODO document
function Prefab:SetTooltip(type, tooltip)
    self:GetRootElement():SetTooltip(type, tooltip)
end