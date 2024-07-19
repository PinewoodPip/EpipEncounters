
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local TooltipPanelPrefab = Generic.GetPrefab("GenericUI_Prefab_TooltipPanel")
local DraggingAreaPrefab = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local PooledContainer = Generic.GetPrefab("GenericUI.Prefabs.PooledContainer")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local Input = Client.Input
local CommonStrings = Text.CommonStrings
local Tooltip = Client.Tooltip
local Notification = Client.UI.Notification
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
UI.PICKUP_SOUND = "UI_Game_PartyFormation_PickUp"
UI.EVENTID_TICK_IS_MOVING = "Features.QuickLoot.UI.IsCharacterMoving"
UI.SETTINGS_PANEL_SIZE = V(500, 500)
UI.SETTINGS_PANEL_ELEMENT_SIZE = V(UI.SETTINGS_PANEL_SIZE[1] - 55, 50)
UI.SETTINGS_PANEL_SCROLLLIST_FRAME = UI.SETTINGS_PANEL_SIZE - V(20, 150)
UI.UIOBJECT_PANEL_EXTRA_WIDTH = 300 -- Extra width for panel size.

UI._State = nil ---@type Features.QuickLoot.UI.State?

UI.Hooks.GetSettings = UI:AddSubscribableHook("GetSettings") ---@type Hook<{Settings:SettingsLib_Setting[]}> Fired only once when the UI is first opened.

QuickLoot:RegisterInputAction("Search", {
    Name = TSK.InputAction_Search_Name,
    Description = TSK.InputAction_Search_Description,
})

---@class Features.QuickLoot.UI.State
---@field HandleMaps Features.QuickLoot.HandleMap
---@field ItemHandles ItemHandle[] Items currently in the UI.
---@field LowPriorityItemHandles set<ItemHandle> Items to show as greyed out.
---@field ItemHandleToSlot table<ItemHandle, GenericUI_Prefab_HotbarSlot>
---@field SearchRadius number

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI with a list of items.
---@param searchResult Features.QuickLoot.Events.SearchCompleted
function UI.Setup(searchResult)
    UI._Initialize()

    UI._UpdateItems(searchResult)

    -- Close the UI when the character begins to move.
    GameState.Events.RunningTick:Unsubscribe(UI.EVENTID_TICK_IS_MOVING)
    GameState.Events.RunningTick:Subscribe(function (_)
        local char = Client.GetCharacter()
        if Character.IsMoving(char) or not UI:IsVisible() then -- Also remove the listener after the UI closes.
            UI:TryHide()
            GameState.Events.RunningTick:Unsubscribe(UI.EVENTID_TICK_IS_MOVING)
        end
    end, {StringID = UI.EVENTID_TICK_IS_MOVING})

    UI:Show()
end

---Requests to loot an item.
---@param item EclItem|integer Item or slot index.
function UI.LootItem(item)
    local slotIndex
    if GetExtType(item) ~= nil then
        slotIndex = UI._GetItemIndex(item)
    else -- Index overload.
        slotIndex = item
        item = Item.Get(UI._State.ItemHandles[slotIndex])
    end

    QuickLoot.RequestPickUp(Client.GetCharacter(), item)
    UI:PlaySound(UI.PICKUP_SOUND) -- This sound is normally different per-item, however we cannot recreate that.

    UI.RemoveItem(item)

    -- Close the UI if all items have been looted.
    -- GetItems() is not used to avoid getter calls - though the performance gain is non-crucial.
    if #UI._State.ItemHandles == 0 then
        UI:Hide()
    end
end

---Refetches items and rerenders the item list based on the last search's radius.
function UI.Refresh()
    UI._UpdateItems(UI._State.SearchRadius)
end

---Requests to loot all items in the UI.
function UI.LootAll()
    local char = UI.GetCharacter()
    for _,item in ipairs(UI.GetItems()) do
        -- No need to update bookkeeping of the UI, as we can just empty/hide it right afterwards.
        QuickLoot.RequestPickUp(char, item)
    end
    UI:PlaySound(UI.PICKUP_SOUND) -- Play the sound only once so as not to stack it.
    UI:Hide()
end

---Returns the items currently in the UI.
---@return EclItem[]
function UI.GetItems()
    return Entity.HandleListToEntities(UI._State.ItemHandles, "EclItem")
end

---Returns whether an item is in the UI.
---@param item EclItem
---@return boolean
function UI.IsItemInUI(item)
    return table.reverseLookup(UI._State.ItemHandles, item.Handle) ~= nil
end

---Returns the slot element for an item already in the UI.
---@param item EclItem
---@return GenericUI_Prefab_HotbarSlot
function UI.GetItemSlot(item)
    return UI._State.ItemHandleToSlot[item.Handle]
