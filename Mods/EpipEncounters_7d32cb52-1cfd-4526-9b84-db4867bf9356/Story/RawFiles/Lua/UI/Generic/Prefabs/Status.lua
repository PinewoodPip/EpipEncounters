
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")

---@class GenericUI_Prefab_Status : GenericUI_Prefab
---@field EntityHandle EntityHandle
---@field StatusHandle EntityHandle
---@field Background GenericUI_Element_TiledBackground
---@field Icon GenericUI_Element_IggyIcon
---@field DurationText GenericUI_Prefab_Text
---@field BorderDummy GenericUI_Element_Empty
local Status = {
    SIZE = Vector.Create(32, 32),
    ICON_SIZE = Vector.Create(28, 28),
    TEXT_SIZE = Vector.Create(32, 16),
    TEXT_FONT_SIZE = 13,
    DURATION_BORDER_WIDTH = 1,
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
    element.BorderDummy = element:CreateElement("Border", "GenericUI_Element_Empty", root)
    
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

local function DrawWedge(element, graphics, relativeDurationLeft, relativeWedgeLength, wedgeMaxLength, position)
        graphics.beginFill(Color.Create(255, 255, 255):ToDecimal(), 1)
    local wedgeLength = math.clamp(relativeDurationLeft / relativeWedgeLength, 0, 1) * wedgeMaxLength
    wedgeLength = Ext.Round(wedgeLength)

    graphics.beginFill(Color.Create(255, 255, 255):ToDecimal(), 1)
    if position == "TopLeft" then
        graphics.drawRect(element.SIZE[1]/2 - wedgeLength, 0, wedgeLength, element.DURATION_BORDER_WIDTH)
    elseif position == "Left" then
        graphics.drawRect(0, 0, element.DURATION_BORDER_WIDTH, wedgeLength)
    elseif position == "Bottom" then
        graphics.drawRect(0, element.SIZE[2] - element.DURATION_BORDER_WIDTH, wedgeLength, element.DURATION_BORDER_WIDTH)
    elseif position == "Right" then
        graphics.drawRect(element.SIZE[1] - element.DURATION_BORDER_WIDTH, element.SIZE[2] - wedgeLength, element.DURATION_BORDER_WIDTH, wedgeLength)
    elseif position == "TopRight" then
        graphics.drawRect(element.SIZE[1] - wedgeLength, 0, wedgeLength, element.DURATION_BORDER_WIDTH)
    else
        error("Unknown position " .. position)
    end
    graphics.endFill()

    return relativeDurationLeft - relativeWedgeLength
end

---@param entity EclCharacter|EclItem
---@param status EclStatus
function Status:SetStatus(entity, status)
    local icon = self.Icon
    local durationTurns = status.CurrentLifeTime // 6

    self.EntityHandle = entity.Handle
    self.StatusHandle = status.StatusHandle

    icon:SetIcon(Stats.GetStatusIcon(status), self.ICON_SIZE:unpack())
    icon:SetPositionRelativeToParent("Center")

    self.DurationText:SetText(status.CurrentLifeTime > 0 and Text.Format("%s", {
        FormatArgs = {durationTurns},
        Size = self.TEXT_FONT_SIZE,
        Color = Color.WHITE,
    }) or "")
    self.DurationText:SetStroke(Color.Create(0, 0, 0), 1, 1, 15, 1)
    self.DurationText:SetPositionRelativeToParent("BottomRight")

    -- Draw duration border
    local TOP_WEDGE_LENGTH = 1/8
    local SIDE_WEDGE_LENGTH = 1/4
    if status.LifeTime > 0 then
        local graphics = self.BorderDummy:GetMovieClip().graphics
        local relativeDurationLeft = status.CurrentLifeTime / status.LifeTime
        graphics.clear()
        
        if relativeDurationLeft >= 0 then
            relativeDurationLeft = DrawWedge(self, graphics, relativeDurationLeft, TOP_WEDGE_LENGTH, self.SIZE[1]/2, "TopLeft")
        end
        if relativeDurationLeft >= 0 then
            relativeDurationLeft = DrawWedge(self, graphics, relativeDurationLeft, SIDE_WEDGE_LENGTH, self.SIZE[2], "Left")
        end
        if relativeDurationLeft >= 0 then
            relativeDurationLeft = DrawWedge(self, graphics, relativeDurationLeft, SIDE_WEDGE_LENGTH, self.SIZE[1], "Bottom")
        end
        if relativeDurationLeft >= 0 then
            relativeDurationLeft = DrawWedge(self, graphics, relativeDurationLeft, SIDE_WEDGE_LENGTH, self.SIZE[2], "Right")
        end
        if relativeDurationLeft >= 0 then
            relativeDurationLeft = DrawWedge(self, graphics, relativeDurationLeft, TOP_WEDGE_LENGTH, self.SIZE[1]/2, "TopRight")
        end
    end
end