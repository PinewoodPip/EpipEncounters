
local Inv = Client.UI.PartyInventory

---@type Feature,unknown
local Improvements = {

}
Epip.AddFeature("InventoryImprovements", "InventoryImprovements", Improvements)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param items PartyInventoryItemUpdate[]
function Improvements.UpdateIcons(items)
    local root = Inv:GetRoot()
    local main = root.inventory_mc
    local inventoryList = main.list
    local inventories = {}

    for i=0,#inventoryList.content_array-1,1 do
        local inv = inventoryList.content_array[i]
        inventories[inv.id] = {
            Inventory = inv,
            ItemCells = {},
        }

        for z=0,#inv.inv.item_array-1,1 do
            local cell = inv.inv.item_array[z]

            inventories[inv.id].ItemCells[z] = cell
        end

        inv.inv.m_IggyImageHolder.name = ""
        inv.inv.m_IggyImageHolder.alpha = 0
    end

    for i,itemUpdate in ipairs(items) do
        local inventory = inventories[itemUpdate.CharacterHandle]
        local cell = inventory.ItemCells[itemUpdate.SlotID]

        print(cell) -- TODO new cells might be left to add

        if cell then
            cell.isnewitem_mc.visible = true
            -- cell.isnewitem_mc.name = "iggy_" .. Client.UI.Hotbar.ACTION_ICONS.AEROTHEURGE
        end

        -- if not cell then
        --     _D(itemUpdate)
        --     print(Item.Get(itemUpdate.ItemHandle).DisplayName)
        -- end
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Inv.Events.ContentUpdated:Subscribe(function (e)
    Improvements.UpdateIcons(e.Items)
end)