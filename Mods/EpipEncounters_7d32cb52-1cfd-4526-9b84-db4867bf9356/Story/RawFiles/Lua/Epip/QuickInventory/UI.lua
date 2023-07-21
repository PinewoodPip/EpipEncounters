
local ContextMenu = Client.UI.ContextMenu
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local TooltipPanelPrefab = Generic.GetPrefab("GenericUI_Prefab_TooltipPanel")
local DraggingAreaPrefab = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local SettingWidgets = Epip.GetFeature("Features.SettingWidgets")
local Tooltip = Client.Tooltip
local Input = Client.Input
local V = Vector.Create

---@class Feature_QuickInventory
local QuickInventory = Epip.GetFeature("Feature_QuickInventory")
local UI = Generic.Create("Epip_EquipmentSwap")
UI._Initialized = false
UI._Lists = {} ---@type GenericUI_Element_HorizontalList[]
UI._Slots = DataStructures.Get("DataStructures_DefaultTable").Create({}) -- Pooling for HotbarSlots, since they are expensive to create.
UI._CurrentItemCount = 0
UI._IsCursorOverUI = false

UI.BACKGROUND_SIZE = V(420, 500) -- For main panel only.
UI.SETTINGS_PANEL_SIZE = V(480, 500)
UI.HEADER_SIZE = V(400, 50)
UI.SCROLLBAR_WIDTH = 10
UI.SCROLL_LIST_AREA = UI.BACKGROUND_SIZE - V(40 + UI.SCROLLBAR_WIDTH, 140)
UI.SCROLL_LIST_FRAME = UI.BACKGROUND_SIZE - V(40, 137)
UI.ITEM_SIZE = V(58, 58)
UI.ELEMENT_SPACING = 5
UI.SETTINGS_PANEL_ELEMENT_SIZE = V(UI.SETTINGS_PANEL_SIZE[1] - 42.5, 50)
UI.DRAGGABLE_AREA_SIZE = V(UI.BACKGROUND_SIZE[1] + UI.SETTINGS_PANEL_SIZE[1], 65)

---------------------------------------------
-- METHODS
---------------------------------------------

---Opens the UI.
function UI.Setup()
    UI._Initialize()

    UI.RenderItems()

    UI._RenderSettingsPanel()

    UI:SetPositionRelativeToViewport("center", "center")
    UI:Show()
end

---Re-renders items onto the UI.
function UI.RenderItems()
    QuickInventory:StartProfiling("RenderItems")

    -- Cleanup previous state.
    UI._CurrentItemCount = 0
    UI.ItemsList:GetMovieClip().list.m_scrollbar_mc.resetHandle()

    local items = QuickInventory.GetItems()
    QuickInventory:AddProfilingStep("GetItems")

    for _,item in ipairs(items) do
        UI._RenderItem(item)
        QuickInventory:AddProfilingStep("ItemRender")
    end

    for i=UI._CurrentItemCount+1,UI._GetTotalSlots(),1 do
        local slot = UI._GetHotbarSlot(i)

        slot.SlotElement:SetVisible(false)
    end
    QuickInventory:AddProfilingStep("SetVisibility")
    QuickInventory:EndProfiling()
end

---Returns the total amount of slot objects available.
---@return integer
function UI._GetTotalSlots()
    return #UI._Lists * UI.GetItemsPerRow()
end

---Refreshes the contents of the UI.
function UI.Refresh()
    UI.RenderItems()
    UI._RenderSettingsPanel()
end

---Closes the UI.
function UI.Close()
    Tooltip.HideTooltip()
    UI:Hide()
end

---Renders an item onto the list.
---@param item EclItem
function UI._RenderItem(item)
    local element = UI._GetHotbarSlot(UI._CurrentItemCount + 1)
    QuickInventory:AddProfilingStep("GetElement")
    local meetsRequirements = Stats.MeetsRequirements(Client.GetCharacter(), item.StatsId, true, item)
    QuickInventory:AddProfilingStep("MeetsRequirements")
    element:SetItem(item)
    element:SetUpdateDelay(-1)
    element:SetEnabled(meetsRequirements)
    element.SlotElement:SetVisible(true)
    QuickInventory:AddProfilingStep("UpdateElement")

    UI._CurrentItemCount = UI._CurrentItemCount + 1
end

