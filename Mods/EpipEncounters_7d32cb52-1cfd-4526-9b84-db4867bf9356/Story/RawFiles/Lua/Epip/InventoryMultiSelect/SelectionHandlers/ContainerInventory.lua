
---------------------------------------------
-- Implements support for InventoryMultiSelect to the ContainerInventory UI.
---------------------------------------------

local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")
local ContainerInventory = Client.UI.ContainerInventory
local ContextMenu = Client.UI.ContextMenu
local Input = Client.Input

---@type Feature
local ContainerSelections = {
    SLOT_SIZE = Vector.Create(64, 64),

    _CurrentHoveredItemHandle = nil, ---@type ItemHandle?
}
Epip.RegisterFeature("Features.InventoryMultiSelect.ContainerSelections", ContainerSelections)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@diagnostic disable-next-line: duplicate-doc-alias
---@alias Features.InventoryMultiSelect.Selection.Type "ContainerInventory"

---@class Features.InventoryMultiSelect.Selection.ContainerInventory : Features.InventoryMultiSelect.Selection
---@field ContainerItemHandle ItemHandle
---@field InventoryCell FlashMovieClip
---@field CellIndex integer 1-based.

---------------------------------------------
-- METHODS
---------------------------------------------

---Toggles the selection for an item.
---@param item EclItem
---@param selected boolean? Defaults to toggling.
function ContainerSelections.ToggleItemSelection(item, selected)
    local cell, cellIndex = ContainerInventory.GetItemCell(item)
    ---@type Features.InventoryMultiSelect.Selection.ContainerInventory
    local selection = {
        Type = "ContainerInventory",
        ItemHandle = item.Handle,
        InventoryCell = cell,
        CellIndex = cellIndex,
        OwnerCharacterHandle = Character.Get(item:GetOwnerCharacter()).Handle,
    }
    if selected == nil then
        selected = not MultiSelect.IsSelected(item)
    end

    if selected then
        MultiSelect.SetItemSelected(item, selection)
    else
        MultiSelect.SetItemSelected(item, false)
    end
end

---Returns the item being hovered over.
---@return EclItem
function ContainerSelections.GetHoveredItem()
    return ContainerInventory.GetSelectedItem() -- Discards cell, index.
end

---Moves an item within the container's inventory.
---@param item EclItem|ItemHandle
---@param slotIndex integer 1-based.
function ContainerSelections._MoveItemToSlot(item, slotIndex)
    local itemHandle = item
    if GetExtType(item) == "ecl::Item" then
        itemHandle = item.Handle
    end
    Client.Input.Inject("Mouse", "left2", "Pressed")
    local itemFlashHandle = Ext.UI.HandleToDouble(itemHandle)
    ContainerInventory:ExternalInterfaceCall("startDragging", itemFlashHandle)
    ContainerInventory:ExternalInterfaceCall("stopDragging", slotIndex - 1)
    Client.Input.Inject("Mouse", "left2", "Released")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for keys being pressed that should select/deselect items.
Input.Events.KeyReleased:Subscribe(function (ev)
    if ContainerSelections._CurrentHoveredItemHandle and ev.InputID == "left2" and MultiSelect:IsEnabled() then
        local item = Item.Get(ContainerSelections._CurrentHoveredItemHandle)

        if Input.IsCtrlPressed() then -- Toggle selection of the item
            ContainerSelections.ToggleItemSelection(item)
        elseif Input.IsShiftPressed() and MultiSelect.HasSelection() then -- Select range
            local orderedSelections = MultiSelect.GetOrderedSelections("ContainerInventory") ---@cast orderedSelections Features.InventoryMultiSelect.Selection.PartyInventory[]
            local firstSelection = orderedSelections[1]
            local _, cellIndex = ContainerInventory.GetItemCell(item)
            local cells = ContainerInventory.GetCells()

            -- Range selection works in either direction; can select ranges before or after the first item.
            local startIndex = math.min(firstSelection.CellIndex, cellIndex)
            local endIndex = math.max(firstSelection.CellIndex, cellIndex)
            for i=startIndex,endIndex,1 do -- Select all cells in the range that have an item.
                local cell = cells[i]
                if cell.itemHandle ~= 0 then
                    ContainerSelections.ToggleItemSelection(Item.Get(cell.itemHandle, true), true)
                end
            end

            ContainerSelections:DebugLog("It's not quite as thrilling the second time around, yet at the same time, I'm far more impressed by the multi-select feature now that container inventories work - and simultaneously with selections in the party inventory too!")
        end
    end
end)

