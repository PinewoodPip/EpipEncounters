
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local TooltipPanelPrefab = Generic.GetPrefab("GenericUI_Prefab_TooltipPanel")
local DraggingAreaPrefab = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local PooledContainer = Generic.GetPrefab("GenericUI.Prefabs.PooledContainer")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local UILayout = Epip.GetFeature("Features.UILayout")
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

---@class Features.QuickLoot.UI.Events : GenericUI.Instance.Events
UI.Events = UI.Events
UI.Events.Initialized = UI:AddSubscribableEvent("Initialized") ---@type Event<Empty>
UI.Events.Opened = UI:AddSubscribableEvent("Opened") ---@type Event<Empty>
UI.Hooks.GetLootAllItems = UI:AddSubscribableHook("GetLootAllItems") ---@type Hook<Features.QuickLoot.UI.Hooks.GetLootAllItems>

UI._State = nil ---@type Features.QuickLoot.UI.State?
UI._LootallRequestRemainingWeight = nil ---@type integer? Necessary to prevent overencumbrance, as looting operations are asynchronous and thus character inventory weight doesn't update right after a request.
UI._HighlightedEntityHandle = nil ---@type ItemHandle? The entity currently highlighted in the world to denote a selected item in the UI. In the case of items in containers/corpses, this will be the container/corpse. 

UI.Hooks.GetSettings = UI:AddSubscribableHook("GetSettings") ---@type Hook<{Settings:SettingsLib_Setting[]}> Fired only once when the UI is first opened.

QuickLoot:RegisterInputAction("Search", {
    Name = TSK.InputAction_Search_Name,
    Description = TSK.InputAction_Search_Description,
})
UILayout.RegisterTrackedUI(UI) -- Persist UI position.

---@class Features.QuickLoot.UI.State
---@field HandleMaps Features.QuickLoot.HandleMap
---@field ItemHandles ItemHandle[] Items currently in the UI.
---@field LowPriorityItemHandles set<ItemHandle> Items to show as greyed out.
---@field ItemHandleToSlot table<ItemHandle, GenericUI_Prefab_HotbarSlot>
---@field SearchRadius number
---@field IsStealing boolean

---Thrown when the "Loot all" functionality is used.
---@class Features.QuickLoot.UI.Hooks.GetLootAllItems
---@field Items EclItem[] Defaults to all items in the UI.

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
    UI.Events.Opened:Throw()
end

---Requests to loot an item.
---@param item EclItem|integer Item or slot index.
---@param asWares boolean? If `true`, the item will also be added to wares.
function UI.LootItem(item, asWares)
    local slotIndex
    if GetExtType(item) ~= nil then
        slotIndex = UI._GetItemIndex(item)
    else -- Index overload.
        slotIndex = item
        item = Item.Get(UI._State.ItemHandles[slotIndex])
    end

    QuickLoot.RequestPickUp(Client.GetCharacter(), item, asWares)
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
---@param asWares boolean? If `true`, all items will be added to wares.
function UI.LootAll(asWares)
    local char = UI.GetCharacter()
    local lootedAny = false
    local lootedAll = true
    local itemsToLoot = UI.GetLootAllItems() -- Items may be excluded from loot-all.
    UI._LootallRequestRemainingWeight = Character.GetMaxCarryWeight(char) - Character.GetCarryWeight(char)
    for _,item in ipairs(itemsToLoot) do
        -- No need to update bookkeeping of the UI, as we can just empty/hide it right afterwards.
        local looted = QuickLoot.RequestPickUp(char, item, asWares)
        if looted then
            UI._LootallRequestRemainingWeight = UI._LootallRequestRemainingWeight - Item.GetWeight(item, true)
        end
        lootedAll = lootedAll and looted
        lootedAny = lootedAny or looted
    end

    -- Show warning if not all items were looted
    if not lootedAll then
        Notification.ShowWarning(TSK.Notification_DidNotLootAll:GetString())
    end

    -- Play looting sound - only once, so as not to stack it.
    if lootedAny then
        UI:PlaySound(UI.PICKUP_SOUND)
    end

    UI:Hide()

    UI._LootallRequestRemainingWeight = nil
end

---Returns the items currently in the UI.
---@return EclItem[]
function UI.GetItems()
    return Entity.HandleListToEntities(UI._State.ItemHandles, "EclItem")
end

