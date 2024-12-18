
---------------------------------------------
-- A container with a header that uses the tooltip background.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI_Prefab_TooltipPanel : GenericUI_Prefab, GenericUI_I_Elementable
---@field Background GenericUI_Element_TiledBackground
---@field HeaderText GenericUI_Element_Text
local TooltipPanelPrefab = {}
Generic:RegisterClass("GenericUI_Prefab_TooltipPanel", TooltipPanelPrefab, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("GenericUI_Prefab_TooltipPanel", TooltipPanelPrefab)

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias GenericUI_PrefabClass "GenericUI_Prefab_TooltipPanel"

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a tooltip panel.
---@param ui GenericUI_Instance
---@param id string
---@param size Vector2
---@param parent (GenericUI_Element|string)?
---@param header string
---@param headerSize Vector2
---@return GenericUI_Prefab_TooltipPanel
function TooltipPanelPrefab.Create(ui, id, parent, size, header, headerSize)
    local panel = TooltipPanelPrefab:_Create(ui, id) ---@cast panel GenericUI_Prefab_TooltipPanel

    local bg = panel:CreateElement("Background", "GenericUI_Element_TiledBackground", parent)
    bg:SetBackground("FormattedTooltip", size:unpack())
    panel.Background = bg

    local headerText = TextPrefab.Create(ui, "Header", bg, header, "Center", headerSize)
    headerText:SetPositionRelativeToParent("Top", 0, 45 - headerSize[2]/2)
    headerText:SetStroke(Color.Create(0, 0, 0):ToDecimal(), 2, 1, 15, 15)
    panel.HeaderText = headerText

    return panel
end

---@generic T
---@param id string
---@param elementType `T`|GenericUI_ElementType
---@return `T`
function TooltipPanelPrefab:AddChild(id, elementType)
    return self.Background:AddChild(id, elementType)
end

---Destroys the elements of the prefab.
function TooltipPanelPrefab:Destroy()
    self.UI:DestroyElement(self.Background)

    self.Background, self.HeaderText = nil, nil
end

---@override
function TooltipPanelPrefab:GetRootElement()
    return self.Background
end
