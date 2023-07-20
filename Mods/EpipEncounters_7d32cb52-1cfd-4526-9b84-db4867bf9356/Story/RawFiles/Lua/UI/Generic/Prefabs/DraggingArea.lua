
---------------------------------------------
-- Prefab for an invisible element that allows dragging the UIObject.
---------------------------------------------

local Generic = Client.UI.Generic

---Prefab for a button that hides the UI.
---@class GenericUI_Prefab_DraggingArea : GenericUI_Prefab
---@field Background GenericUI_Element_TiledBackground
local DraggingArea = {}
Generic.RegisterPrefab("GenericUI_Prefab_DraggingArea", DraggingArea)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_DraggingArea"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_Element|string
---@param size Vector2
---@param alpha integer? Defaults to `0`.
---@return GenericUI_Prefab_DraggingArea
function DraggingArea.Create(ui, id, parent, size, alpha)
    local instance = DraggingArea:_Create(ui, id) ---@type GenericUI_Prefab_DraggingArea
    alpha = alpha or 0

    local background = instance:CreateElement(id, "GenericUI_Element_TiledBackground", parent)
    background:SetBackground("Black", size:unpack())
    background:SetAlpha(alpha)
    background:SetAsDraggableArea()

    instance.Background = background

    return instance
end