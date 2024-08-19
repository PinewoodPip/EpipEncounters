
local Generic = Client.UI.Generic
local RadialList = Generic.GetPrefab("GenericUI.Prefabs.Containers.RadialList")
local V = Vector.Create

local RadialMenus = Epip.GetFeature("Features.RadialMenus")
local SlotPrefab = RadialMenus:GetClass("Features.RadialMenus.Prefabs.Slot")

---@class Features.RadialMenus.Prefabs.RadialMenu : GenericUI_Prefab, GenericUI_I_Elementable
---@field Root GenericUI_Element_Empty
---@field SegmentsList GenericUI.Prefabs.Containers.RadialList
---@field RadialList GenericUI.Prefabs.Containers.RadialList
---@field _Config Features.RadialMenus.Prefabs.RadialMenu.Config
---@field _SelectedSegmentIndex integer?
local Menu = {
    ELEMENT_RADIUS = 280,
    SEGMENT_RADIUS = 400,
    SEGMENT_HOVER_SOUND = "UI_Game_Reward_MoveCursor",
    ---@type table<Features.RadialMenus.Prefabs.RadialMenu.SegmentState, Color>
    SEGMENT_STATE_COLORS = {
        ["Idle"] = Color.Create(255, 255, 255, 255 * 0.2),
        ["Highlighted"] = Color.Create(255, 255, 255, 255 * 0.5),
        ["Pressed"] = Color.Create(255, 255, 255, 255 * 0.6),
    },
    Events = {
        SegmentClicked = {}, ---@type Event<{Index:integer}>
        SegmentRightClicked = {}, ---@type Event<{Index:integer}>
    },
}
RadialMenus:RegisterClass("Features.RadialMenus.Prefabs.RadialMenu", Menu, {"GenericUI_Prefab", "GenericUI_I_Elementable"})
Generic.RegisterPrefab("Features.RadialMenus.Prefabs.RadialMenu", Menu)

---@class Features.RadialMenus.Prefabs.RadialMenu.Config
---@field Menu Features.RadialMenus.Menu

---@alias Features.RadialMenus.Prefabs.RadialMenu.SegmentState "Idle"|"Highlighted"|"Pressed"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param ui GenericUI_Instance
---@param id string
---@param parent GenericUI_ParentIdentifier
---@param config Features.RadialMenus.Prefabs.RadialMenu.Config
---@return Features.RadialMenus.Prefabs.RadialMenu
function Menu.Create(ui, id, parent, config)
    local instance = Menu:_Create(ui, id) ---@cast instance Features.RadialMenus.Prefabs.RadialMenu
    instance._Config = config

    local root = instance:CreateElement("Root", "GenericUI_Element_Empty", parent)
    instance.Root = root

    -- Create content list first, so it goes behind the segments
    -- and does not block mouse input.
    local menu = RadialList.Create(ui, instance:PrefixID("RadialList"), root, {Radius = Menu.ELEMENT_RADIUS, RotateElements = false})
    instance.RadialList = menu

    -- Create segment elements; these are the ones the user interacts with.
    local segments = RadialList.Create(ui, instance:PrefixID("SegmentsList"), root, {Radius = Menu.SEGMENT_RADIUS / 2, RotateElements = true, CenterElements = false})
    instance.SegmentsList = segments

    instance:_Render()

    return instance
end

---Selects a segment, as if it had been hovered over.
---@param index integer
function Menu:SelectSegment(index)
    if index == self._SelectedSegmentIndex then return end
    self:DeselectSegment()
    local slots = self:GetMenu():GetSlots()
    if slots[index].Type ~= "Empty" then -- Empty slots are non-interactable.
        self.UI:PlaySound(self.SEGMENT_HOVER_SOUND)
        self:_UpdateSegment(index, "Highlighted")
        self._SelectedSegmentIndex = index
    end
end

---Deselects the current segment, as if it had been hovered out of.
function Menu:DeselectSegment()
    local index = self._SelectedSegmentIndex
    if not index then return end
    self:_UpdateSegment(index, "Idle")
    self._SelectedSegmentIndex = nil
end

---Interacts with a segment.
---@param index integer
function Menu:ActivateSegment(index)
    self.Events.SegmentClicked:Throw({
        Index = index,
    })
end

---Returns the currently-selected slot, if any.
---@return Features.RadialMenus.Slot?, integer? -- Slot, index.
function Menu:GetSelectedSlot()
    local index = self._SelectedSegmentIndex
    return (index and self:GetMenu():GetSlots()[index] or nil), index
end