---Returns the items that are valid to be looted via the "Loot all" button.
---@see Features.QuickLoot.UI.Hooks.GetLootAllItems
---@return EclItem[]
function UI.GetLootAllItems()
    local items = UI.GetItems()
    items = UI.Hooks.GetLootAllItems:Throw({Items = items}).Items
    return items
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
---@return (EclItem|EclCharacter)? -- `nil` if the item is on the ground.
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
---@param source (EclItem|EclCharacter)? Use `nil` for items on the ground.
---@param greyedOut boolean? Defaults to `false`.
function UI.AddItem(item, source, greyedOut)
    greyedOut = greyedOut or false
    local state = UI._State

    -- Update bookkeeping
    table.insert(state.ItemHandles, item.Handle)
    if source then
        local handleMap = Entity.IsCharacter(source) and state.HandleMaps.ItemHandleToCorpseHandle or state.HandleMaps.ItemHandleToContainerHandle
        handleMap[item.Handle] = source.Handle
    end
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

---Returns whether a tracked item is on the ground.
---@param item EclItem
---@return boolean
function UI.IsGroundItem(item)
    local handleMap = UI._State.HandleMaps
    return handleMap.GroundItems[item.Handle]
end

---Returns whether an item in the UI would be stolen when looted.
---Items from corpses are never considered stolen (dead owner = legal).
---@param item EclItem Must be in the UI.
---@return boolean
function UI._IsItemStolen(item)
    local handleMap = UI._State.HandleMaps
    local containerHandle = handleMap.ItemHandleToContainerHandle[item.Handle]
    if containerHandle then
        local container = Item.Get(containerHandle)
        return not Item.IsLegal(container)
    elseif handleMap.ItemHandleToCorpseHandle[item.Handle] then
        return false -- Corpse loot is always legal.
    else
        return not Item.IsLegal(item) -- Ground item.
    end
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
        IsStealing = UI._State and UI._State.IsStealing or QuickLoot._IsStealSearchActive, -- Keep the steal flag if we're updating items while the UI was already open.
    }

    -- Add items and render the list
    for _,item in ipairs(items) do
        local sourceHandle = handleMaps.ItemHandleToContainerHandle[item.Handle] or handleMaps.ItemHandleToCorpseHandle[item.Handle]
        UI.AddItem(item, sourceHandle and Entity.GetGameObjectComponent(sourceHandle) or nil, false)
    end
    -- Add filtered-out items in greyed-out mode.
    if QuickLoot.Settings.FilterMode:GetValue() == QuickLoot.SETTING_FILTERMODE_CHOICES.GREYED_OUT then
        local allItems, newMap = QuickLoot.GetItems(char.WorldPos, radius, false)
        for _,item in ipairs(allItems) do
            if not UI.IsItemInUI(item) then
                local itemHandle = item.Handle
                local sourceHandle = newMap.ItemHandleToContainerHandle[itemHandle] or newMap.ItemHandleToCorpseHandle[itemHandle]
                local isGroundItem = sourceHandle == nil

                -- Only include filtered-out ground items if the setting is enabled; without this check they would always show, as the GetItems() call above ignores this filter as well.
                if not isGroundItem or QuickLoot.Settings.ShowGroundItems:GetValue() == true then
                    UI.AddItem(item, sourceHandle and Entity.GetGameObjectComponent(sourceHandle) or nil, true)
                    if isGroundItem then
                        UI._State.HandleMaps.GroundItems[itemHandle] = true
                    end
                end
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

    -- Toggle steal overlay
    local showStealOverlay = QuickLoot._IsStealSearchActive and UI._IsItemStolen(item)
    slot._StealOverlay:SetVisible(showStealOverlay)

    state.ItemHandleToSlot[item.Handle] = slot
end

