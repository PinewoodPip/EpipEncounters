
local Generic = Client.UI.Generic

---@class GenericUI_Prefab_FormElementBackground : GenericUI_Prefab
---@field Background GenericUI_Element_TiledBackground
---@field HorizontalList GenericUI_Element_HorizontalList
local BG = {}
Generic.RegisterPrefab("GenericUI_Prefab_FormElementBackground", BG)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_FormElementBackground"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param size Vector2
---@return GenericUI_Prefab_FormElementBackground
function BG.Create(ui, id, parent, size)
    local instance = BG:_Create(ui, id) ---@type GenericUI_Prefab_FormElementBackground

    local bg = instance:CreateElement("BG", "GenericUI_Element_TiledBackground", parent)
    bg:SetBackground("Black", size:unpack())
    bg:SetAlpha(0.2)

    local list = instance:CreateElement("HorizontalList", "GenericUI_Element_HorizontalList", bg)
    list:SetElementSpacing(0)

    instance.Background = bg
    instance.HorizontalList = list

    return instance
end