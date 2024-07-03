
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local TooltipPanelPrefab = Generic.GetPrefab("GenericUI_Prefab_TooltipPanel")
local DraggingAreaPrefab = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local PooledContainer = Generic.GetPrefab("GenericUI.Prefabs.PooledContainer")
local Notification = Client.UI.Notification
local Input = Client.Input
local V = Vector.Create

---@class Features.QuickLoot
local QuickLoot = Epip.GetFeature("Features.QuickLoot")
local TSK = QuickLoot.TranslatedStrings
local UI = Generic.Create("Features.QuickLoot") ---@class Features.QuickLoot.UI : GenericUI_Instance
QuickLoot.UI = UI
UI.BACKGROUND_SIZE = V(420, 500) -- For main panel only.
UI.HEADER_SIZE = V(400, 50)
UI.DRAGGABLE_AREA_SIZE = UI.BACKGROUND_SIZE
UI.SCROLLBAR_WIDTH = 10
UI.SCROLL_LIST_AREA = UI.BACKGROUND_SIZE - V(40 + UI.SCROLLBAR_WIDTH, 140)
UI.SCROLL_LIST_FRAME = UI.BACKGROUND_SIZE - V(40, 137)
UI.ITEM_SIZE = V(58, 58)
UI.ELEMENT_SPACING = 5