---Sets an item's source to be highlighted in the world with an outline.
---Will clear the outline of the previously-highlighted item.
---@param selectedItem EclItem? `nil` to clear highlight.
function UI._SetHighlightedItem(selectedItem)
    local sourceEntity = selectedItem and UI.GetItemSource(selectedItem) or selectedItem
    local previousHandle = UI._HighlightedEntityHandle

    -- Clear previous highlight
    if previousHandle then
        local previousEntity = Entity.GetGameObjectComponent(previousHandle)
        if previousEntity then
            Entity.SetHighlight(previousHandle, Entity.HIGHLIGHT_TYPES.NONE)
        end
    end

    -- Set new highlight; use red (ENEMY) outline for stolen items.
    if sourceEntity then
        local highlightType = Entity.HIGHLIGHT_TYPES.SELECTED
        if QuickLoot._IsStealSearchActive and selectedItem and UI._IsItemStolen(selectedItem) then
            highlightType = Entity.HIGHLIGHT_TYPES.ENEMY
        end
        Entity.SetHighlight(sourceEntity.Handle, highlightType)
    end

    -- Update bookkeeping
    UI._HighlightedEntityHandle = sourceEntity and sourceEntity.Handle or nil
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
    if Client.IsUsingController() then
        uiObj.OF_PlayerModal1 = true -- Necessary to prevent character movement from using the left-stick, which would also close the UI.
    end

    local root = UI:CreateElement("Root", "GenericUI_Element_Empty")
    UI.Root = root

    local bg = TooltipPanelPrefab.Create(UI, "Background", root, UI.BACKGROUND_SIZE, Text.Format(TSK.Label_FeatureName:GetString(), {
        Size = 23,
    }), UI.HEADER_SIZE)
    UI.Background = bg

    DraggingAreaPrefab.Create(UI, "DraggableArea", bg.Background, UI.DRAGGABLE_AREA_SIZE)

    local closeButton = CloseButtonPrefab.Create(UI, "CloseButton", bg.Background)
    closeButton:SetPositionRelativeToParent("TopLeft", 9, 9)

    local lootAllButton = ButtonPrefab.Create(UI, "LootAllButton", bg.Background, ButtonPrefab.STYLES.GreenSmallTextured)
    lootAllButton:SetLabel(TSK.Label_LootAll)
    lootAllButton:SetPositionRelativeToParent("Bottom", 0, -13)
    lootAllButton.Events.Pressed:Subscribe(function (_)
        UI.LootAll()
    end)
    lootAllButton.Events.RightClicked:Subscribe(function (_)
        UI.LootAll(true) -- Loot all as wares.
    end)
    -- Show "Take all" binding in tooltip.
    -- Will not update if rebound mid-session - TODO?
    local takeAllBinding = Input.GetBinding("UITakeAll", "Key")
    local keybindLabel = takeAllBinding and CommonStrings.KeybindHint:Format(Input.StringifyBinding(takeAllBinding:ToKeyCombination())) or ""
    lootAllButton:SetTooltip("Simple", TSK.Tooltip_LootAll:Format(keybindLabel))
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
        slot:GetRootElement().Events.RightClick:Subscribe(function (_)
            UI.LootItem(slot.Object:GetEntity(), true) -- Right-click loots as wares.
        end)
        -- Position tooltips to the right of the panel.
        slot.Hooks.GetTooltipData:Subscribe(function (ev)
            ev.Position = V(UI:GetPosition()) + V(UI.BACKGROUND_SIZE[1] - 15, 3)
        end)
        -- Create red overlay for stolen items.
        local overlay = slot:CreateElement("StealOverlay", "GenericUI_Element_Color", slot.SlotElement)
        overlay:SetColor(Color.CreateFromHex(Color.LARIAN.RED))
        overlay:SetSize(HotbarSlot.ICON_SIZE:unpack())
        overlay:SetPosition(1, 1)
        overlay:SetAlpha(0.3, true)
        overlay:SetVisible(false)
        slot._StealOverlay = overlay
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

    -- Attempt to restore the UI's position when it is initialized.
    UILayout.RestorePosition(UI, UI.BACKGROUND_SIZE) -- Use only the main panel size for determining overflow, since the SysPanel size is padded to offset centering via the setPosition UICall.

    UI._Initialized = true
    UI.Events.Initialized:Throw()
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
    local settingsButton = ButtonPrefab.Create(UI, "SettingsButton", UI.Background:GetRootElement(), ButtonPrefab.STYLES.SettingsRed)
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
    QuickLoot._IsStealSearchActive = false
    UI._State = nil
    Tooltip.HideTooltip()
    if UI._Initialized then
        UI.SettingsPanel:SetVisible(false) -- Make the settings panel default to closed when opening the UI.
    end
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

-- Close the UI if the client character died.
Character.Events.CharacterDied:Subscribe(function (ev)
    if ev.Character == Client.GetCharacter() then
        UI:Hide()
    end
end, {EnabledFunctor = function () return UI:IsVisible() end})

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
        settings.ShowGroundItems,
    }
    for _,setting in ipairs(defaultSettings) do
        table.insert(ev.Settings, setting)
    end
end, {StringID = "DefaultImplementation"})

-- Exclude greyed/filtered-out items from the "Loot all" functionality.
UI.Hooks.GetLootAllItems:Subscribe(function (ev)
    ev.Items = table.filter(ev.Items, function (item)
        return not UI._State.LowPriorityItemHandles[item.Handle]
    end)
end, {StringID = "DefaultImplementation"})