end

---Returns the container or corpse that contains the item.
---@param item EclItem Must be currently within the UI.
---@return EclItem|EclCharacter
function UI.GetItemSource(item)
    local handleMap = UI._State.HandleMaps
    local containerHandle, corpseHandle = handleMap.ItemHandleToContainerHandle[item.Handle], handleMap.ItemHandleToCorpseHandle[item.Handle]
    return containerHandle and Item.Get(containerHandle) or Character.Get(corpseHandle)
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

---Renders an item onto the grid and tracks it.
---Should be called during or after Setup().
---@param item EclItem
---@param source EclItem|EclCharacter
---@param greyedOut boolean? Defaults to `false`.
function UI.AddItem(item, source, greyedOut)
    greyedOut = greyedOut or false
    local state = UI._State

    -- Update bookkeeping
    table.insert(state.ItemHandles, item.Handle)
    local handleMap = Entity.IsCharacter(source) and state.HandleMaps.ItemHandleToCorpseHandle or state.HandleMaps.ItemHandleToContainerHandle
    handleMap[item.Handle] = source.Handle
    state.LowPriorityItemHandles[item.Handle] = greyedOut or nil
end

---Removes an item from the UI.
---@param item EclItem|integer Item or slot index.
function UI.RemoveItem(item)
    local index = UI._GetItemIndex(item)
    local state = UI._State

    -- Hide the slot and reposition the grid elements.
    local slot = UI.GetItemSlot(item)
    slot:SetVisible(false)
    UI.ItemGrid.Container:RepositionElements() -- Done directly so as not to invoke PooledContainer's behaviour of stopping at the first invisible element.

    -- Update bookkeeping
    table.remove(state.ItemHandles, index)
    state.ItemHandleToSlot[item.Handle] = nil
    state.LowPriorityItemHandles[item.Handle] = nil
    state.HandleMaps.ItemHandleToContainerHandle[item.Handle] = nil
    state.HandleMaps.ItemHandleToCorpseHandle[item.Handle] = nil
end

---Re-fetches items and resets the state.
---@param search Features.QuickLoot.Events.SearchCompleted|number Search or radius.
function UI._UpdateItems(search)
    local items, handleMaps, radius
    if type(search) == "number" then -- Radius overload.
        radius = search
        items, handleMaps = QuickLoot.GetItems(UI.GetCharacter().WorldPos, radius)
    else
        items, handleMaps, radius = search.LootableItems, search.HandleMaps, search.Radius
    end
    local char = UI.GetCharacter()

    UI._State = {
        HandleMaps = handleMaps,
        ItemHandles = {},
        ItemHandleToSlot = {},
        LowPriorityItemHandles = {},
        SearchRadius = radius,
    }

    -- Add items and render the list
    for _,item in ipairs(items) do
        local sourceHandle = handleMaps.ItemHandleToContainerHandle[item.Handle] or handleMaps.ItemHandleToCorpseHandle[item.Handle]
        UI.AddItem(item, Entity.GetGameObjectComponent(sourceHandle), false)
    end
    -- Add filtered-out items in greyed-out mode.
    if QuickLoot.Settings.FilterMode:GetValue() == QuickLoot.SETTING_FILTERMODE_CHOICES.GREYED_OUT then
        local allItems, newMap = QuickLoot.GetItems(char.WorldPos, radius, false)
        for _,item in ipairs(allItems) do
            if not UI.IsItemInUI(item) then
                local sourceHandle = newMap.ItemHandleToContainerHandle[item.Handle] or newMap.ItemHandleToCorpseHandle[item.Handle]
                UI.AddItem(item, Entity.GetGameObjectComponent(sourceHandle), true)
            end
        end
    end

    UI._RenderItems()
end

---Re-renders the item list.
function UI._RenderItems()
    local grid = UI.ItemGrid
    grid:Clear()
    for _,item in ipairs(UI.GetItems()) do
        UI._RenderItem(item)
    end
    grid:RepositionElements()
    UI.ItemsViewport:RepositionElements() -- Necessary to update the scroll area.
end

---Renders an item onto the UI.
---@param item EclItem
function UI._RenderItem(item)
    local state = UI._State
    local itemIndex = table.reverseLookup(state.ItemHandles, item.Handle)
    local slot = UI.ItemGrid:GetItem(itemIndex) ---@type GenericUI_Prefab_HotbarSlot

    -- Setup slot
    slot:SetItem(item)
    slot:SetEnabled(not state.LowPriorityItemHandles[item.Handle])
    slot:SetCanDragDrop(false)
    slot:SetUsable(false)
    slot:SetUpdateDelay(-1)

    state.ItemHandleToSlot[item.Handle] = slot
