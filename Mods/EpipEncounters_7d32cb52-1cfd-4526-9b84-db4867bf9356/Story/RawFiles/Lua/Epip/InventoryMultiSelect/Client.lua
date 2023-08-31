
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
    if selected == nil then
        selected = not MultiSelect.IsSelected(item)
    end

    -- Find the cell of the item within the UI
    local cell, cellIndex = MultiSelect._GetItemCell(item)
    if not cell then
        MultiSelect:InternalError("SelectItem", "Cell not found for", item.DisplayName)
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

---Returns the inventory movie clip of a character.
---@param owner EclCharacter
---@return FlashMovieClip
function MultiSelect._GetInventoryMovieClip(owner)
    local clips = MultiSelect._GetInventoryMovieClips()
    for _,mc in ipairs(clips) do
        if mc.id == Ext.UI.HandleToDouble(owner.Handle) then
            return mc
        end
    end
    return nil
end

---Returns the inventory cell that contains an item.
---@param item EclItem
---@return FlashMovieClip?, integer? -- Cell, cell index (1-based). `nil` if the item was not found within the inventory.
function MultiSelect._GetItemCell(item)
    local inventories = MultiSelect._GetInventoryMovieClips()
    local itemFlashHandle = Ext.UI.HandleToDouble(item.Handle)
    local owner = Character.Get(item:GetOwnerCharacter())
    local cell, cellIndex = nil, nil
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
    return cell, cellIndex
end

---Returns the character whose inventory header is being hovered over.
---@return EclCharacter?
function MultiSelect._GetSelectedInventoryHeader()
    local root = PartyInventory:GetRoot()
    local invMC = root.inventory_mc
    local char = nil

    for i=0,#invMC.list.content_array-1,1 do
        local playerInventory = invMC.list.content_array[i]
        if playerInventory.frame_mc.playerheader.currentFrame == 2 then
            char = Character.Get(playerInventory.id, true)
            break
        end
    end

    return char
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
PartyInventory:RegisterCallListener("slotUp", function (ev)
    if not Input.AreModifierKeysPressed() then
        MultiSelect.ClearSelections()
    elseif Input.IsShiftPressed() and MultiSelect.HasSelection() then -- Only prevent shift-click if we already have a selection. Otherwise, use vanilla behaviour (toggle wares)
        ev:PreventAction()
    end
end)

-- Listen for keys being pressed that should select/deselect items.
Input.Events.KeyPressed:Subscribe(function (ev)
    if MultiSelect._CurrentHoveredItemHandle and ev.InputID == "left2" then
        local item = Item.Get(MultiSelect._CurrentHoveredItemHandle)

        if Input.IsCtrlPressed() then -- Toggle selection of the item
            MultiSelect.SetItemSelected(item)
        elseif Input.IsShiftPressed() and MultiSelect.HasSelection() then -- Select range
            local orderedSelections = MultiSelect.GetOrderedSelections()
            local firstSelection = orderedSelections[1]
            local _, cellIndex = MultiSelect._GetItemCell(item)
            local inv = MultiSelect._GetInventoryMovieClip(Character.Get(item:GetOwnerCharacter()))

            -- Range selection works in either direction; can select ranges before or after the first item.
            local startIndex = math.min(firstSelection.CellIndex, cellIndex)
            local endIndex = math.max(firstSelection.CellIndex, cellIndex)
            for i=startIndex,endIndex,1 do
                local itemFlashHandle = inv.content_array[i - 1]._itemHandle
                if itemFlashHandle ~= 0 then
                    local cellItem = Item.Get(itemFlashHandle, true)
                    MultiSelect.SetItemSelected(cellItem, true)
                end
            end
        end
    end
end)