QuickLoot:RegisterInputAction("Search", {
    Name = TSK.InputAction_Search_Name,
    Description = TSK.InputAction_Search_Description,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI with a list of items.
---@param items EclItem[]
function UI.Setup(items)
    UI._Initialize()

    UI._CurrentItemHandles = {}
    UI._ItemHandleToSlot = {}
    UI._ItemsCount = 0

    -- Render items
    UI.ItemGrid:Clear()
    for _,item in ipairs(items) do
        UI._RenderItem(item)
    end
    UI.ItemGrid:RepositionElements()

    UI:Show()
end

---Requests to loot an item.
---@param item EclItem|integer Item or slot index.
function UI.LootItem(item)
    local slotIndex
    if GetExtType(item) ~= nil then
        slotIndex = table.getFirst(UI._CurrentItemHandles, function (_, v)
            return v == item.Handle
        end)
    else -- Index overload.
        slotIndex = item
        item = Item.Get(UI._CurrentItemHandles[slotIndex])
    end

    QuickLoot.RequestPickUp(Client.GetCharacter(), item)

    table.remove(UI._CurrentItemHandles, slotIndex)

    -- Hide the slot and reposition the grid elements.
    local slot = UI.GetItemSlot(item)
    slot:SetVisible(false)
    UI.ItemGrid.Container:RepositionElements() -- Done directly so as not to invoke PooledContainer's behaviour of stopping at the first invisible element.
end

---Requests to loot all items in the UI.
function UI.LootAll()
    local char = UI.GetCharacter()
    for _,handle in ipairs(UI._CurrentItemHandles) do
        -- No need to update bookkeeping of the UI, as we can just empty/hide it right afterwards.
        QuickLoot.RequestPickUp(char, Item.Get(handle))
    end
    UI:Hide()
end

---Returns the slot element for an item already in the UI.
---@param item EclItem
---@return GenericUI_Prefab_HotbarSlot
function UI.GetItemSlot(item)
    return UI._ItemHandleToSlot[item.Handle]
end

---Returns the amount of items that fit per row.
---@return integer
function UI.GetItemsPerRow()
    return UI.SCROLL_LIST_AREA[1] // UI.ITEM_SIZE[1]
end

---Returns the width of the the item list, with all columns filled.
---@return number
function UI.GetItemListWidth()
    local items = UI.GetItemsPerRow()
    return items * UI.ITEM_SIZE[1] + UI.SCROLLBAR_WIDTH + (items - 1) * UI.ELEMENT_SPACING
end

---Returns the character using the UI.
---@return EclCharacter
function UI.GetCharacter()
    return Client.GetCharacter()
end

---Renders an item onto the grid.
---@param item EclItem
function UI._RenderItem(item)
    local itemIndex = UI._ItemsCount + 1
    local slot = UI.ItemGrid:GetItem(itemIndex) ---@type GenericUI_Prefab_HotbarSlot
    UI._ItemHandleToSlot[item.Handle] = slot
    UI._CurrentItemHandles[itemIndex] = item.Handle
    UI._ItemsCount = itemIndex
    slot:SetItem(item)
    slot:SetEnabled(true)
    slot:SetCanDragDrop(false)
    slot:SetUsable(false)
    slot:SetUpdateDelay(-1)
end

---Initializes the static elements of the UI.
function UI._Initialize()
    if UI._Initialized then return end

    UI:GetUI().SysPanelSize = {UI.BACKGROUND_SIZE[1], UI.BACKGROUND_SIZE[2]}

    local bg = TooltipPanelPrefab.Create(UI, "Background", nil, UI.BACKGROUND_SIZE, Text.Format(TSK.Label_FeatureName:GetString(), {
        Size = 23,
    }), UI.HEADER_SIZE)
    UI.Background = bg

    DraggingAreaPrefab.Create(UI, "DraggableArea", bg.Background, UI.DRAGGABLE_AREA_SIZE)

    local closeButton = CloseButtonPrefab.Create(UI, "CloseButton", bg.Background)
    closeButton:SetPositionRelativeToParent("TopLeft", 9, 9)

    local lootAllButton = ButtonPrefab.Create(UI, "LootAllButton", bg.Background, ButtonPrefab:GetStyle("GreenSmallTextured"))
    lootAllButton:SetLabel(TSK.Label_LootAll)
    lootAllButton:SetPositionRelativeToParent("Bottom", 0, -13)
    lootAllButton.Events.Pressed:Subscribe(function (_)
        UI.LootAll()
    end)
    UI.LootAllButton = lootAllButton

    local scrollList = bg:AddChild("Items", "GenericUI_Element_ScrollList")
    scrollList:SetFrame(UI.SCROLL_LIST_FRAME:unpack())
    scrollList:SetMouseWheelEnabled(true)
    scrollList:SetPosition(UI.BACKGROUND_SIZE[1]/2 - UI.GetItemListWidth()/2, 80)
    scrollList:SetScrollbarSpacing(-22)
    UI.ItemsList = scrollList

    local slotGrid = scrollList:AddChild("ItemGrid", "GenericUI_Element_Grid")
    slotGrid:SetRepositionAfterAdding(false)
    slotGrid:SetGridSize(UI.GetItemsPerRow(), -1)
    UI.ItemGrid = PooledContainer.Create(slotGrid, function (index)
        local slot = HotbarSlot.Create(UI, "ItemSlot." .. tostring(index), slotGrid)
        slot.Events.Clicked:Subscribe(function (_)
            UI.LootItem(slot.Object:GetEntity())
        end, {StringID = "PickUpItem"})
        return slot
    end)

    -- Only set relative position the first time the UI is used in a session.
    UI:SetPositionRelativeToViewport("center", "center")

    UI._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Start & stop searches when the action is pressed & released.
Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == QuickLoot.InputActions.Search.ID then
        QuickLoot.StartSearch(Client.GetCharacter())
        Notification.ShowWarning(TSK.Notification_Searching:GetString(), 0.5)
    end
end)
Input.Events.ActionReleased:Subscribe(function (ev)
    if ev.Action.ID == QuickLoot.InputActions.Search.ID then
        local char = Client.GetCharacter()
        local radius = QuickLoot.StopSearch(char)
        local items = QuickLoot.GetItems(V(char.WorldPos), radius)
        if #items == 0 then -- Do not open the UI if no items were found.
            Notification.ShowNotification(TSK.Notification_NoLootNearby:GetString())
        else
            UI.Setup(items)
        end
    end
end)
