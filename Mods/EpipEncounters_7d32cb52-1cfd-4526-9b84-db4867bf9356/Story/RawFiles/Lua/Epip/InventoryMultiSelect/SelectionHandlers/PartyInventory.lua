
local PartyInventory = Client.UI.PartyInventory
local Input = Client.Input
local V = Vector.Create

local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")
MultiSelect.PARTYINVENTORY_CELL_SIZE =  V(50, 50)
MultiSelect._UI_INVISIBLE_LISTENER = "Features.InventoryMultiSelect.IsUIVisible"
MultiSelect._CurrentHoveredItemHandle = nil ---@type ComponentHandle?

---------------------------------------------
-- METHODS
---------------------------------------------

---Toggles the selection for an item in the Party Inventory UI.
---@param item EclItem
---@param selected boolean? If `nil`, will toggle selection.
function MultiSelect._TogglePartyInventorySelection(item, selected)
    local cell, cellIndex = MultiSelect._GetItemCell(item) -- Find the cell of the item within the UI
    ---@type Features.InventoryMultiSelect.Selection.PartyInventory
    local selection = {
        Type = "PartyInventory",
        ItemHandle = item.Handle,
        InventoryCell = cell,
        CellIndex = cellIndex,
        OwnerCharacterHandle = Character.Get(item:GetOwnerCharacter()).Handle,
    }
    if selected == nil then
        selected = not MultiSelect.IsSelected(item)
    end

    if not selected then
        MultiSelect.SetItemSelected(item, false)
    else
        if not cell then
            -- This may happen if the item was equipped or moved out by external shenanigans
            -- MultiSelect:InternalError("SelectItem", "Cell not found for", item.DisplayName)
            return
        end

        MultiSelect.SetItemSelected(item, selection)

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
end

---Moves an item within the party inventory.
---@param item EclItem|ItemHandle
---@param inventoryID integer
---@param slotIndex integer
function MultiSelect._MoveItemToPartyInventorySlot(item, inventoryID, slotIndex)
    local itemHandle = item
    if GetExtType(item) == "ecl::Item" then
        itemHandle = item.Handle
    end
    -- Needs M1 held beforehand, or the client will stop the drag immediately
    Client.Input.Inject("Mouse", "left2", "Pressed")
    local itemFlashHandle = Ext.UI.HandleToDouble(itemHandle)
    PartyInventory:ExternalInterfaceCall("startDragging", itemFlashHandle)
    PartyInventory:ExternalInterfaceCall("stopDragging", inventoryID, slotIndex)
    Client.Input.Inject("Mouse", "left2", "Released")
end

---Returns the inventory cell that contains an item.
---@param item EclItem
---@return FlashMovieClip?, integer?, integer? -- Cell, cell index (1-based), inventory ID. `nil` if the item was not found within the inventory.
function MultiSelect._GetItemCell(item)
    local inventories = MultiSelect._GetInventoryMovieClips()
    local itemFlashHandle = Ext.UI.HandleToDouble(item.Handle)
    local owner = Character.Get(item:GetOwnerCharacter())
    local cell, cellIndex, inventoryID = nil, nil, nil
    for _,inv in ipairs(inventories) do
        local handle = Ext.UI.DoubleToHandle(inv.id)
        if handle == owner.Handle then
            for i=0,#inv.content_array-1,1 do
                local slot = inv.content_array[i]
                if slot._itemHandle == itemFlashHandle then
                    cell = slot
                    cellIndex = i + 1 -- 1-based.
                    inventoryID = inv.id
                    goto CellFound
                end
            end
        end
    end
    ::CellFound::
    return cell, cellIndex, inventoryID
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

