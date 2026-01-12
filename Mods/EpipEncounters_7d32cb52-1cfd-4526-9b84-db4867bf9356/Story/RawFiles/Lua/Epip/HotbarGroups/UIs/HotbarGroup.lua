
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local Hotbar = Client.UI.Hotbar
local V = Vector.Create

local GroupManager = Epip.GetFeature("Features.HotbarGroups") ---@cast GroupManager Features.HotbarGroups.Client
local TSK = GroupManager.TranslatedStrings

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.HotbarGroups.UI.Group : GenericUI_Instance
---@field GUID GUID
---@field _Slots table<GenericUI_Prefab_HotbarSlot>
---@field _SlotsAllocated integer
---@field _LockPosition boolean
---@field _SnapToHotbar boolean
---@field package _Rows integer
---@field package _Columns integer
---@field package _Content  GenericUI_Element_TiledBackground
---@field package _Container GenericUI_Element_Grid
---@field _DragArea GenericUI_Element_Divider
local HotbarGroup = {
    SLOT_SIZE = 58,
    SLOT_SPACING = 0,
}
GroupManager:RegisterClass("Features.HotbarGroups.UI.Group", HotbarGroup, {"GenericUI_Instance"})

---@return GenericUI_Prefab_HotbarSlot
function HotbarGroup:_AddSlot()
    local slot = HotbarSlot.Create(self, self.GUID .. "_Slot_" .. self._SlotsAllocated, self._Container, {CooldownAnimations = true, ActiveAnimation = true})
    slot:SetCanDragDrop(true)
    slot.SlotElement:SetSizeOverride(self.SLOT_SIZE, self.SLOT_SIZE)
    self._Slots[self._SlotsAllocated] = slot
    self._SlotsAllocated = self._SlotsAllocated + 1

    -- Save the group when the slot is edited
    slot.Events.ObjectDraggedIn:Subscribe(function (_)
        GroupManager.SaveData()
    end)

    return slot
end

---@return number, number -- Width, height
function HotbarGroup:GetSlotAreaSize()
    local width = self._Columns * self.SLOT_SIZE + (self._Columns + 0) * self.SLOT_SPACING
    local height = self._Rows * self.SLOT_SIZE + (self._Rows + 0) * self.SLOT_SPACING

    return width, height
end

---@return GenericUI_Prefab_HotbarSlot
function HotbarGroup:_GetSlot(index)
    return self._Slots[index]
end

---@return GenericUI_Prefab_HotbarSlot
function HotbarGroup:GetSlot(row, column)
    return self._Slots[(row - 1) * self._Columns + column - 1]
end

---Returns the grid element of the group.
---@return GenericUI_Element_Grid
function HotbarGroup:GetGrid()
    return self._Container
end

---Returns the grid size of the group.
---@return integer, integer -- Rows, columns.
function HotbarGroup:GetSize()
    return self._Rows, self._Columns
end

---@param newRows integer
---@param newColumns integer
function HotbarGroup:Resize(newRows, newColumns)
    for _=self._Rows * self._Columns + 1,newRows * newColumns,1 do
        self:_AddSlot()
    end

    local oldSlotObjects = {}
    local oldRows, oldCols = self._Rows, self._Columns
    for i=1,self._Rows,1 do
        oldSlotObjects[i] = {}
        for j=1,self._Columns,1 do
            oldSlotObjects[i][j] = self:GetSlot(i, j).Object
        end
    end

    self._Rows = newRows
    self._Columns = newColumns

    for i=1,math.max(newRows,oldRows),1 do
        for j=1,math.max(newColumns,oldCols),1 do
            if i <= oldRows and j <= oldCols then
                self:GetSlot(i, j):SetObject(oldSlotObjects[i][j])
            else
                self:GetSlot(i, j):Clear()
            end
        end
    end

    local width, height = self:GetSlotAreaSize()

    self._Content:SetBackground("Black", width, height)

    self._Container:SetGridSize(newColumns, newRows)
    self._Container:RepositionElements()
    self._Container:SetSizeOverride(width, height)

    -- Dragging area/handle
    local mcWidth, mcHeight = width, height
    local EXTRA_WIDTH = 15 * 2
    -- Show the handle on the longest side of the slot group
    if not self:_IsHandleOnLeft() then
        self._DragArea:SetRotation(90)
        self._DragArea:SetSize(mcHeight + EXTRA_WIDTH)
        self._DragArea:SetPosition(0, -EXTRA_WIDTH/2)
    else
        self._DragArea:SetRotation(0)
        self._DragArea:SetSize(mcWidth + EXTRA_WIDTH)
        self._DragArea:SetPosition(-EXTRA_WIDTH/2, -25)
    end

    self:UpdatePosition()
end
---Returns whether the Hotbar Group can be dragged around.
---@return boolean
function HotbarGroup:IsPositionLocked()
    return self._LockPosition
