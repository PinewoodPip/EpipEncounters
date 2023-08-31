
---------------------------------------------
-- Implements a UI that displays multi-select drags.
---------------------------------------------

local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local V = Vector.Create

---@class Features.InventoryMultiSelect
local MultiSelect = Epip.GetFeature("Features.InventoryMultiSelect")

local UI = Generic.Create("Features.InventoryMultiSelect.MultiDrag")

UI.MULTIDRAG_COUNT_LABEL_SIZE = V(300, 50)
UI.ITEM_ICON_SIZE = V(50, 50) -- Visual size.
UI.ITEM_ICON_SIZE_OVERRIDE = V(20, UI.ITEM_ICON_SIZE[2])

UI._TICK_LISTENER_ID = "Features.InventoryMultiSelect.MultiDragUITick"

---------------------------------------------
-- TSKS
---------------------------------------------

MultiSelect.TranslatedStrings.MultiDragLabel = MultiSelect:RegisterTranslatedString("h7807c88fg2c24g4d2dg8015ga1666bcfa0b1", {
    Text = "Dragging %s items",
    ContextDescription = "Hint over cursor while dragging. Param is amount of items",
})

---------------------------------------------
-- METHODS
---------------------------------------------

---Initializes and shows the UI.
function UI.Setup()
    UI._Initialize()

    local list = UI.IconList
    list:Clear()

    local selections = MultiSelect.GetOrderedSelections()
    for _,selection in pairs(selections) do
        local item = Item.Get(selection.ItemHandle)
        local icon = list:AddChild("ItemIcon_" .. item.NetID, "GenericUI_Element_IggyIcon")

        icon:SetIcon(Item.GetIcon(item), UI.ITEM_ICON_SIZE:unpack())
        icon:SetSizeOverride(UI.ITEM_ICON_SIZE_OVERRIDE) -- Make items take up less space horizontally on the list, creating a "stacking" effect
    end
    list:RepositionElements()

    -- Update count label
    UI.MultiDragLabel:SetText(string.format(MultiSelect.TranslatedStrings.MultiDragLabel:GetString(), table.getKeyCount(selections)))

    GameState.Events.RunningTick:Subscribe(function (_)
        UI:SetPosition(V(Client.GetMousePosition())) -- Follow mouse.

        -- Stop multi-dragging when M1 is released.
        if not Client.Input.IsKeyPressed("left2") then
            MultiSelect.EndMultiDrag()
            UI:Hide()
            GameState.Events.RunningTick:Unsubscribe(UI._TICK_LISTENER_ID)
        end
    end, {StringID = UI._TICK_LISTENER_ID})

    UI:Show()
end

function UI._Initialize()
    if UI._Initialized then return end

    local root = UI:CreateElement("Root", "GenericUI_Element_Empty")
    local label = TextPrefab.Create(UI, "ItemCountLabel", root, "", "Left", UI.MULTIDRAG_COUNT_LABEL_SIZE)
    local iconList = root:AddChild("IconList", "GenericUI_Element_HorizontalList")

    label:SetStroke(Color.Create(0, 0, 0), 1, 1, 1, 1)
    label:Move(0, UI.ITEM_ICON_SIZE[2] + 10) -- Place label below items

    UI.MultiDragLabel = label
    UI.IconList = iconList

    UI:TogglePlayerInput(false)

    UI._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for multi-drags starting to show the UI.
MultiSelect.Events.MultiDragStarted:Subscribe(function (_)
    UI.Setup()
end)