-- Listen for input actions to select/deselect items.
Input.Events.ActionExecuted:Subscribe(function (ev)
    local item = Item.Get(MultiSelect._CurrentHoveredItemHandle)
    if ev.Action == MultiSelect.InputActions.ToggleSelection then
        MultiSelect._TogglePartyInventorySelection(item)
    elseif ev.Action == MultiSelect.InputActions.SelectRange and MultiSelect.HasSelection() then
        local orderedSelections = MultiSelect.GetOrderedSelections("PartyInventory") ---@cast orderedSelections Features.InventoryMultiSelect.Selection.PartyInventory[]
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
                MultiSelect._TogglePartyInventorySelection(cellItem, true)
            end
        end
    end
end, {EnabledFunctor = function ()
    return MultiSelect._CurrentHoveredItemHandle ~= nil and MultiSelect:IsEnabled()
end})

-- Add/clear selection visuals.
MultiSelect.Events.ItemSelectionChanged:Subscribe(function (ev)
    local selection = ev.Selection
    if selection.Type == "PartyInventory" then
        ---@cast selection Features.InventoryMultiSelect.Selection.PartyInventory
        local cell, cellIndex, _ = MultiSelect._GetItemCell(Item.Get(selection.ItemHandle)) -- Find the cell of the item within the UI
        if cell then -- When deselecting, cell might no longer exist if the deselection was caused by the cell being deleted (ex. inventory filters changed)
            MultiSelect.SetSlotHighlight(cell, MultiSelect.PARTYINVENTORY_CELL_SIZE, ev.Selected)
        end

        -- Deselect the item if the cell no longer contains it.
        -- A tick listener is required for this as operations like changing filters
        -- delete the cells before sending the corresponding UICall.
        if ev.Selected then
            local tickListenerID = Text.GenerateGUID()
            GameState.Events.RunningTick:Subscribe(function (_)
                local item = Item.Get(selection.ItemHandle)
                if not MultiSelect.IsSelected(item) then
                    GameState.Events.RunningTick:Unsubscribe(tickListenerID)
                    return
                end

                -- Unhighlight the cell if the item is no longer in it
                local currentCell, currentCellIndex, _ = MultiSelect._GetItemCell(item)
                if not currentCell or currentCellIndex ~= cellIndex then
                    MultiSelect.SetSlotHighlight(cell, MultiSelect.PARTYINVENTORY_CELL_SIZE, false) -- Necessary as the selection might not be pointing to the same cell anymore.
                    MultiSelect.SetItemSelected(Item.Get(selection.ItemHandle), false)
                    GameState.Events.RunningTick:Unsubscribe(tickListenerID)
                end
            end, {StringID = tickListenerID})
        end
    end
end)

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
    else
        MultiSelect.ClearSelections()
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
    if MultiSelect.HasSelection() and MultiSelect.IsSelectingRange() then -- Only prevent shift-click if we already have a selection. Otherwise, use vanilla behaviour (toggle wares)
        ev:PreventAction()
    elseif not MultiSelect.IsUsingMultiSelectActions() then
        MultiSelect.ClearSelections()
    end
end)
PartyInventory:RegisterCallListener("doubleClickItem", function (ev, _)
    if MultiSelect.HasSelection() or MultiSelect.IsTogglingSelection() then
        ev:PreventAction()
    end
end)

-- Cancel selections when inventory sorting is applied,
-- as the cells of the items might change.
local _TryClearSelections = function (_)
    if MultiSelect.HasSelection() then
        MultiSelect.ClearSelections()
    end
end
PartyInventory:RegisterCallListener("autosort", _TryClearSelections)
PartyInventory:RegisterCallListener("applySortFilters", _TryClearSelections)

-- Sort selections from the party inventory.
MultiSelect.Hooks.SortSelection:Subscribe(function (ev)
    if ev.SelectionA.Type == "PartyInventory" and ev.SelectionB.Type == "PartyInventory" then
        local selA = ev.SelectionA ---@cast selA Features.InventoryMultiSelect.Selection.PartyInventory
        local selB = ev.SelectionB ---@cast selB Features.InventoryMultiSelect.Selection.PartyInventory
        ev.SortResult = selA.CellIndex < selB.CellIndex
    end
end)