---Re-renders the menu's slots.
function Menu:_Render()
    local slots = self._Config.Menu:GetSlots()

    -- Render segments
    local segmentList = self.SegmentsList
    segmentList:Clear()
    for i,slot in ipairs(slots) do
        local selectionArea = self:CreateElement("Segment" .. tostring(i), "GenericUI_Element_Empty", segmentList:GetRootElement())

        -- Render the segment's default state immediately.
        self:_UpdateSegment(i, "Idle")

        -- Update segment graphics upon mouse interaction and forward events.
        if slot.Type ~= "Empty" then -- Empty slots are non-interactable.
            selectionArea.Events.MouseOver:Subscribe(function (_)
                self:SelectSegment(i)
            end)
            selectionArea.Events.MouseOut:Subscribe(function (_)
                self:DeselectSegment()
            end)
            selectionArea.Events.MouseDown:Subscribe(function (_)
                self:_UpdateSegment(i, "Pressed")
            end)
            selectionArea.Events.MouseUp:Subscribe(function (_)
                self:_UpdateSegment(i, "Highlighted")
                self:ActivateSegment(i)
            end)
        end

        -- Handle right-clicks for editing slots, even for empty slots
        if self._Config.Menu:GetClassName() == "Features.RadialMenus.Menu.Custom" then
            selectionArea.Events.RightClick:Subscribe(function (_)
                self:_UpdateSegment(i, "Pressed")
                self.Events.SegmentRightClicked:Throw({
                    Index = i,
                })
            end)
        end
    end
    segmentList:PositionElements()

    -- Render slots
    local container = self:GetContainer()
    container:Clear()
    for i,slot in ipairs(slots) do
        local _ = SlotPrefab.Create(self.UI, self:PrefixID("Slot" .. tostring(i)), container:GetRootElement(), slot)
    end
    container:PositionElements()
end

---Sets the menu to display and re-renders the prefab.
---@param menu Features.RadialMenus.Menu
function Menu:SetMenu(menu)
    self:DeselectSegment() -- Necessary when shrinking the wheel, as the user might've been hovering over a segment that will no longer exist after the re-render.
    self._Config.Menu = menu
    self:_Render()
end

---Returns the instance's current radial menu.
---@return Features.RadialMenus.Menu
function Menu:GetMenu()
    return self._Config.Menu
end

---Returns the container that children should be added to.
---@return GenericUI.Prefabs.Containers.RadialList
function Menu:GetContainer()
    return self.RadialList
end

---Returns the segment radius with the horizontal element scale override considered.
---@return number
function Menu:GetScaledRadius()
    return self.SEGMENT_RADIUS * self:GetScale()[1]
end

---Redraws a segment.
---@param index integer
---@param state Features.RadialMenus.Prefabs.RadialMenu.SegmentState
function Menu:_UpdateSegment(index, state)
    local segment = self.SegmentsList:GetChildren()[index]:GetMovieClip()
    local slots = self._Config.Menu:GetSlots()
    local slotsAmount = #slots
    local slot = slots[index]
    local graphics = segment.graphics
    local topVector = V(0, -self.SEGMENT_RADIUS)
    local rotation = -(2 * math.pi) / slotsAmount
    local leftVector = Vector.Rotate(topVector, math.deg(rotation) / 2) -- We're rotating from the middle to one of the sides, thus we divide the angle by 2.
    local color = Menu.SEGMENT_STATE_COLORS[state]
    -- Empty slots are non-interactable; do not change graphics for them.
    if slot.Type == "Empty" then
        state = "Idle"
    end

    -- Though the segment has its root in its middle,
    -- for easier maths we treat the center of the menu as the origin.
    local offset = V(0, self.SEGMENT_RADIUS / 2)
    local origin = V(0, 0)

    -- Magic numbers galore!
    -- The fewer slots there are, the further out the anchor point
    -- has to be for the menu to appear nicely round.
    -- We do not use drawCircle as there'd be no way to highlight specific segments with it.
    local curveAnchorOffset = 0.9 ^ slotsAmount * 50
    if slotsAmount == 4 then
        curveAnchorOffset = curveAnchorOffset + 90
    elseif slotsAmount == 5 then
        curveAnchorOffset = curveAnchorOffset + 50
    elseif slotsAmount == 6 then
        curveAnchorOffset = curveAnchorOffset + 30
    elseif slotsAmount == 7 then
        curveAnchorOffset = curveAnchorOffset + 20
    end

    -- Draw the segment
    graphics.clear()
    graphics.lineStyle(2, 0, 1, true, "normal", "none", "round", 2)
    graphics.beginFill(color:ToDecimal(), color.Alpha / 256)
    graphics.moveTo((origin + offset):unpack()) -- Go to center
    graphics.lineTo((leftVector + offset):unpack())
    graphics.curveTo(topVector[1] + offset[1], topVector[2] + offset[2] - curveAnchorOffset, -leftVector[1] + offset[1], leftVector[2] + offset[2])
    graphics.lineTo((origin + offset):unpack())
    graphics.endFill()
end

---@override
function Menu:GetRootElement()
    return self.Root
end
