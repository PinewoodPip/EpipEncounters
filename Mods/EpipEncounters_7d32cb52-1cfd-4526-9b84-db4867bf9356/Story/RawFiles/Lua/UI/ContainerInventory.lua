
---------------------------------------------
-- APIs for the containerInventory.swf UI.
---------------------------------------------

local Flash = Client.Flash
local ParseFlashArray, EncodeFlashArray = Flash.ParseArray, Flash.EncodeArray

---@class UI.ContainerInventory : UI
local Inventory = {
    FLASH_ENTRY_TEMPLATES = {
        UPDATE_ITEMS = {
            "SlotIndex",
            "ItemHandle",
            "Amount",
            "Selected",
            "Disabled",
        },
    },

    _CurrentContainerHandle = nil, ---@type ItemHandle?

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        TakeAllPressed = {}, ---@type Event<Empty>
        DragStarted = {Preventable = true}, ---@type PreventableEvent<{ItemFlashHandle:FlashItemHandle}>
        HoveredItemChanged = {}, ---@type Event<UI.ContainerInventory.Events.HoveredItemChanged>
    },
    Hooks = {
        UpdateItems = {}, ---@type Hook<UI.ContainerInventory.Hooks.UpdateItems>
    }
}
Client.UI.ContainerInventory = Inventory
Epip.InitializeUI(Ext.UI.TypeID.containerInventory.Default, "ContainerInventory", Inventory)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class UI.ContainerInventory.Entries.ItemUpdate
---@field SlotIndex integer 0-based.
---@field ItemHandle FlashItemHandle
---@field Amount integer The slot will be cleared if amount is < 1, however this is unused behaviour - the slots are instead cleared by calling `clearSlots()` before all updates.
---@field Selected boolean
---@field Disabled boolean

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class UI.ContainerInventory.Events.HoveredItemChanged
---@field Item EclItem? `nil` if an item was hovered out.
---@field Index integer? `nil` if an item was hovered out.

---@class UI.ContainerInventory.Hooks.UpdateItems
---@field Entries UI.ContainerInventory.Entries.ItemUpdate[] Hookable.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the item currently being hovered.
---@return EclItem?, integer?, FlashMovieClip? -- Item (if any), slot index (1-based), cell. Slot index and cell may be returned even if no item is within the cell.
function Inventory.GetSelectedItem()
    local item, slotIndex, cell = nil, nil, nil
    cell, slotIndex = Inventory.GetSelectedCell()
    if cell and cell.itemHandle > 0 then
        item = Item.Get(cell.itemHandle, true)
    else
        cell, slotIndex = nil, nil
    end

    return item, slotIndex, cell
end

---Returns all cells currently in the UI.
---@return FlashMovieClip[], integer, integer -- Cells, grid width, grid height.
function Inventory.GetCells()
    local inv = Inventory:GetRoot().inv_mc
    local width, height = inv.cols, inv.rows
    local cells = {} ---@type FlashMovieClip[]
    for i=0,#inv.slot_array-1,1 do
        local cell = inv.slot_array[i]
        cells[i + 1] = cell
    end

    return cells, width, height
end

---Returns the cell being hovered over.
---@return FlashMovieClip?, integer? -- Cell, index (1-based). `nil` if no cell is being hovered.
function Inventory.GetSelectedCell()
    local inv = Inventory:GetRoot().inv_mc
    local selectedIndex = inv.currentHLSlot
    local cell, cellIndex = nil, nil
    if selectedIndex >= 0 then
        cell = inv.slot_array[selectedIndex]
        cellIndex = selectedIndex + 1
    end
    return cell, cellIndex
end

---Returns the cell of an item.
---@param item EclItem
---@return FlashMovieClip?, integer? -- `nil` if no cell with the item was found.
function Inventory.GetItemCell(item)
    local cells = Inventory.GetCells()
    local itemFlashHandle = Ext.UI.HandleToDouble(item.Handle)
    local cellIndex, itemCell = nil, nil
    for i,cell in ipairs(cells) do
        if cell.itemHandle == itemFlashHandle then
            cellIndex = i
            itemCell = cell
            break
        end
    end
    return itemCell, cellIndex
end

---Returns whether the container is owned by players; ie. in their inventory.
---This prevents the take-all button from appearing, but gives the client seemingly greater authority over managing the inventory, and preserves layout (empty slots are kept).
---@return boolean
function Inventory.IsPlayerInventory()
    return Inventory:GetRoot().playerInventory
end

---Returns the container currently open in the UI.
---@return EclItem? `nil` if the UI is closed.
function Inventory.GetContainerItem()
    return (Inventory._CurrentContainerHandle and Inventory:IsVisible()) and Item.Get(Inventory._CurrentContainerHandle) or nil
end

---@override
---@return UIObject
function Inventory:GetUI()
    return Ext.UI.GetByType(Ext.UI.TypeID.containerInventory.Default) or Ext.UI.GetByType(Ext.UI.TypeID.containerInventory.Pickpocket)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Hook item updates.
Inventory:RegisterInvokeListener("updateItems", function (ev, _)
    local root = ev.UI:GetRoot()
    local array = root.itemsUpdateList
    local entries = ParseFlashArray(array, Inventory.FLASH_ENTRY_TEMPLATES.UPDATE_ITEMS)

    entries = Inventory.Hooks.UpdateItems:Throw({
        Entries = entries,
    }).Entries

    EncodeFlashArray(array, Inventory.FLASH_ENTRY_TEMPLATES.UPDATE_ITEMS, entries)
end)

-- Forward and intercept drag events.
Inventory:RegisterCallListener("startDragging", function (ev, itemFlashHandle)
    local prevented = Inventory.Events.DragStarted:Throw({
        ItemFlashHandle = itemFlashHandle,
    }).Prevented

    if prevented then
        ev:PreventAction()
    end
end)

-- Forward take-all event.
Inventory:RegisterCallListener("takeAll", function (_)
    Inventory.Events.TakeAllPressed:Throw()
end)

-- Forward item hover events.
Inventory:RegisterCallListener("slotOver", function (_, itemFlashHandle, index)
    Inventory.Events.HoveredItemChanged:Throw({
        Item = Item.Get(itemFlashHandle, true),
        Index = index + 1,
    })
end)
Inventory:RegisterCallListener("slotOut", function (_)
    Inventory.Events.HoveredItemChanged:Throw({
        Item = nil,
    })
end)

-- Track the container open in the UI.
-- We currently have no client-side way of determining this,
-- other than trying to catch every interaction with an item client-side - unreasonable to implement.
Item.Events.ItemUsed:Subscribe(function (ev)
    local char, item = ev.Character, ev.Item
    if char == Client.GetCharacter() and Item.IsContainer(item) then
        Inventory._CurrentContainerHandle = item.Handle
    end
end)