-- Append source container/corpse to item tooltips, as well as warnings for items that cannot be picked up.
Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    if UI:IsVisible() then
        local element = ev.Tooltip:GetFirstElement("ItemDescription")
        local hadElement = element ~= nil
        local infix = element == nil and "" or "<br><br>" -- Don't append line breaks if there was no element before.
        local sourceLabel = nil ---@type string?

        -- Check item source
        -- The tooltip might be from another UI, or the item might've been moved out by another character in the meantime.
        local source = UI.GetItemSource(ev.Item)
        if source then
            local entityName = Entity.IsItem(source) and Item.GetDisplayName(source) or Character.GetDisplayName(source)
            local hasCorpseKeyword = string.find(entityName, CommonStrings.Corpse:GetString(), nil, true)
            local tsk = (Entity.IsItem(source) or hasCorpseKeyword) and TSK.Label_SourceContainer or TSK.Label_SourceCorpse -- Avoid using "In {name}'s corpse" if the word "corpse" is already in the entity name.
            sourceLabel = tsk:Format({
                FormatArgs = {entityName},
                Color = Color.LARIAN.GREEN,
            })
        elseif UI.IsGroundItem(ev.Item) then
            sourceLabel = TSK.Label_OnGround:Format({
                Color = Color.LARIAN.GREEN,
            })
        end

        -- Append source label.
        local labels = {} ---@type string[]
        -- Add "Steal" indicator for stolen items.
        if QuickLoot._IsStealSearchActive and UI.IsItemInUI(ev.Item) and UI._IsItemStolen(ev.Item) then
            table.insert(labels, TSK.Label_Steal:Format({
                Color = Color.LARIAN.RED,
            }))
        end
        if sourceLabel then
            table.insert(labels, sourceLabel)
        end

        -- Append hint on looting controls
        -- TODO make these different for controller
        table.insert(labels, TSK.Label_LootingHint:GetString())

        -- Append overencumbrance warning.
        if Character.ItemWouldOverencumber(Client.GetCharacter(), ev.Item) then
            table.insert(labels, TSK.Label_CannotPickup_TooHeavy:Format({
                Color = Color.LARIAN.ORANGE,
            }))
        end

        -- Update or insert the element
        element = element or {Type = "ItemDescription", Label = ""}
        element.Label = string.format("%s%s%s", element.Label, infix, Text.Join(labels, "<br>"))
        if not hadElement and labels[1] then
            ev.Tooltip:InsertElement(element)
        end
    end
end)

-- Highlight source containers/corpses when items are selected in the UI.
Tooltip.Hooks.RenderItemTooltip:Subscribe(function (ev)
    -- Check whether the item is in Quick Loot
    -- The tooltip might be from another UI, or the item might've been moved out by another character in the meantime.
    local isInUI = UI.IsItemInUI(ev.Item)
    if isInUI then
        UI._SetHighlightedItem(ev.Item)
    end
end, {EnabledFunctor = function ()
    return UI:IsVisible()
end})
-- Clear highlights when items are deselected.
Tooltip.Events.TooltipHidden:Subscribe(function (_)
    UI._SetHighlightedItem(nil)
end, {EnabledFunctor = function ()
    return UI:IsVisible()
end})

-- Do not allow looting more items if they were to overencumber the character considering the current request.
QuickLoot.Hooks.CanPickupItem:Subscribe(function (ev)
    if not ev.CanPickup or UI._LootallRequestRemainingWeight == nil then return end
    ev.CanPickup = UI._LootallRequestRemainingWeight >= Item.GetWeight(ev.Item, true)
end)

-- Close the UI when active character changes or a new search is started.
local function TryHide() UI:TryHide() end
Client.Events.ActiveCharacterChanged:Subscribe(TryHide)
QuickLoot.Events.SearchStarted:Subscribe(TryHide)

-- Close the UI when the player enters dialogue (e.g. from a crime accusation or NPC conversation).
Client.Events.InDialogueStateChanged:Subscribe(function (ev)
    if ev.InDialogue then
        UI:TryHide()
    end
end, {EnabledFunctor = function () return UI:IsVisible() end})

-- Close the UI when the player unsneaks while using the UI in steal mode.
Client.Events.SneakingStateChanged:Subscribe(function (ev)
    if not ev.IsSneaking and UI._State.IsStealing then
        UI:TryHide()
    end
end, {EnabledFunctor = function () return UI:IsVisible() end})
