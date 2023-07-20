
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI_Prefab_FormHorizontalList : GenericUI_Prefab
local Form = {
    List = nil, ---@type GenericUI_Element_HorizontalList
    BG = nil, ---@type GenericUI_Element_TiledBackground
    Label = nil, ---@type GenericUI_Prefab_Text

    SELECTED_BG_ALPHA = 0.2,

    Events = {

    },
}
Generic.RegisterPrefab("GenericUI_Prefab_FormHorizontalList", Form)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_FormHorizontalList"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param label string
---@param size Vector2
---@param labelSize Vector2
---@return GenericUI_Prefab_FormHorizontalList
function Form.Create(ui, id, parent, label, size, labelSize)
    local obj = Form:_Create(ui, id, parent, label, size, labelSize) ---@type GenericUI_Prefab_FormHorizontalList

    return obj
end

function Form:_Setup(parent, label, size, labelSize)
    local bg = self.UI:CreateElement(self.ID, "GenericUI_Element_TiledBackground", parent)
    bg:SetBackground("Black", size:unpack())
    bg:SetAlpha(0)

    local list = bg:AddChild(self:PrefixID("List"), "GenericUI_Element_HorizontalList")
    list:SetElementSpacing(0)

    if label then
        local labelElement = TextPrefab.Create(self.UI, self:PrefixID("Label"), list, label, "Left", labelSize)

        self.Label = labelElement
    end

    -- Setup highlight upon hovering
    bg.Events.MouseOver:Subscribe(function (_)
        bg:SetAlpha(self.SELECTED_BG_ALPHA)
    end)
    bg.Events.MouseOut:Subscribe(function (_)
        bg:SetAlpha(0)
    end)

    self.BG = bg
    self.List = list
end

---@generic T
---@param id string
---@param type `T`|GenericUI_ElementType
---@return `T`
function Form:AddChild(id, type)
    local list = self.List

    return list:AddChild(self:PrefixID(id), type)
end