
local PartyInventory = Client.UI.PartyInventory
local Input = Client.Input
local V = Vector.Create

---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")

MultiSelect.SELECTED_COLOR = Color.Create(255, 255, 255, 80)
MultiSelect.CELL_SIZE =  V(50, 50)
MultiSelect._UI_INVISIBLE_LISTENER = "Features.InventoryMultiSelect.IsUIVisible"

MultiSelect._CurrentHoveredItemHandle = nil ---@type ComponentHandle?
MultiSelect._SelectedItems = {} ---@type table<ComponentHandle, Features.InventoryMultiSelect.Selection>
MultiSelect._MultiDragActive = false

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.InventoryMultiSelect.Selection
---@field ItemHandle ComponentHandle
---@field InventoryCell FlashMovieClip
---@field CellIndex integer 1-based.

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets the selection state of an item.
---@param item EclItem
---@param selected boolean? Defaults to toggling.
function MultiSelect.SetItemSelected(item, selected)
    local set = MultiSelect._SelectedItems
    local inventories = MultiSelect._GetInventoryMovieClips()
    if selected == nil then
        selected = not MultiSelect.IsSelected(item)
    end

    -- Find the cell of the item within the UI
    local itemFlashHandle = Ext.UI.HandleToDouble(item.Handle)
    local owner = Character.Get(item:GetOwnerCharacter())
    local cell, cellIndex
    for _,inv in ipairs(inventories) do
        local handle = Ext.UI.DoubleToHandle(inv.id)
        if handle == owner.Handle then
            for i=0,#inv.content_array-1,1 do
                local slot = inv.content_array[i]
                if slot._itemHandle == itemFlashHandle then
                    cell = slot
                    cellIndex = i + 1 -- 1-based.
                    goto CellFound
                end
            end
        end
    end
    ::CellFound::

    if not cell then
        MultiSelect:InternalError("SelectItem", "Cell not found for", item.DisplayName, "in", owner.DisplayName)
    end

    if selected then
        set[item.Handle] = {
            ItemHandle = item.Handle,
            InventoryCell = cell,
            CellIndex = cellIndex,
        }
    else
        set[item.Handle] = nil
    end

    MultiSelect._SetSlotHighlight(cell, selected)

    -- Listen for the UI closing to clear selection
    GameState.Events.RunningTick:Unsubscribe(MultiSelect._UI_INVISIBLE_LISTENER)
    GameState.Events.RunningTick:Subscribe(function (_)
        -- Clear selections if the UI is closed and we are not multi-dragging
        if not PartyInventory:IsVisible() and not MultiSelect.IsMultiDragActive() then
            MultiSelect.ClearSelections()
            GameState.Events.RunningTick:Unsubscribe(MultiSelect._UI_INVISIBLE_LISTENER)
        end
    end, {StringID = MultiSelect._UI_INVISIBLE_LISTENER})
end

---Removes all item selections.
function MultiSelect.ClearSelections()
    for handle,_ in pairs(MultiSelect._SelectedItems) do
        MultiSelect.SetItemSelected(Item.Get(handle), false)
    end
    MultiSelect:DebugLog("Selections cleared")
end

---Returns whether any items are selected.
---@return boolean
function MultiSelect.HasSelection()
    return next(MultiSelect._SelectedItems) ~= nil
end

---Returns the items selected.
---@return table<ComponentHandle, Features.InventoryMultiSelect.Selection> -- Do not modify
function MultiSelect.GetSelections()
    return MultiSelect._SelectedItems
end

---Returns the items selected, ordered by inventory cell index.
---@return Features.InventoryMultiSelect.Selection[]
function MultiSelect.GetOrderedSelections()
    local selections = MultiSelect.GetSelections()
    local orderedSelections = {} ---@type Features.InventoryMultiSelect.Selection[]
    for _,selection in pairs(selections) do
        table.insert(orderedSelections, selection)
    end
    table.sort(orderedSelections, function (a, b)
        return a.CellIndex < b.CellIndex
    end)
    return orderedSelections