end

---Sets whether the Hotbar Group can be dragged around.
---@param lock boolean
function HotbarGroup:SetLockPosition(lock)
    self._LockPosition = lock
    self._DragArea:SetVisible(not lock) -- Toggle dragging handle
end

---Returns whether the group's Y position should snap to the hotbar.
---@return boolean
function HotbarGroup:IsSnappingToHotbar()
    return self._SnapToHotbar
end

---Sets whether the group should snap to the hotbar.
---@param snap boolean
function HotbarGroup:SetSnapToHotbar(snap)
    self._SnapToHotbar = snap
    if snap then
        self:UpdatePosition()
    end
end

---Initializes the UI for a hotbar group.
---@param id string
---@param rows integer
---@param columns integer
---@return Features.HotbarGroups.UI.Group
function HotbarGroup.___Create(id, rows, columns)
    local group = Generic.Create("Features.HotbarGroups.UI.Group." .. id)
    group = HotbarGroup:__Create(group) ---@cast group Features.HotbarGroups.UI.Group

    group.GUID = id
    group._Slots = {}
    group._Rows = 0
    group._Columns = 0
    group._SlotsAllocated = 0
    group._LockPosition = false
    group._SnapToHotbar = false

    local content = group:CreateElement("ContentContainer" .. group.GUID, "GenericUI_Element_TiledBackground")
    content:SetAlpha(0)
    group._Content = content
    group._Content:SetPosition(25, 25)

    local container = content:AddChild("container" .. group.GUID, "GenericUI_Element_Grid")
    container:SetElementSpacing(HotbarGroup.SLOT_SPACING - 4, HotbarGroup.SLOT_SPACING)
    container:SetPosition(3, 3)
    container:SetRepositionAfterAdding(false)
    container:SetGridSize(group._Columns, group._Rows)
    group._Container = container
    group._Container:SetPosition(3, 3)

    local dragArea = content:AddChild("DragArea", "GenericUI_Element_Divider")
    dragArea:SetAsDraggableArea()
    dragArea:SetType("Border")
    dragArea.Tooltip = TSK.HotbarGroup_DragHandle_Tooltip:GetString()
    group._DragArea = dragArea

    -- Apply preference of snapping to hotbar when dragging the group.
    local dragTickListener = "Features.HotbarGroups.UI.Group." .. group.GUID .. ".DragTickListener"
    group:RegisterCallListener("startMoveWindow", function (_)
        GameState.Events.Tick:Subscribe(function (_)
            ---@diagnostic disable-next-line: invisible
            group:UpdatePosition()
        end, {StringID = dragTickListener})
    end)
    group:RegisterCallListener("cancelMoveWindow", function (_)
        GameState.Events.Tick:Unsubscribe(dragTickListener)
        GroupManager.SaveData() -- Save the group's new position
    end)

    -- Reposition the group when the hotbar bar changes.
    Hotbar:RegisterListener("Refreshed", function (_)
        ---@diagnostic disable-next-line: invisible
        group:UpdatePosition()
    end)

    group:Resize(rows, columns)

    group:GetUI().MovieLayout = 3 -- Allows UIScaling to apply to the group's UI.
    group:UpdatePosition()
    group:Show()

    return group
end

---Updates the position of the hotbar group according to snapping preferences.
function HotbarGroup:UpdatePosition()
    if not self._SnapToHotbar or not Client.GetCharacter() then return end -- Do nothing to the position if not snapping to hotbar or if the client has not been assigned a character yet (in which case Hotbar state is unavailable)

    -- Calculate hotbar height
    local rows = Hotbar.GetBarCount()
    local rowHeight = Hotbar.SLOT_SIZE + Hotbar.SLOT_SPACING
    local offset = rows * 2 -- Magic numbers galore as usual
    if rows == 1 then offset = offset + 5 end
    local hotbarTop = rowHeight * rows + offset
    hotbarTop = hotbarTop * self:GetUI():GetUIScaleMultiplier() -- Apply UIScaling

    -- Calculate group height
    local groupHeight = self._Container:GetHeight()
    if self:_IsHandleOnLeft() and not self:IsPositionLocked() then -- Compensate for drag handle when it is on the left.
        groupHeight = groupHeight + 16 - rows
    else
        groupHeight = groupHeight + (7 - rows)
    end
    groupHeight = groupHeight * self:GetUI():GetUIScaleMultiplier() -- Apply UIScaling

    -- Reposition group to snap to the top of the hotbar
    local x, _ = self:GetPosition()
    self:SetPosition(V(x, math.floor(Client.GetViewportSize()[2] - groupHeight - hotbarTop)))
end

---Returns whether the dragging handle should be on the left side of the group.
---@return boolean
function HotbarGroup:_IsHandleOnLeft()
    local width, height = self:GetSlotAreaSize()
    return width >= height
end
