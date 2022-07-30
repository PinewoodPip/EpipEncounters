
---@class PartyInventoryUI : UI
local Inv = {
    ui = nil,
    root = nil,

    nextContentEvent = {},

    draggedItemHandle = nil,
    initialized = false,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
    Events = {
        ContentUpdated = {}, ---@type SubscribableEvent<PartyInventoryUI_Event_ContentUpdated>
    },
    Hooks = {
        GetUpdate = {}, ---@type SubscribableEvent<PartyInventoryUI_Hooks_GetUpdate>
    },
}
Client.UI.PartyInventory = Inv
Epip.InitializeUI(Client.UI.Data.UITypes.partyInventory, "PartyInventory", Inv)

---@class PartyInventoryItemUpdate
---@field CharacterHandle FlashObjectHandle
---@field ItemHandle FlashObjectHandle
---@field Amount uint64
---@field SlotID uint64
---@field IsNewItem boolean

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class PartyInventoryUI_Hooks_GetUpdate
---@field Items PartyInventoryItemUpdate[]

---@class PartyInventoryUI_Event_ContentUpdated
---@field Items PartyInventoryItemUpdate[]

---------------------------------------------
-- METHODS
---------------------------------------------

-- Unlock the inventory of a player.
function Inv.AutoUnlockFor(chars)
    for char,unlock in pairs(chars) do
        if unlock then
            -- Temporarily unavailable
            -- Inv:GetUI():ExternalInterfaceCall("lockInventory", Ext.UI.HandleToDouble(Ext.GetCharacter(char).Handle), false)

            Inv:Log("Unlocked " .. char .. "'s inventory.")
        end
    end
end

-- Update the data on the UI. Item uses this to query item amounts from this UI, as Amount is not mapped on client.
function Inv.Refresh()
    Ext.UI.SetDirty(Client.GetCharacter().Handle, 16777216)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

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
    }

    -- TODO prevent action
    Inv.Hooks.GetUpdate:Throw(ev)

    for i=0,#ev.Items-1,1 do
        local item = ev.Items[i + 1]
        local index = i * 5

        itemArray[index] = item.CharacterHandle
        itemArray[index + 1] = item.SlotID
        itemArray[index + 2] = item.ItemHandle
        itemArray[index + 3] = item.Amount
        itemArray[index + 4] = item.IsNewItem
    end
    
    Inv.nextContentEvent = {Items = ev.Items}
end)

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

-- auto-unlock inventories setting; per player.
Net.RegisterListener("EPIPENCOUNTERS_AutoUnlockPartyInventory", function(event, payload)
    Inv.AutoUnlockFor(payload.Chars)
end)

-- Notify the server we want our inventories to be unlocked when game begins running.
Ext.Events.GameStateChanged:Subscribe(function(event)
    local from = event.FromState
    local to = event.ToState
    
    if from == "PrepareRunning" and to == "Running" and Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "AutoUnlockInventory") and not Client.IsUsingController() then
        Net.PostToServer("EPIPENCOUNTERS_AutoUnlockMe", {NetID = Client.GetCharacter().NetID})
    end
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