-- Listen for item drags being started, to prevent them if they were to start a multi-drag.
ContainerInventory:RegisterCallListener("startDragging", function (ev, itemHandle)
    local item = Item.Get(itemHandle, true)
    if MultiSelect.IsSelected(item) then -- Can only start multi-drag from a selected item.
        MultiSelect.StartMultiDrag()
        ev:PreventAction()
    else
        MultiSelect.ClearSelections()
    end
end)

-- Replace the context menu with a custom one while right-clicking a selection.
ContainerInventory:RegisterCallListener("openContextMenu", function (ev, flashItemHandle) -- First param is character handle.
    local item = Item.Get(flashItemHandle, true)
    if item and MultiSelect.IsSelected(item) then -- Only do this if right-clicking a selection.
        local x, y = Client.GetMousePosition()
        ContextMenu.RequestMenu(x, y, "Features.InventoryMultiSelect", nil)

        ev:PreventAction()
    else -- Clear selections if an unrelated item was context menu'd
        MultiSelect.ClearSelections()
    end
end)

-- Handle multi-drags ending.
MultiSelect.Events.MultiDragEnded:Subscribe(function (ev)
    -- Listen for multi-drags ending over a container item.
    -- This will move selected items into the container.
    local item = ContainerSelections.GetHoveredItem()
    if item and Item.IsContainer(item) then
        -- TODO extract to some "MultiDragOperations" feature
        MultiSelect:DebugLog("Sending selections to container", item.DisplayName)

        Net.PostToServer(MultiSelect.NETMSG_SEND_TO_CONTAINER, {
            ItemNetIDs = MultiSelect._SelectionsToNetIDList(ev.OrderedSelections),
            TargetContainerNetID = item.NetID,
        })

        ev:StopPropagation()
        ContainerInventory:PlaySound(MultiSelect.SOUND_DRAG_TO_SLOT)
    else
        local _, selectedSlotIndex = ContainerInventory.GetSelectedCell()
        if selectedSlotIndex then
            -- Put items into hovered slot and subsequent available ones
            -- Must be done next tick, or emulating startDragging will throw "Already multi-dragging" error
            Ext.OnNextTick(function ()
                local cells = ContainerInventory.GetCells()
                local nextSlotIndex = selectedSlotIndex

                -- Move each selection to the next available slot starting from hovered one
                for _,selection in ipairs(ev.OrderedSelections) do
                    item = Item.Get(selection.ItemHandle)
                    local slot = cells[nextSlotIndex]
                    while slot.itemHandle ~= 0 do -- Search next empty slot
                        nextSlotIndex = nextSlotIndex + 1
                        slot = cells[nextSlotIndex]
                        if nextSlotIndex > 999 then -- TODO check whether we've run out of slots
                            MultiSelect:InternalError("Events.MultiDragEnded", "Could not find slot within reasonable range")
                        end
                    end

                    ContainerSelections._MoveItemToSlot(item, nextSlotIndex)

                    nextSlotIndex = nextSlotIndex + 1
                end
            end)
            ContainerInventory:PlaySound(MultiSelect.SOUND_DRAG_TO_SLOT)
            ev:StopPropagation()
        end
    end
end, {StringID = "DefaultImplementation"})

-- Track the hovered item.
ContainerInventory.Events.HoveredItemChanged:Subscribe(function (ev)
    local item = ev.Item
    ContainerSelections._CurrentHoveredItemHandle = item and item.Handle or nil
end)

-- Prevent slot clicks while multi-selecting items
local PreventCallWhileMultiSelecting = function (ev)
    if Input.IsCtrlPressed() or (MultiSelect.HasSelection() and Input.IsShiftPressed()) then
       ev:PreventAction()
       ev:StopPropagation()
   end
end
ContainerInventory:RegisterCallListener("slotUp", PreventCallWhileMultiSelecting)
ContainerInventory:RegisterCallListener("doubleClickItem", PreventCallWhileMultiSelecting)

-- Apply selection visuals to the UI.
MultiSelect.Events.ItemSelectionChanged:Subscribe(function (ev)
    local selection = ev.Selection
    if selection.Type == "ContainerInventory" then
        ---@cast selection Features.InventoryMultiSelect.Selection.ContainerInventory
        MultiSelect.SetSlotHighlight(selection.InventoryCell, ContainerSelections.SLOT_SIZE, ev.Selected)
    end
end)

-- Cancel selections when an item is used.
ContainerInventory:RegisterCallListener("useItem", function (_)
    MultiSelect.ClearSelections()
end)
ContainerInventory:RegisterCallListener("doubleClickItem", function (ev)
    if not ev.ActionPrevented then
        MultiSelect.ClearSelections()
    end
end)
