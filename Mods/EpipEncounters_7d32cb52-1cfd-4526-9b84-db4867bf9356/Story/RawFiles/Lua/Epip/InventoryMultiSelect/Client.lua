
---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")
local Events = MultiSelect.Events ---@class Features.InventoryMultiSelect.Events
local Hooks = MultiSelect.Hooks ---@class Features.InventoryMultiSelect.Hooks

MultiSelect.SELECTED_COLOR = Color.Create(255, 255, 255, 80)

MultiSelect._SelectedItems = {} ---@type table<ComponentHandle, Features.InventoryMultiSelect.Selection>
MultiSelect._MultiDragActive = false

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired when an item is selected or unselected.
---Client-only.
---@class Features.InventoryMultiSelect.Events.ItemSelectionChanged
---@field Selection Features.InventoryMultiSelect.Selection
---@field Selected boolean
---@type Event<Features.InventoryMultiSelect.Events.ItemSelectionChanged>
Events.ItemSelectionChanged = MultiSelect:AddSubscribableEvent("ItemSelectionChanged")

---Fired when requesting a sorted list of selections.
---Client-only.
---@class Features.InventoryMultiSelect.Hooks.SortSelection
---@field SelectionA Features.InventoryMultiSelect.Selection
---@field SelectionB Features.InventoryMultiSelect.Selection
---@field SortResult boolean Hookable.
---@type Hook<Features.InventoryMultiSelect.Hooks.SortSelection>
Hooks.SortSelection = MultiSelect:AddSubscribableEvent("SortSelection")

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias Features.InventoryMultiSelect.Selection.Type "PartyInventory"

---@class Features.InventoryMultiSelect.Selection
---@field Type Features.InventoryMultiSelect.Selection.Type
---@field ItemHandle ComponentHandle

---@class Features.InventoryMultiSelect.Selection.PartyInventory : Features.InventoryMultiSelect.Selection
---@field OwnerCharacterHandle ComponentHandle
---@field InventoryCell FlashMovieClip
---@field CellIndex integer 1-based.

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets the selection state of an item.
---@param item EclItem
---@param data Features.InventoryMultiSelect.Selection|false If `false`, will unselect the item. If a table is passed, it will be used as the base for the Selection entry.
function MultiSelect.SetItemSelected(item, data)
    local set = MultiSelect._SelectedItems
    local selected = data ~= false

    if selected then
        set[item.Handle] = data
    else
        data = set[item.Handle]
        set[item.Handle] = nil
    end

    -- Do not fire the event if requesting to unselect an item that was not previously selected.
    if data then
        MultiSelect.Events.ItemSelectionChanged:Throw({
            Selection = data,
            Selected = selected,
        })
    end
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
---@see Features.InventoryMultiSelect.Hooks.SortSelection
---@param type Features.InventoryMultiSelect.Selection.Type? If set, only selections of that type will be returned.
---@return Features.InventoryMultiSelect.Selection[]
function MultiSelect.GetOrderedSelections(type)
    local selections = MultiSelect.GetSelections()
    local orderedSelections = {} ---@type Features.InventoryMultiSelect.Selection[]
    for _,selection in pairs(selections) do
        if not type or selection.Type == type then
            table.insert(orderedSelections, selection)
        end
    end
    table.sort(orderedSelections, function (a, b)
        return MultiSelect.Hooks.SortSelection:Throw({
            SelectionA = a,
            SelectionB = b,
        }).SortResult
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

---Client-only override. Checks setting.
---@override
function MultiSelect:IsEnabled()
    return MultiSelect:GetSettingValue(MultiSelect.Settings.Enabled) == true and _Feature.IsEnabled(self)
end

---Sets or removes a highlight from an inventory-cell-like movie clip.
---@param slot FlashMovieClip
---@param slotSize Vector2
---@param highlighted boolean
function MultiSelect.SetSlotHighlight(slot, slotSize, highlighted)
    local graphics = slot.graphics
    graphics.clear()

    if highlighted then
        graphics.beginFill(MultiSelect.SELECTED_COLOR:ToDecimal(), MultiSelect.SELECTED_COLOR.Alpha / 255)
        graphics.drawRect(0, 0, slotSize[1], slotSize[2])
    end
end

---Creates a list of NetIDs from selections.
---@param selections Features.InventoryMultiSelect.Selection[]
---@return NetId[]
function MultiSelect._SelectionsToNetIDList(selections)
    local itemsNetIDs = {} ---@type NetId[]
    for _,selection in ipairs(selections) do
        table.insert(itemsNetIDs, Item.Get(selection.ItemHandle).NetID)
    end
    return itemsNetIDs
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Sort selections of different types.
MultiSelect.Hooks.SortSelection:Subscribe(function (ev)
    if ev.SelectionA.Type ~= ev.SelectionB.Type then
        ev.SortResult = ev.SelectionA.Type < ev.SelectionB.Type
    end
end)

-- Hide tooltips when a multi-drag starts.
MultiSelect.Events.MultiDragStarted:Subscribe(function (_)
    Client.Tooltip.HideTooltip()
end)
