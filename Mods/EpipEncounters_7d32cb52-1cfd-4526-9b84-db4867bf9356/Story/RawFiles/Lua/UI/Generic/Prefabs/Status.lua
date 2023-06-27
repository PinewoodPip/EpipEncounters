
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
    SIZE = Vector.Create(40, 40),
    ICON_SIZE = Vector.Create(28, 28),
    TEXT_SIZE = Vector.Create(18, 18),
    TEXT_FONT_SIZE = 12,
    DURATION_BORDER_WIDTH = 2,
    DURATION_BORDER_COLOR = Color.Create(240, 211, 185),
    DURATION_BORDER_INFINITE_COLOR = Color.Create(105, 105, 105),
    BACKGROUND_TEXTURE = "c8631624-a85d-42c4-8e22-08a44feada6d", -- pip_ui_icon_status_background
    BACKGROUND_HIGHLIGHT_SIZE = Vector.Create(27, 27),

    Events = {
        RightClicked = {}, ---@type Event<GenericUI_Element_Event_RightClick>
    },
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

    local backgroundHighlight = element:CreateElement("BackgroundHighlight", "GenericUI_Element_Texture", root)
    backgroundHighlight:SetTexture(element.BACKGROUND_TEXTURE, element.BACKGROUND_HIGHLIGHT_SIZE)
    backgroundHighlight:SetPositionRelativeToParent("Center")

    element.BorderDummy = element:CreateElement("Border", "GenericUI_Element_Empty", root)

    -- Add border size to element size
    root:SetSizeOverride(Vector.Create(
        element.SIZE[1] + element.DURATION_BORDER_WIDTH,
        element.SIZE[2] + element.DURATION_BORDER_WIDTH
    ))
    
    local icon = element:CreateElement("Icon", "GenericUI_Element_IggyIcon", backgroundHighlight)
    local text = TextPrefab.Create(ui, element:PrefixID("DurationText"), backgroundHighlight, "", "Right", element.TEXT_SIZE)

    element.Background = root
    element.Icon = icon
    element.DurationText = text

    element:SetStatus(entity, status)

    -- Show tooltip
    root.Events.MouseOver:Subscribe(function (_)
        local char = Character.Get(element.EntityHandle) -- TODO support items
        local statusObj = Character.GetStatusByHandle(char, element.StatusHandle)

        if statusObj then
            Client.Tooltip.ShowStatusTooltip(char, statusObj)
        end
    end)
    root.Events.MouseOut:Subscribe(function (_)
        Client.Tooltip.HideTooltip()
    end)

    -- Forward right-click event
    root.Events.RightClick:Subscribe(function (ev)
        element.Events.RightClicked:Throw(ev)
    end)

    return element
end

local function DrawWedge(element, graphics, relativeDurationLeft, relativeWedgeLength, wedgeMaxLength, color, position)
    local wedgeLength = math.clamp(relativeDurationLeft / relativeWedgeLength, 0, 1) * wedgeMaxLength
    wedgeLength = Ext.Round(wedgeLength)

    -- TODO yeet all these magic numbers
    graphics.beginFill(color:ToDecimal(), 1)
    if position == "TopLeft" then
        graphics.drawRect(element.SIZE[1]/2 - wedgeLength, 0, wedgeLength, element.DURATION_BORDER_WIDTH)
    elseif position == "Left" then
        graphics.drawRect(0, 0, element.DURATION_BORDER_WIDTH, wedgeLength - 3)
    elseif position == "Bottom" then
        graphics.drawRect(0, element.SIZE[2] - element.DURATION_BORDER_WIDTH - 3, wedgeLength - 3, element.DURATION_BORDER_WIDTH)
    elseif position == "Right" then
        graphics.drawRect(element.SIZE[1] - element.DURATION_BORDER_WIDTH - 2, element.SIZE[2] - wedgeLength, element.DURATION_BORDER_WIDTH, wedgeLength - 3)
    elseif position == "TopRight" then
        graphics.drawRect(element.SIZE[1] - wedgeLength, 0, wedgeLength - 3, element.DURATION_BORDER_WIDTH)
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
    if status.CurrentLifeTime % 6 > 0 then -- Round turns up.
        durationTurns = durationTurns + 1
    end

    self.EntityHandle = entity.Handle
    self.StatusHandle = status.StatusHandle

    icon:SetIcon(Stats.GetStatusIcon(status), self.ICON_SIZE:unpack())
    icon:SetPositionRelativeToParent("Center", -self.DURATION_BORDER_WIDTH/2, -self.DURATION_BORDER_WIDTH/2)

    self.DurationText:SetText(status.CurrentLifeTime > 0 and Text.Format("%s", {
        FormatArgs = {durationTurns},
        Size = self.TEXT_FONT_SIZE,
        Color = Color.WHITE,
    }) or "")
    self.DurationText:SetStroke(Color.Create(0, 0, 0), 1, 1, 15, 1)
    self.DurationText:SetPositionRelativeToParent("BottomRight", 3, 3)

    -- Draw duration border
    local TOP_WEDGE_LENGTH = 1/8
    local SIDE_WEDGE_LENGTH = 1/4
    local color = status.LifeTime > 0 and self.DURATION_BORDER_COLOR or self.DURATION_BORDER_INFINITE_COLOR
    
    local graphics = self.BorderDummy:GetMovieClip().graphics
    local relativeDurationLeft = status.CurrentLifeTime / status.LifeTime
    graphics.clear()
    if status.LifeTime < 0 then -- Draw the whole rect for infinite statuses
        relativeDurationLeft = 1
    end
    
    if relativeDurationLeft >= 0 then
        relativeDurationLeft = DrawWedge(self, graphics, relativeDurationLeft, TOP_WEDGE_LENGTH, self.SIZE[1]/2, color, "TopLeft")
    end
    if relativeDurationLeft >= 0 then
        relativeDurationLeft = DrawWedge(self, graphics, relativeDurationLeft, SIDE_WEDGE_LENGTH, self.SIZE[2], color, "Left")
    end
    if relativeDurationLeft >= 0 then
        relativeDurationLeft = DrawWedge(self, graphics, relativeDurationLeft, SIDE_WEDGE_LENGTH, self.SIZE[1], color, "Bottom")
    end
    if relativeDurationLeft >= 0 then
        relativeDurationLeft = DrawWedge(self, graphics, relativeDurationLeft, SIDE_WEDGE_LENGTH, self.SIZE[2], color, "Right")
    end
    if relativeDurationLeft >= 0 then
        relativeDurationLeft = DrawWedge(self, graphics, relativeDurationLeft, TOP_WEDGE_LENGTH, self.SIZE[1]/2, color, "TopRight")
    end
end

---@param visible boolean
function Status:SetVisible(visible)
    self.Background:SetVisible(visible)
end