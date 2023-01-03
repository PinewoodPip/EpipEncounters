
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI_Prefab_Status : GenericUI_Prefab
---@field EntityHandle EntityHandle
---@field StatusHandle EntityHandle
---@field Background GenericUI_Element_TiledBackground
---@field Icon GenericUI_Element_IggyIcon
---@field DurationText GenericUI_Prefab_Text
local Status = {
    SIZE = Vector.Create(32, 32),
    TEXT_SIZE = Vector.Create(32, 16),
}
Generic.RegisterPrefab("GenericUI_Prefab_Status", Status)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent (GenericUI_Element|string)?
---@param entity EclCharacter|EclItem
---@param status EclStatus
---@return GenericUI_Prefab_Status
function Status.Create(ui, id, parent, entity, status)
    local element = Status:_Create(ui, id) ---@type GenericUI_Prefab_Status

    local root = element:CreateElement("Container", "GenericUI_Element_TiledBackground", parent)
    root:SetBackground("Black", element.SIZE:unpack())
    
    local icon = element:CreateElement("Icon", "GenericUI_Element_IggyIcon", root)
    local text = TextPrefab.Create(ui, element:PrefixID("DurationText"), root, "", "Right", element.TEXT_SIZE)

    element.Background = root
    element.Icon = icon
    element.DurationText = text

    element:SetStatus(entity, status)

    -- Show tooltip
    root.Events.MouseOver:Subscribe(function (_)
        local char = Character.Get(element.EntityHandle) -- TODO support items
        local statusObj = Character.GetStatusByHandle(char, element.StatusHandle)
        
        Client.Tooltip.ShowStatusTooltip(char, statusObj)
    end)
    root.Events.MouseOut:Subscribe(function (_)
        Client.Tooltip.HideTooltip()
    end)

    return element
end

---@param entity EclCharacter|EclItem
---@param status EclStatus
function Status:SetStatus(entity, status)
    local icon = self.Icon
    local durationTurns = status.CurrentLifeTime // 6

    self.EntityHandle = entity.Handle
    self.StatusHandle = status.StatusHandle

    icon:SetIcon(Stats.GetStatusIcon(status), self.SIZE:unpack())
    self.DurationText:SetText(Text.Format("%s", {
        FormatArgs = {durationTurns},
        Size = 11,
        Color = Color.WHITE,
    }))
    self.DurationText:SetStroke(Color.Create(0, 0, 0), 1, 1, 15, 1)
    self.DurationText:SetPositionRelativeToParent("BottomRight")
end