---Returns a pooled HotbarSlot.
---@overload fun(globalItemIndex:integer):GenericUI_Prefab_HotbarSlot
---@param listIndex integer
---@param itemIndex integer
---@return GenericUI_Prefab_HotbarSlot
function UI._GetHotbarSlot(listIndex, itemIndex)
    local itemsPerRow = UI.GetItemsPerRow()
    if itemIndex == nil then
        local globalItemIndex = listIndex
        listIndex = ((globalItemIndex - 1) // itemsPerRow) + 1
        itemIndex = globalItemIndex - (listIndex - 1) * itemsPerRow
    end

    local hasAddedLists = false
    while listIndex > #UI._Lists do
        local newList = UI.ItemsList:AddChild("List_" .. #UI._Lists + 1, "GenericUI_Element_HorizontalList")
        newList:SetElementSpacing(UI.ELEMENT_SPACING)
        newList:SetRepositionAfterAdding(false)

        table.insert(UI._Lists, newList)
        local list = UI._Lists[#UI._Lists]
        list:SetSizeOverride(V(UI.ITEM_SIZE[1] * itemsPerRow + (itemsPerRow - 1) * UI.ELEMENT_SPACING, UI.ITEM_SIZE[2]))

        -- Insert hotbar slots to the new list
        for i=1,itemsPerRow,1 do
            local element = HotbarSlot.Create(UI, string.format("%s_%s", #UI._Lists, i), list)
            element:SetCanDrag(true, false) -- Can drag items out of the slot, without removing them from it.

            element.Events.Clicked:Subscribe(function (_)
                UI._OnSlotClicked(element)
            end)

            element.Hooks.GetTooltipData:Subscribe(function (ev)
                ev.Position = V(UI:GetPosition()) + V(UI.BACKGROUND_SIZE[1], 0)
            end)

            UI._Slots[#UI._Lists][i] = element

            element.SlotElement:SetSizeOverride(UI.ITEM_SIZE)
            QuickInventory:AddProfilingStep("Create Slot")
        end

        hasAddedLists = true
    end

    if hasAddedLists then
        for _,list in ipairs(UI._Lists) do
            list:RepositionElements()
        end
        UI.ItemsList:RepositionElements()
        QuickInventory:AddProfilingStep("RepositionElements")
    end

    return UI._Slots[listIndex][itemIndex]
end

---Creates the core elements of the UI.
function UI._Initialize()
    if not UI._Initialized then
        UI:GetUI().SysPanelSize = {UI.BACKGROUND_SIZE[1] + UI.SETTINGS_PANEL_SIZE[1], UI.BACKGROUND_SIZE[2]}

        local bg = TooltipPanelPrefab.Create(UI, "Background", nil, UI.BACKGROUND_SIZE, Text.Format(QuickInventory.TranslatedStrings.Header:GetString(), {
            Size = 23,
        }), UI.HEADER_SIZE)
        bg.Background.Events.MouseOver:Subscribe(function (_)
            UI._IsCursorOverUI = true
        end)
        bg.Background.Events.MouseOut:Subscribe(function (_)
            UI._IsCursorOverUI = false
        end)
        UI.Background = bg

        DraggingAreaPrefab.Create(UI, "DraggableArea", bg.Background, UI.DRAGGABLE_AREA_SIZE)

        local closeButton = CloseButtonPrefab.Create(UI, "CloseButton", bg.Background)
        closeButton:SetPositionRelativeToParent("TopLeft", 9, 9)

        local scrollList = bg:AddChild("Items", "GenericUI_Element_ScrollList")
        scrollList:SetFrame(UI.SCROLL_LIST_FRAME:unpack())
        scrollList:SetMouseWheelEnabled(true)
        scrollList:SetPosition(UI.BACKGROUND_SIZE[1]/2 - UI.GetItemListWidth()/2, 80)
        scrollList:SetScrollbarSpacing(-22)
        UI.ItemsList = scrollList
    end

    UI._Initialized = true
end

function UI._RenderSettingsPanel()
    -- Destroy previous settings panel
    if UI.SettingsPanel then
        UI.SettingsPanel:Destroy()
    end

    local settingsPanel = TooltipPanelPrefab.Create(UI, "Settings", UI.Background.Background, UI.SETTINGS_PANEL_SIZE, Text.Format(Text.CommonStrings.Settings:GetString(), {Size = 23}), UI.HEADER_SIZE)
    settingsPanel.Background:SetPosition(UI.BACKGROUND_SIZE[1] - 15, 0)
    UI.Background.Background:SetChildIndex(settingsPanel.Background.ID, 0)
    UI.SettingsPanel = settingsPanel

    local list = settingsPanel:AddChild("List", "GenericUI_Element_VerticalList")
    list:SetPosition(25, 80)
    UI.SettingsPanelList = list

    -- Item category
    UI.RenderSetting(QuickInventory.Settings.ItemCategory)

    local itemCategory = QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory)
    if itemCategory == "Equipment" then
        local itemSlot = QuickInventory:GetSettingValue(QuickInventory.Settings.ItemSlot)

        UI.RenderSetting(QuickInventory.Settings.ItemSlot) -- Equipment slot
        UI.RenderSetting(QuickInventory.Settings.Rarity) -- Rarity

        if itemSlot == "Weapon" then
            UI.RenderSetting(QuickInventory.Settings.WeaponSubType) -- Equipment subtype
        elseif QuickInventory.SLOTS_WITH_ARMOR_SUBTYPES:Contains(itemSlot) then
            UI.RenderSetting(QuickInventory.Settings.ArmorSubType) -- Armor subtype
        end

        if EpicEncounters.IsEnabled() then
            UI.RenderSetting(QuickInventory.Settings.CulledOnly)
        end

        UI.RenderSetting(QuickInventory.Settings.ShowEquippedItems)

        UI.RenderSetting(QuickInventory.Settings.DynamicStat)
    elseif itemCategory == "Skillbooks" then
        UI.RenderSetting(QuickInventory.Settings.LearntSkillbooks)
        UI.RenderSetting(QuickInventory.Settings.SkillbookSchool)
    elseif itemCategory == "Consumables" then
        UI.RenderSetting(QuickInventory.Settings.ConsumablesCategory)
    end
end

---Renders a widget to the settings panel from a setting.
---@param setting Features.SettingWidgets.SupportedSettingType
function UI.RenderSetting(setting)
    SettingWidgets.RenderSetting(UI, UI.SettingsPanelList, setting, UI.SETTINGS_PANEL_ELEMENT_SIZE, function (_)
        if setting.Type == "String" then -- Do not re-render the whole settings panel in this case, as it causes the focus to break.
            UI.RenderItems()
        else
            UI.Refresh()
        end
    end)
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

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---Handle slots being clicked.
---@param slot GenericUI_Prefab_HotbarSlot
function UI._OnSlotClicked(slot)
    local slottedItem = slot.Object:GetEntity()
    local shouldClose = QuickInventory:GetSettingValue(QuickInventory.Settings.CloseAfterUsing) == true

    -- Invert behaviour if shift is pressed
    if Input.IsShiftPressed() then
        shouldClose = not shouldClose
    end

    shouldClose = shouldClose and Stats.MeetsRequirements(Client.GetCharacter(), slottedItem.StatsId, true, slottedItem)

    if shouldClose then
        UI.Close()
    else -- Refresh UI after using an item. Needs a delay for the item to be consumed first.
        Timer.Start(0.3, function (_)
            UI.Refresh()
        end)
    end
end

-- Refresh the UI when the client character changes.
Client.Events.ActiveCharacterChanged:Subscribe(function (_)
    if UI:IsVisible() and UI._Initialized then -- TODO why does this error on load?
        UI.Refresh()
    end
end)

-- Close the UI when escape is pressed.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if ev.InputID == "escape" and UI:IsVisible() then
        UI.Close()
        ev:Prevent()
    end
end)

-- Listen for clicks that get sent to the world to optionally close the UI.
Input.Events.MouseButtonPressed:Subscribe(function (_)
    if UI:IsVisible() and QuickInventory:GetSettingValue(QuickInventory.Settings.CloseOnClickOutOfBounds) == true and not Client.IsCursorOverUI() then
        UI.Close()
    end
end)

-- Add option to equipment context menus.
ContextMenu.RegisterVanillaMenuHandler("Item", function(item)
    if Item.IsEquipment(item) and Item.IsEquipped(Client.GetCharacter(), item) then
        ContextMenu.AddElement({
            {id = "epip_Feature_QuickInventory", type = "button", text = QuickInventory.TranslatedStrings.ContextMenuButtonLabel:GetString()},
        })
    end
end)

-- Listen for context menu button being pressed.
ContextMenu.RegisterElementListener("epip_Feature_QuickInventory", "buttonPressed", function(item, _)
    item = item ---@type EclItem

    -- Set filters to show items valid for the slot
    QuickInventory:SetSettingValue(QuickInventory.Settings.ItemCategory, "Equipment")
    QuickInventory:SetSettingValue(QuickInventory.Settings.ItemSlot, tostring(Item.GetItemSlot(item)))
    QuickInventory:SetSettingValue(QuickInventory.Settings.WeaponSubType, "Any")
    QuickInventory:SetSettingValue(QuickInventory.Settings.DynamicStat, "")

    UI.Setup()
end)

-- Toggle the UI through a keybind.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == "EpipEncounters_QuickFind" then
        if UI:IsVisible() then
            UI.Close()
        else
            UI.Setup()
        end
    end
end)

-- Close the UI when an item is dragged into the Greatforge socket.
if EpicEncounters.IsEnabled() then
    local GreatforgeDragDrop = Epip.GetFeature("Feature_GreatforgeDragDrop")

    GreatforgeDragDrop.Events.ItemDropped:Subscribe(function (ev)
        if ev.Character == Client.GetCharacter() then -- Explicit character check in case the event is modified in the future to fire for all characters.
            UI.Close()
        end
    end)
end