
local ContextMenu = Client.UI.ContextMenu
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local TooltipPanelPrefab = Generic.GetPrefab("GenericUI_Prefab_TooltipPanel")
local LabelledDropdownPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledDropdown")
local LabelledCheckboxPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledCheckbox")
local LabelledTextField = Generic.GetPrefab("GenericUI_Prefab_LabelledTextField")
local DraggingAreaPrefab = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
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
    -- Cleanup previous state.
    UI._CurrentItemCount = 0
    UI.ItemsList:GetMovieClip().list.m_scrollbar_mc.resetHandle()

    local items = QuickInventory.GetItems()

    for _,item in ipairs(items) do
        UI._RenderItem(item)
    end

    for i=UI._CurrentItemCount+1,UI._GetTotalSlots(),1 do
        local slot = UI._GetHotbarSlot(i)

        slot.SlotElement:SetVisible(false)
    end
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
    local meetsRequirements = Stats.MeetsRequirements(Client.GetCharacter(), item.StatsId, true, item)
    element:SetItem(item)
    element:SetUpdateDelay(-1)
    element:SetEnabled(meetsRequirements)
    element.SlotElement:SetVisible(true)

    UI._CurrentItemCount = UI._CurrentItemCount + 1
end

---Returns a pooled HotbarSlot.
---@overload fun(globalItemIndex:integer):GenericUI_Prefab_HotbarSlot
---@param listIndex integer
---@param itemIndex integer
---@return GenericUI_Prefab_HotbarSlot
function UI._GetHotbarSlot(listIndex, itemIndex)
    if itemIndex == nil then
        local globalItemIndex = listIndex
        listIndex = ((globalItemIndex - 1) // UI.GetItemsPerRow()) + 1
        itemIndex = globalItemIndex - (listIndex - 1) * UI.GetItemsPerRow()
    end

    local hasAddedLists = false
    while listIndex > #UI._Lists do
        local newList = UI.ItemsList:AddChild("List_" .. #UI._Lists + 1, "GenericUI_Element_HorizontalList")
        newList:SetElementSpacing(UI.ELEMENT_SPACING)
        newList:SetRepositionAfterAdding(false)

        table.insert(UI._Lists, newList)
        local list = UI._Lists[#UI._Lists]
        list:SetSizeOverride(V(UI.ITEM_SIZE[1] * UI.GetItemsPerRow() + (UI.GetItemsPerRow() - 1) * UI.ELEMENT_SPACING, UI.ITEM_SIZE[2]))

        -- Insert hotbar slots to the new list
        for i=1,UI.GetItemsPerRow(),1 do
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
        end

        hasAddedLists = true
    end

    if hasAddedLists then
        for _,list in ipairs(UI._Lists) do
            list:RepositionElements()
        end
        UI.ItemsList:RepositionElements()
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

        local closeButton = bg:AddChild("CloseButton", "GenericUI_Element_Button")
        closeButton:SetType("Close")
        closeButton:SetPositionRelativeToParent("TopLeft", 9, 9)
        closeButton.Events.Pressed:Subscribe(function (_)
            UI:Hide()
        end)

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
---@param setting SettingsLib_Setting_Choice|SettingsLib_Setting_Boolean
function UI.RenderSetting(setting)
    if setting.Type == "Boolean" then
        UI._RenderCheckboxFromSetting(setting)
    elseif setting.Type == "Choice" then
        UI._RenderComboBoxFromSetting(setting)
    elseif setting.Type == "String" then
        UI._RenderTextFieldFromSetting(setting)
    end
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

---Renders a checkbox to the settings panel from a setting.
---@param setting SettingsLib_Setting_Choice
function UI._RenderComboBoxFromSetting(setting)
    local list = UI.SettingsPanelList

    -- Generate combobox options from setting choices.
    local options = {}
    for _,choice in ipairs(setting.Choices) do
        table.insert(options, {
            ID = choice.ID,
            Label = choice:GetName(),
        })
    end

    local dropdown = LabelledDropdownPrefab.Create(UI, setting.ID, list, setting:GetName(), options)
    dropdown:SetSize(UI.SETTINGS_PANEL_ELEMENT_SIZE:unpack())
    dropdown:SelectOption(setting:GetValue())

    -- Set setting value and refresh UI.
    dropdown.Events.OptionSelected:Subscribe(function (ev)
        QuickInventory:SetSettingValue(setting, ev.Option.ID)
        UI.Refresh()
    end)
end

---Renders a combobox to the settings panel from a setting.
---@param setting SettingsLib_Setting_Boolean
function UI._RenderCheckboxFromSetting(setting)
    local list = UI.SettingsPanelList

    local checkbox = LabelledCheckboxPrefab.Create(UI, setting.ID, list, setting:GetName())
    checkbox:SetSize(UI.SETTINGS_PANEL_ELEMENT_SIZE:unpack())
    checkbox:SetState(setting:GetValue())

    -- Set setting value and refresh UI.
    checkbox.Events.StateChanged:Subscribe(function (ev)
        QuickInventory:SetSettingValue(setting, ev.Active)
        UI.Refresh()
    end)
end

---Renders an editable text field to the settings panel from a setting.
---@param setting SettingsLib_Setting_String
function UI._RenderTextFieldFromSetting(setting)
    local list = UI.SettingsPanelList
    local timerID = "Epip_QuickInventory_UI_" .. setting.ID

    local field = LabelledTextField.Create(UI, setting.ID, list, setting:GetName())
    field:SetText(setting:GetValue())
    field:SetSize(UI.SETTINGS_PANEL_ELEMENT_SIZE:unpack())

    -- Set setting value and refresh UI - this uses a delay to reduce lag from needless updates.
    field.Events.TextEdited:Subscribe(function (ev)
        local existingTimer = Timer.GetTimer(timerID)
        if existingTimer then
            existingTimer:Cancel()
        end

        Timer.Start(timerID, 0.6, function (_)
            QuickInventory:SetSettingValue(setting, ev.Text)
            UI.RenderItems()
        end)
    end)
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

-- Close the UI when escape is pressed, or when a mouse press occurs outside the UI.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if ev.InputID == "escape" and UI:IsVisible() then
        UI.Close()
        ev:Prevent()
    end
end)
-- Temporarily disabled due to issues with dropdowns.
-- Input.Events.MouseButtonPressed:Subscribe(function (_)
--     if UI:IsVisible() and not UI._IsCursorOverUI then
--         UI.Close()
--     end
-- end)

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