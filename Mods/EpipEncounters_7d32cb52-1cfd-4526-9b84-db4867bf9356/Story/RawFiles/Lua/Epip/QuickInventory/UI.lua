
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

---@class Features.QuickInventory.UI : GenericUI_Instance
local UI = Generic.Create("Features.QuickInventory.UI", 13) -- Placed below book.swf, which can be accessed from it.
QuickInventory.UI = UI

UI._Initialized = false
UI._Slots = {} ---@type GenericUI_Prefab_HotbarSlot[] Pooling for HotbarSlots, since they are expensive to create.
UI._CurrentItemCount = 0
UI._IsCursorOverUI = false
UI._SettingPrefabInstances = {} ---@type table<string, GenericUI_Prefab|GenericUI_I_Elementable> Maps setting full IDs to prefab instance.

UI.BACKGROUND_SIZE = V(420, 500) -- For main panel only.
UI.SETTINGS_PANEL_SIZE = V(500, 500)
UI.HEADER_SIZE = V(400, 50)
UI.SCROLLBAR_WIDTH = 10
UI.SCROLL_LIST_AREA = UI.BACKGROUND_SIZE - V(40 + UI.SCROLLBAR_WIDTH, 140)
UI.SCROLL_LIST_FRAME = UI.BACKGROUND_SIZE - V(40, 137)
UI.ITEM_SIZE = V(58, 58)
UI.ELEMENT_SPACING = 5
UI.SETTINGS_PANEL_ELEMENT_SIZE = V(UI.SETTINGS_PANEL_SIZE[1] - 55, 50)
UI.SETTINGS_PANEL_SCROLLLIST_FRAME = UI.SETTINGS_PANEL_SIZE - V(20, 150)
UI.DRAGGABLE_AREA_SIZE = V(UI.BACKGROUND_SIZE[1] + UI.SETTINGS_PANEL_SIZE[1], 65)

UI.Events.RenderSettings = SubscribableEvent:New("RenderSettings") ---@type Event<{ItemCategory:string}> Children of the list are set to invisible before invoking; you're expected to pool the setting elements. See `UI.RenderSetting()`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Opens the UI.
function UI.Setup()
    UI._Initialize()

    UI.RenderItems()

    UI._RenderSettingsPanel()

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

    for i=UI._CurrentItemCount+1,UI._GetTotalSlots(),1 do -- Hide excess slots
        local slot = UI._GetHotbarSlot(i)

        if slot.SlotElement:IsVisible() then
            slot.SlotElement:SetVisible(false)
        else -- Exit after finding the first invisible element; performance gain is very, very minimal.
            break
        end
    end
    QuickInventory:AddProfilingStep("SetVisibility")
    UI.ItemGrid:RepositionElements()
    UI.ItemsList:RepositionElements()
    QuickInventory:EndProfiling()
end

---Returns the total amount of slot objects available.
---@return integer
function UI._GetTotalSlots()
    return #UI._Slots
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
---@param itemIndex integer
---@return GenericUI_Prefab_HotbarSlot
function UI._GetHotbarSlot(itemIndex)
    local slot = UI._Slots[itemIndex]
    if not slot then -- Create extra slots on demand.
        local grid = UI.ItemGrid

        slot = HotbarSlot.Create(UI, string.format("ItemSlot_%s", itemIndex), grid)
        slot:SetCanDrag(true, false) -- Can drag items out of the slot, without clearing the slot.

        slot.Events.Clicked:Subscribe(function (_)
            UI._OnSlotClicked(slot)
        end)

        slot.Hooks.GetTooltipData:Subscribe(function (ev)
            ev.Position = V(UI:GetPosition()) + V(UI.BACKGROUND_SIZE[1], 0)
        end)

        slot.SlotElement:SetSizeOverride(UI.ITEM_SIZE)
        QuickInventory:AddProfilingStep("Create Slot")

        UI._Slots[itemIndex] = slot
    end

    return slot
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

        local slotGrid = scrollList:AddChild("ItemGrid", "GenericUI_Element_Grid")
        slotGrid:SetRepositionAfterAdding(false)
        slotGrid:SetGridSize(UI.GetItemsPerRow(), -1)
        UI.ItemGrid = slotGrid

        UI._InitalizeSettingsPanel()

        -- Only set relative position the first time the UI is used in a session.
        UI:SetPositionRelativeToViewport("center", "center")
    end

    UI._Initialized = true
end

function UI._RenderSettingsPanel()
    local itemCategory = QuickInventory:GetSettingValue(QuickInventory.Settings.ItemCategory)

    -- Set children as invisible instead of clearing the list;
    -- elements are intended to be pooled for performance.
    for _,child in ipairs(UI.SettingsPanelList:GetChildren()) do
        child:SetVisible(false)
    end

    -- Render item category setting
    UI.RenderSetting(QuickInventory.Settings.ItemCategory)

    UI.Events.RenderSettings:Throw({
        ItemCategory = itemCategory,
    })

    UI.RenderSetting(QuickInventory.Settings.RecursiveSearch)

    UI.SettingsPanelList:SortByChildIndex()
end

---Renders a widget to the settings panel for a setting.
---This method supports pooling and will return the existing prefab instance for the setting if one exists, as well as set it to visible.
---@param setting Features.SettingWidgets.SupportedSettingType
---@return GenericUI_Prefab|GenericUI_I_Elementable
function UI.RenderSetting(setting)
    local instance = UI._GetPooledSettingPrefab(setting)
    if not instance then
        instance = SettingWidgets.RenderSetting(UI, UI.SettingsPanelList, setting, UI.SETTINGS_PANEL_ELEMENT_SIZE, function (_)
            if setting.Type == "String" then -- Do not re-render the whole settings panel in this case, as it causes the focus to break.
                UI.RenderItems()
            else
                UI.Refresh()
            end
        end)
        UI._SettingPrefabInstances[setting:GetNamespacedID()] = instance
    else
        instance:SetVisible(true) -- Auto-set visibility.
        UI.SettingsPanelList:SetChildIndex(instance:GetRootElement().ID, 9999) -- Place the instance at the bottom of the list; scripts expect elements to appear in order of invocation of RenderSetting().
    end
    return instance
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

---Returns the prefab instance of a setting, if one exists.
---@see Features.QuickInventory.UI.RenderSetting
---@param setting SettingsLib_Setting
---@return (GenericUI_Prefab|GenericUI_I_Elementable)?
function UI._GetPooledSettingPrefab(setting)
    return UI._SettingPrefabInstances[setting:GetNamespacedID()]
end

---Initializes the settings panel.
function UI._InitalizeSettingsPanel()
    local settingsPanel = TooltipPanelPrefab.Create(UI, "Settings", UI.Background.Background, UI.SETTINGS_PANEL_SIZE, Text.Format(Text.CommonStrings.Settings:GetString(), {Size = 23}), UI.HEADER_SIZE)
    settingsPanel.Background:SetPosition(UI.BACKGROUND_SIZE[1] - 15, 0)
    UI.Background.Background:SetChildIndex(settingsPanel.Background.ID, 0)
    UI.SettingsPanel = settingsPanel

    local list = settingsPanel:AddChild("SettingsList", "GenericUI_Element_ScrollList")
    list:SetFrame(UI.SETTINGS_PANEL_SCROLLLIST_FRAME:unpack())
    list:SetRepositionAfterAdding(false)
    list:SetScrollbarSpacing(-50)
    list:SetMouseWheelEnabled(true)
    list:SetPosition(20, 80)
    UI.SettingsPanelList = list
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