end

---Returns whether an item is selected.
---@param item EclItem
---@return boolean
function MultiSelect.IsSelected(item)
    return MultiSelect._SelectedItems[item.Handle] ~= nil
end

---Returns whether the selections are being multi-dragged.
---@return boolean
function MultiSelect.IsMultiDragActive()
    return MultiSelect._MultiDragActive
end

---Begins multi-dragging.
function MultiSelect.StartMultiDrag()
    if MultiSelect.IsMultiDragActive() then
        MultiSelect:Error("StartMultiDrag", "Already multi-dragging")
    end
    MultiSelect:DebugLog("Starting multi-drag")
    MultiSelect.Events.MultiDragStarted:Throw()
    MultiSelect._MultiDragActive = true
end

---Ends multi-dragging.
function MultiSelect.EndMultiDrag()
    if not MultiSelect.IsMultiDragActive() then
        MultiSelect:Error("EndMultiDrag", "No multi-drag is active")
    end

    -- Throw event. If handled, user code should stop propagation.
    local selections = MultiSelect.GetSelections()
    local orderedSelections = MultiSelect.GetOrderedSelections()
    MultiSelect.Events.MultiDragEnded:Throw({
        Selections = selections,
        OrderedSelections = orderedSelections,
    })

    MultiSelect.ClearSelections()
    MultiSelect._MultiDragActive = false
end

---Sets or removes a highlight from an inventory cell.
---@param slot FlashMovieClip
---@param highlighted boolean
function MultiSelect._SetSlotHighlight(slot, highlighted)
    local graphics = slot.graphics
    graphics.clear()

    if highlighted then
        local cellSize = MultiSelect.CELL_SIZE

        graphics.beginFill(MultiSelect.SELECTED_COLOR:ToDecimal(), MultiSelect.SELECTED_COLOR.Alpha / 255)
        graphics.drawRect(0, 0, cellSize[1], cellSize[2])
    end
end

---Returns the movie clips of all inventories.
---@return FlashMovieClip[]
function MultiSelect._GetInventoryMovieClips()
    local root = PartyInventory:GetRoot()
    local mcs = {} ---@type FlashMovieClip[]
    local invMC = root.inventory_mc
    for i=0,#invMC.list.content_array-1,1 do
        mcs[i + 1] = invMC.list.content_array[i].inv
    end
    return mcs
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for slots being hovered over or out to track the hovered item.
PartyInventory:RegisterCallListener("slotOver", function (_, flashItemHandle)
    if flashItemHandle ~= 0 then
        MultiSelect._CurrentHoveredItemHandle = Ext.UI.DoubleToHandle(flashItemHandle)
    end
end)
PartyInventory:RegisterCallListener("slotOut", function (_, _)
    MultiSelect._CurrentHoveredItemHandle = nil
end)

-- Listen for item drags being started, to prevent them if they were to start a multi-drag.
PartyInventory:RegisterCallListener("startDragging", function (ev, itemHandle)
    local item = Item.Get(itemHandle, true)
    if MultiSelect.IsSelected(item) then -- Can only start multi-drag from a selected item.
        MultiSelect.StartMultiDrag()
        ev:PreventAction()
    end
end)

-- Prevent item tooltips while a multi-drag is active.
PartyInventory:RegisterCallListener("showItemTooltip", function (ev)
    if MultiSelect.IsMultiDragActive() then
        ev:PreventAction()
    end
end)

-- Clear selections when an item is clicked.
PartyInventory:RegisterCallListener("slotUp", function (_)
    if not Input.IsCtrlPressed() then
        MultiSelect.ClearSelections()
    end
end)

-- Listen for keys being pressed that should select/deselect items.
Input.Events.KeyPressed:Subscribe(function (ev)
    if ev.InputID == "left2" and Input.IsCtrlPressed() and MultiSelect._CurrentHoveredItemHandle then
        local item = Item.Get(MultiSelect._CurrentHoveredItemHandle)
        MultiSelect.SetItemSelected(item)
    end
end)