end

---Returns the slot index of an item.
---@param item EclItem Must be in the UI.
---@return integer
function UI._GetItemIndex(item)
    local index, _ = table.getFirst(UI._State.ItemHandles, function (_, handle)
        return handle == item.Handle
    end)
    return index
end

---Initializes the static elements of the UI.
function UI._Initialize()
    if UI._Initialized then return end

    local uiObj = UI:GetUI()
    uiObj.SysPanelSize = {UI.BACKGROUND_SIZE[1] + UI.SETTINGS_PANEL_ELEMENT_SIZE[1] + UI.UIOBJECT_PANEL_EXTRA_WIDTH, UI.BACKGROUND_SIZE[2]} -- Padding makes the UI get positioned slightly to the left by default, so as not to obscure the character.
    uiObj.Left = UI.BACKGROUND_SIZE[1] -- Prevent dragging the main panel outside the viewport.

    local root = UI:CreateElement("Root", "GenericUI_Element_Empty")
    UI.Root = root

    local bg = TooltipPanelPrefab.Create(UI, "Background", root, UI.BACKGROUND_SIZE, Text.Format(TSK.Label_FeatureName:GetString(), {
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
    -- Show "Take all" binding in tooltip.
    -- Will not update if rebound mid-session - TODO?
    local takeAllBinding = Input.GetBinding("UITakeAll", "Key")
    lootAllButton:SetTooltip("Simple", CommonStrings.KeybindHint:Format(Input.StringifyBinding(takeAllBinding:ToKeyCombination())))
    UI.LootAllButton = lootAllButton

    local scrollList = bg:AddChild("Items", "GenericUI_Element_ScrollList")
    scrollList:SetFrame(UI.SCROLL_LIST_FRAME:unpack())
    scrollList:SetMouseWheelEnabled(true)
    scrollList:SetPosition(UI.BACKGROUND_SIZE[1]/2 - UI.GetItemListWidth()/2, 80)
    scrollList:SetScrollbarSpacing(-22)
    UI.ItemsViewport = scrollList

    local slotGrid = scrollList:AddChild("ItemGrid", "GenericUI_Element_Grid")
    slotGrid:SetRepositionAfterAdding(false)
    slotGrid:SetGridSize(UI.GetItemsPerRow(), -1)
    UI.ItemGrid = PooledContainer.Create(slotGrid, function (index)
        local slot = HotbarSlot.Create(UI, "ItemSlot." .. tostring(index), slotGrid, {TextLabel = true})
        slot.Label:SetStroke(Color.CreateFromDecimal(1050888), 1.4, 1, 1.8, 3) -- Taken from partyInventory cell.
        slot.Events.Clicked:Subscribe(function (_)
            UI.LootItem(slot.Object:GetEntity())
        end, {StringID = "PickUpItem"})
        -- Position tooltips to the right of the panel.
        slot.Hooks.GetTooltipData:Subscribe(function (ev)
            ev.Position = V(UI:GetPosition()) + V(UI.BACKGROUND_SIZE[1] - 15, 3)
        end)
        return slot
    end)

    UI._InitalizeSettingsPanel()

    -- Only set relative position the first time the UI is used in a session.
    UI:SetPositionRelativeToViewport("center", "center")

    -- Close the UI when pause key is pressed and bind "Take all" to loot all.
    UI:SetIggyEventCapture("ToggleInGameMenu", true)
    UI.Events.IggyEventDownCaptured:Subscribe(function (ev)
        local eventID = ev.EventID
        if eventID == "ToggleInGameMenu" then
            UI:Hide()
        end
    end)
    -- Bind "Take all" to loot all.
    -- Cannot be done via Iggy events as some vanilla UI takes priority.
    Input.Events.KeyPressed:Subscribe(function (_)
        local currentTakeAllBinding = Input.GetBinding("UITakeAll", "Key")
        if currentTakeAllBinding and Input.HasInputEventModifiersPressed(currentTakeAllBinding) and Input.IsKeyPressed(currentTakeAllBinding.InputID) then
            UI.LootAll()
        end
    end, {EnabledFunctor = function () return UI:IsVisible() end})

    UI._Initialized = true
end

---Initializes the settings panel.
function UI._InitalizeSettingsPanel()
    local settingsPanel = TooltipPanelPrefab.Create(UI, "Settings", UI.Root, UI.SETTINGS_PANEL_SIZE, Text.Format(Text.CommonStrings.Filters:GetString(), {Size = 23}), UI.HEADER_SIZE)
    settingsPanel.Background:SetPosition(UI.BACKGROUND_SIZE[1] - 15, 0)
    UI.SettingsPanel = settingsPanel

    local list = settingsPanel:AddChild("SettingsList", "GenericUI_Element_ScrollList")
    list:SetFrame(UI.SETTINGS_PANEL_SCROLLLIST_FRAME:unpack())
    list:SetRepositionAfterAdding(false)
    list:SetScrollbarSpacing(-50)
    list:SetMouseWheelEnabled(true)
    list:SetPosition(20, 80)
    UI.SettingsPanelList = list

    -- Render settings
    for _,setting in ipairs(UI.Hooks.GetSettings:Throw({Settings = {}}).Settings) do
        SettingWidgets.RenderSetting(UI, list, setting, UI.SETTINGS_PANEL_ELEMENT_SIZE, function (_)
            UI.Refresh()
            QuickLoot:SaveSettings()
        end)
    end
    list:RepositionElements()

    -- Settings button
    local settingsButton = ButtonPrefab.Create(UI, "SettingsButton", UI.Background:GetRootElement(), ButtonPrefab:GetStyle("SettingsRed"))
    settingsButton:SetPositionRelativeToParent("TopRight", -13, 13)
    -- Toggle panel visibility
    settingsButton.Events.Pressed:Subscribe(function (_)
        settingsPanel:SetVisible(not settingsPanel:IsVisible())
    end)

    -- Position setting tooltips to the right of the settings panel.
    Tooltip.Events.TooltipPositioned:Subscribe(function (_)
        local currentTooltip = Tooltip.GetCurrentTooltipSourceData()
        if currentTooltip and currentTooltip.Type == "Custom" and UI:IsVisible() then
            local setting = SettingWidgets.GetTooltipSetting(currentTooltip) -- Technically the tooltip could still come from another UI, but that's a hilarious edgecase
            if setting and setting.ModTable == QuickLoot:GetNamespace() then
                local pos = V(UI:GetPosition()) + V(UI:GetUI().SysPanelSize[1] - UI.UIOBJECT_PANEL_EXTRA_WIDTH + 20, -30) -- No idea why another horizontal offset is needed.
                Client.UI.Tooltip:SetPosition(pos)
            end
        end
    end)

    settingsPanel:SetVisible(false)
end

---@override
function UI:Hide()
    Tooltip.HideTooltip()
    Client.UI._BaseUITable.Hide(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open the UI when a search completes.
QuickLoot.Events.SearchCompleted:Subscribe(function (ev)
    local items = ev.LootableItems
    if #items == 0 then -- Do not open the UI if no items were found.
        Notification.ShowNotification(TSK.Notification_NoLootNearby:GetString())
    else
        UI.Setup(ev)
    end
end)

-- Show default settings.
UI.Hooks.GetSettings:Subscribe(function (ev)
    local settings = QuickLoot.Settings
    local defaultSettings = {
        settings.FilterMode,
        settings.MinEquipmentRarity,
        settings.ShowConsumables,
        settings.ShowFoodAndDrinks,
        settings.ShowIngredients,
        settings.ShowBooks,
        settings.ShowClutter,
    }
    for _,setting in ipairs(defaultSettings) do
        table.insert(ev.Settings, setting)
    end
end, {StringID = "DefaultImplementation"})

-- Append source container/corpse to item tooltips.
Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    if UI:IsVisible() then
        local source = UI.GetItemSource(ev.Item)
        if source then -- The tooltip might be from another UI, or the item might've been moved out by another character in the meantime.
            local entityName = Entity.IsItem(source) and Item.GetDisplayName(source) or Character.GetDisplayName(source)
            local hasCorpseKeyword = string.find(entityName, CommonStrings.Corpse:GetString(), nil, true)
            local tsk = (Entity.IsItem(source) or hasCorpseKeyword) and TSK.Label_SourceContainer or TSK.Label_SourceCorpse -- Avoid using "In {name}'s corpse" if the word "corpse" is already in the entity name.
            local label = tsk:Format({
                FormatArgs = {entityName},
                Color = Color.LARIAN.GREEN,
            })
            local element = ev.Tooltip:GetFirstElement("ItemDescription")
            local infix = "<br><br>"
            if not element then
                element = {Type = "ItemDescription", Label = ""}
                ev.Tooltip:InsertElement(element)
                infix = "" -- Don't append line breaks if there was no element before.
            end
            element.Label = string.format("%s%s%s", element.Label, infix, label)
        end
    end
end)

-- Close the UI when active character changes or a new search is started.
local function TryHide() UI:TryHide() end
Client.Events.ActiveCharacterChanged:Subscribe(TryHide)
QuickLoot.Events.SearchStarted:Subscribe(TryHide)
