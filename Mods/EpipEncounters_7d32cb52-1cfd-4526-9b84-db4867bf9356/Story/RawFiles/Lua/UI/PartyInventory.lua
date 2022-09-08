
---@class PartyInventoryUI : UI
local Inv = {
    ui = nil,
    root = nil,

    nextContentEvent = {},

    draggedItemHandle = nil,
    initialized = false,
    _inventoryIDs = {}, ---@type table<FlashObjectHandle, integer>
    _nextInventoryID = 0,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
    Events = {
        ContentUpdated = {}, ---@type SubscribableEvent<PartyInventoryUI_Event_ContentUpdated>
    },
    Hooks = {
        GetUpdate = {}, ---@type SubscribableEvent<PartyInventoryUI_Hooks_GetUpdate>
    },
    FILEPATH_OVERRIDES = {
        -- ["Public/Game/GUI/partyInventory.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/partyInventory.swf",
    }
}
Epip.InitializeUI(Client.UI.Data.UITypes.partyInventory, "PartyInventory", Inv)

---@class PartyInventoryItemUpdate
---@field CharacterHandle FlashObjectHandle
---@field ItemHandle FlashObjectHandle
---@field Amount uint64
---@field SlotID uint64
---@field IsNewItem boolean

---@class PartyInventoryUI_GoldWeightUpdate
---@field CharacterHandle FlashObjectHandle
---@field GoldLabel string
---@field WeightLabel string

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class PartyInventoryUI_Hooks_GetUpdate
---@field Items PartyInventoryItemUpdate[]
---@field GoldAndCarryWeight PartyInventoryUI_GoldWeightUpdate[]

---@class PartyInventoryUI_Event_ContentUpdated
---@field Items PartyInventoryItemUpdate[]

---------------------------------------------
-- METHODS
---------------------------------------------

-- Update the data on the UI. Item uses this to query item amounts from this UI, as Amount is not mapped on client.
function Inv.Refresh()
    Ext.UI.SetDirty(Client.GetCharacter().Handle, 16777216)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---@return PartyInventoryUI_GoldWeightUpdate[]
local function ParseGoldAndWeight()
    local root = Inv:GetRoot()
    local array = root.goldWeightList

    ---@type PartyInventoryUI_GoldWeightUpdate[]
    local data = Client.Flash.ParseArray(array, {
        "CharacterHandle",
        "GoldLabel",
        "WeightLabel",
    })

    return data
end

Inv:RegisterInvokeListener("updateItems", function(_)
    local root = Inv:GetRoot()
    local itemArray = root.itemsUpdateList

    ---@type PartyInventoryItemUpdate[]
    local items = Client.Flash.ParseArray(itemArray, {
        "CharacterHandle",
        "SlotID",
        "ItemHandle",
        "Amount",
        "IsNewItem",
    })

    ---@type PartyInventoryUI_Hooks_GetUpdate
    local ev = {
        Items = items,
        GoldAndCarryWeight = ParseGoldAndWeight()
    }

    -- TODO prevent action
    Inv.Hooks.GetUpdate:Throw(ev)

    -- Items
    for i=0,#ev.Items-1,1 do
        local item = ev.Items[i + 1]
        local index = i * 5

        itemArray[index] = item.CharacterHandle
        itemArray[index + 1] = item.SlotID
        itemArray[index + 2] = item.ItemHandle
        itemArray[index + 3] = item.Amount
        itemArray[index + 4] = item.IsNewItem
    end

    -- Gold and carry weight
    local arr = root.goldWeightList
    for i=0,#ev.GoldAndCarryWeight-1,1 do
        local data = ev.GoldAndCarryWeight[i + 1]
        local index = i * 3

        arr[index] = data.CharacterHandle
        arr[index + 1] = data.GoldLabel
        arr[index + 2] = data.WeightLabel
    end
    
    Inv.nextContentEvent = {Items = ev.Items}
end)

-- WIP.
if Epip.IsDeveloperMode(true) and false then
    Inv:RegisterInvokeListener("updateInventories", function (ev)
        local entries = Client.Flash.ParseArray(ev.UI:GetRoot().inventoryUpdateList, {
            "CharacterHandle",
            "Unknown2",
            "Unknown3",
            "Unknown4",
            "Unknown5",
        })
    
        for _,entry in ipairs(entries) do
            if Inv._inventoryIDs[entry.CharacterHandle] == nil then
                Inv._inventoryIDs[entry.CharacterHandle] = Inv._nextInventoryID
    
                Inv._nextInventoryID = Inv._nextInventoryID + 1
            end
        end
    end)
    
    -- Set icons for each item
    Inv.Hooks.GetUpdate:Subscribe(function (ev)
        local ui = Inv:GetUI()
    
        for _,entry in ipairs(ev.Items) do
            -- print("iggy_slot_" .. Text.RemoveTrailingZeros(entry.SlotID))
            if entry.ItemHandle > 0 then
                -- print(entry.CharacterHandle)
                local item = Item.Get(entry.ItemHandle, true)
                local icon = Item.GetIcon(item)
                local inventoryID = Inv._inventoryIDs[entry.CharacterHandle]
    
                local iggyIconID = string.format("inventory_%s_slot_%s", Text.RemoveTrailingZeros(inventoryID), Text.RemoveTrailingZeros(entry.SlotID))
                ui:SetCustomIcon(iggyIconID, icon, 50, 50)
            end
        end
    
        -- Reduced vanilla iggy icon opacity to check if icons are correct.
        local inv_mc = ui:GetRoot().inventory_mc
        inv_mc.list.content_array[0].inv.m_IggyImageHolder.alpha = 0
        inv_mc.list.content_array[1].inv.m_IggyImageHolder.alpha = 0
        inv_mc.list.content_array[2].inv.m_IggyImageHolder.alpha = 0
        inv_mc.list.content_array[3].inv.m_IggyImageHolder.alpha = 0
    end)
end

Inv:RegisterInvokeListener("updateItems", function(_)
    Inv.Events.ContentUpdated:Throw(Inv.nextContentEvent)
end, "After")

-- TODO fix
Ext.RegisterUINameCall("cancelDragging", function(ui, method)
    Inv:DebugLog("Cancelled dragging.")
    Inv.draggedItemHandle = nil
end)

Ext.RegisterUINameCall("stopDragging", function(ui, method, p1, p2)
    local selection = nil
    local target = nil

    if p2 == nil then
        selection = p1
    else
        selection = p2
        target = p1
    end

    Inv:DebugLog("Stopped dragging.")

    Inv.draggedItemHandle = nil
end)

Ext.RegisterUITypeCall(Client.UI.Data.UITypes.partyInventory, "startDragging", function(ui, method, handle)
    Inv:DebugLog("Started dragging: " .. handle)

    Inv.draggedItemHandle = handle
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Open the game when a session is loaded so it contains data right from the start.
Utilities.Hooks.RegisterListener("Game", "Loaded", function()
    if not Client.IsUsingController() then
        local ui = Inv:GetUI()

        ui:Show()

        Ext.OnNextTick(function()
            ui:Hide()
        end)
    end
end)