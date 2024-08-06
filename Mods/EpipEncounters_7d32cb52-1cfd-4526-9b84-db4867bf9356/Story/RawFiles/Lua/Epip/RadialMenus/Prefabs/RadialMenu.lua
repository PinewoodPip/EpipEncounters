
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
local Menu = {
    ELEMENT_RADIUS = 280, -- Element radius; segment radius is twice of this.
    SEGMENT_RADIUS = 400,
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
                self:_UpdateSegment(i, "Highlighted")
            end)
            selectionArea.Events.MouseOut:Subscribe(function (_)
                self:_UpdateSegment(i, "Idle")
            end)
            selectionArea.Events.MouseDown:Subscribe(function (_)
                self:_UpdateSegment(i, "Pressed")
            end)
            selectionArea.Events.MouseUp:Subscribe(function (_)
                self:_UpdateSegment(i, "Highlighted")
                self.Events.SegmentClicked:Throw({
                    Index = i,
                })
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

---Redraws a segment.
---@param index integer
---@param state Features.RadialMenus.Prefabs.RadialMenu.SegmentState
function Menu:_UpdateSegment(index, state)
    local segment = self.SegmentsList:GetChildren()[index]:GetMovieClip()
    local slots = self._Config.Menu:GetSlots()
    local slot = slots[index]
    local graphics = segment.graphics
    local topVector = V(0, -self.SEGMENT_RADIUS / 2)
    local rotation = -(2 * math.pi) / #slots
    local leftVector = Vector.Rotate(topVector, math.deg(rotation))
    local color = Menu.SEGMENT_STATE_COLORS[state]
    -- Empty slots are non-interactable; do not change graphics for them.
    if slot.Type == "Empty" then
        state = "Idle"
    end
    graphics.clear()
    graphics.lineStyle(2, 0, 1, true, "normal", "none", "round", 2)
    graphics.beginFill(color:ToDecimal(), color.Alpha / 256)
    graphics.moveTo(0, self.SEGMENT_RADIUS / 2) -- Go to center
    graphics.lineTo(leftVector[1], leftVector[2])
    graphics.curveTo(topVector[1], topVector[2] - 1, -leftVector[1], leftVector[2])
    graphics.lineTo(0, self.SEGMENT_RADIUS / 2)
    graphics.endFill()
end

---@override
function Menu:GetRootElement()
    return self.Root
end
