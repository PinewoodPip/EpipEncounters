
local Flash = Client.Flash

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

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        TakeAllPressed = {}, ---@type Event<EmptyEvent>
        DragStarted = {Preventable = true}, ---@type PreventableEvent<{ItemFlashHandle:FlashItemHandle}>
    },
    Hooks = {
        UpdateItems = {}, ---@type Hook<UI.ContainerInventory.Hooks.UpdateItems>
    }
}
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

---@class UI.ContainerInventory.Hooks.UpdateItems
---@field Entries UI.ContainerInventory.Entries.ItemUpdate[] Hookable.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the item currently being hovered.
---@return EclItem?, integer?, FlashMovieClip? -- Item (if any), slot index (1-based), cell. Slot index and cell may be returned even if no item is within the cell.
function Inventory.GetSelectedItem()
    local inv = Inventory:GetRoot().inv_mc
    local selectedIndex = inv.currentHLSlot
    local item, slotIndex, cell = nil, nil, nil

    if selectedIndex >= 0 then
        slotIndex = selectedIndex + 1
        cell = inv.slot_array[selectedIndex]
        if cell.itemHandle > 0 then
            item = Item.Get(cell.itemHandle, true)
        end
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
    local entries = Flash.ParseArray(array, Inventory.FLASH_ENTRY_TEMPLATES.UPDATE_ITEMS)

    entries = Inventory.Hooks.UpdateItems:Throw({
        Entries = entries,
    }).Entries

    Flash.EncodeArray(array, Inventory.FLASH_ENTRY_TEMPLATES.UPDATE_ITEMS, entries)
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