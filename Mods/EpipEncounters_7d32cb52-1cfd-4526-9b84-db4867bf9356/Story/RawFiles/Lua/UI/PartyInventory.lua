
---------------------------------------------
-- APIs for the partyInventory.swf UI.
---------------------------------------------

local Flash = Client.Flash
local ParseFlashArray, EncodeFlashArray = Flash.ParseArray, Flash.EncodeArray

---@class PartyInventoryUI : UI
local Inv = {
    FLASH_ARRAY_TEMPLATES = {
        UPDATE_ITEMS = {
            "CharacterHandle",
            "SlotID",
            "ItemHandle",
            "Amount",
            "IsNewItem",
        },
        GOLD_AND_WEIGHT = {
            "CharacterHandle",
            "GoldLabel",
            "WeightLabel",
        },
        UPDATE_INVENTORIES = {
            "CharacterHandle",
            "InventoryName",
            "OwnedByClient",
            "Locked",
            "Unused5",
        }
    },
    ---@enum UI.PartyInventory.FilterTab
    FILTER_TABS = {
        EQUIPMENT = 2,
        CONSUMABLES = 3,
        MAGICAL = 4,
        INGREDIENTS = 5,
        MISCELLANEOUS = 6,
        BOOKS_AND_KEYS = 7,
        WARES = 8,
    },

    initialized = false,
    _inventoryIDs = {}, ---@type table<FlashObjectHandle, integer>
    _nextInventoryID = 0,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
    Events = {},
    Hooks = {
        GetUpdate = {}, ---@type Event<PartyInventoryUI_Hooks_GetUpdate>
        GetInventoryUpdate = {}, ---@type Event<UI.PartyInventory.Hooks.GetInventoryUpdate>
    },
}
Epip.InitializeUI(Ext.UI.TypeID.partyInventory, "PartyInventory", Inv)

---@class PartyInventoryItemUpdate
---@field CharacterHandle FlashCharacterHandle
---@field ItemHandle FlashItemHandle
---@field Amount uint64
---@field SlotID uint64
---@field IsNewItem boolean

---@class PartyInventoryUI_GoldWeightUpdate
---@field CharacterHandle FlashCharacterHandle
---@field GoldLabel string
---@field WeightLabel string

---@class UI.PartyInventory.FlashEntries.InventoryUpdate
---@field CharacterHandle FlashCharacterHandle
---@field InventoryName string In the format "{Character name}'s Bag"
---@field OwnedByClient boolean
---@field Locked boolean
---@field Unused5 integer Seemingly the index, from top to bottom.

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class PartyInventoryUI_Hooks_GetUpdate
---@field Items PartyInventoryItemUpdate[] Hookable.
---@field GoldAndCarryWeight PartyInventoryUI_GoldWeightUpdate[] Hookable.

---@class UI.PartyInventory.Hooks.GetInventoryUpdate
---@field Entries UI.PartyInventory.FlashEntries.InventoryUpdate[] Hookable.

---------------------------------------------
-- METHODS
---------------------------------------------

---Updates the data on the UI.
function Inv.Refresh()
    Ext.UI.SetDirty(Client.GetCharacter().Handle, "CharacterInventoryView")
end

---Returns whether a tab filter is active.
---@param tab UI.PartyInventory.FilterTab
---@return boolean
function Inv.IsTabFilterActive(tab)
    local list = Inv:GetRoot().inventory_mc.tabList
    local tabs = list.content_array
    local tabMC
    for i=0,#tabs-1,1 do
        if tabs[i].id == tab then
            tabMC = tabs[i]
            break
        end
    end
    if not tabMC then
        Inv:Error("IsTabFilterActive", "Tab not found", tab)
    end
    return tabMC.isSelected()
end

---@override
function Inv:Show()
    -- With extender's patches to item synching,
    -- showing the UI during certain load states crashes the game for non-hosts.
    if not GameState.IsLoading() then
        Client.UI._BaseUITable.Show(self)
    else
        Inv:__LogWarning("Attempted to show PartyInventory during a load state; this could cause crashes for non-hosts.")
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Inv:RegisterInvokeListener("updateItems", function(_)
    local root = Inv:GetRoot()
    local itemArray = root.itemsUpdateList
    local goldAndWeightArray = root.goldWeightList

    ---@type PartyInventoryItemUpdate[]
    local items = ParseFlashArray(itemArray, Inv.FLASH_ARRAY_TEMPLATES.UPDATE_ITEMS)
    ---@type PartyInventoryUI_GoldWeightUpdate[]
    local godlAndWeight = ParseFlashArray(goldAndWeightArray, Inv.FLASH_ARRAY_TEMPLATES.GOLD_AND_WEIGHT)

    ---@type PartyInventoryUI_Hooks_GetUpdate
    local ev = {
        Items = items,
        GoldAndCarryWeight = godlAndWeight,
    }

    -- TODO prevent action
    Inv.Hooks.GetUpdate:Throw(ev)

    EncodeFlashArray(itemArray, Inv.FLASH_ARRAY_TEMPLATES.UPDATE_ITEMS, ev.Items)
    EncodeFlashArray(goldAndWeightArray, Inv.FLASH_ARRAY_TEMPLATES.GOLD_AND_WEIGHT, ev.GoldAndCarryWeight)
end)

-- Listen for inventory definitions being updated to hook them.
Inv:RegisterInvokeListener("updateInventories", function (_)
    local root = Inv:GetRoot()
    local updateArray = root.inventoryUpdateList
    local entries = ParseFlashArray(updateArray, Inv.FLASH_ARRAY_TEMPLATES.UPDATE_INVENTORIES) ---@type UI.PartyInventory.FlashEntries.InventoryUpdate[]

    entries = Inv.Hooks.GetInventoryUpdate:Throw({
        Entries = entries,
    }).Entries

    EncodeFlashArray(updateArray, Inv.FLASH_ARRAY_TEMPLATES.UPDATE_INVENTORIES, entries)
end)
