
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local Tooltip = Client.Tooltip
local Input = Client.Input
local V = Vector.Create

---@class Feature_EquipmentSwap
local EquipmentSwap = Epip.GetFeature("Feature_EquipmentSwap")
local UI = Generic.Create("Epip_EquipmentSwap")
UI._Initialized = false
UI._Lists = {} ---@type GenericUI_Element_HorizontalList[]
UI._CurrentItemCount = 0
UI._IsCursorOverUI = false

UI.BACKGROUND_SIZE = V(400, 400)
UI.HEADER_SIZE = V(400, 50)
UI.SCROLL_LIST_FRAME = V(380, 260)
UI.ITEM_SIZE = V(50, 50)
UI.ITEMS_PER_ROW = 6
UI.RARITY_PRIORITY = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Divine = 6,
    Unique = 7,
    Artifact = 8,
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Opens the UI.
---@param char EclCharacter
---@param slot ItemSlot
function UI.Setup(char, slot)
    UI._Initialize()
    UI._Cleanup()

    local items = Item.GetItemsInPartyInventory(char, function (item)
        return Item.GetItemSlot(item) == slot
    end)

    -- Sort by rarity
    table.sort(items, function (a, b)
        a, b = a, b ---@type EclItem, EclItem
        local rarityA, rarityB = a.Stats.Rarity, b.Stats.Rarity
        local scoreA, scoreB

        if Item.IsArtifact(a) then
            rarityA = "Artifact"
        end
        if Item.IsArtifact(b) then
            rarityB = "Artifact"
        end

        scoreA, scoreB = UI.RARITY_PRIORITY[rarityA] or 0, UI.RARITY_PRIORITY[rarityB] or 0

        return scoreA > scoreB
    end)

    for _,item in ipairs(items) do
        UI._RenderItem(item)
    end

    UI.ItemsList:RepositionElements()

    local x, y = Client.GetMousePosition()
    UI:GetUI():SetPosition(x, y - UI.BACKGROUND_SIZE[2])
    UI:Show()
end

---Closes the UI.
function UI.Close()
    Tooltip.HideTooltip()
    UI:Hide()
end

---Removes dynamically created elements.
function UI._Cleanup()
    UI._CurrentItemCount = 0

    UI.ItemsList:GetMovieClip().list.m_scrollbar_mc.resetHandle()

    for _,list in ipairs(UI._Lists) do
        list:Clear()
    end
end

---Renders an item onto the list.
---@param item EclItem
function UI._RenderItem(item)
    local listIndex = (UI._CurrentItemCount // UI.ITEMS_PER_ROW) + 1
    if listIndex > #UI._Lists then
        table.insert(UI._Lists, UI.ItemsList:AddChild("List_" .. listIndex, "GenericUI_Element_HorizontalList"))
    end
    local list = UI._Lists[listIndex]
    local element = HotbarSlot.Create(UI, item.MyGuid, list)
    element:SetItem(item)
    element:SetUpdateDelay(-1)
    element:SetEnabled(Stats.MeetsRequirements(Client.GetCharacter(), item.StatsId, true, item))

    element.Events.Clicked:Subscribe(function (_)
        UI.Close()
    end)

    UI._CurrentItemCount = UI._CurrentItemCount + 1
end

---Creates the core elements of the UI.
function UI._Initialize()
    if not UI._Initialized then
        local bg = UI:CreateElement("Background", "GenericUI_Element_TiledBackground")
        bg:SetBackground("FormattedTooltip", UI.BACKGROUND_SIZE:unpack())
        bg.Events.MouseOver:Subscribe(function (_)
            UI._IsCursorOverUI = true
        end)
        bg.Events.MouseOut:Subscribe(function (_)
            UI._IsCursorOverUI = false
        end)

        local header = TextPrefab.Create(UI, "Header", bg, "Quick Swap", "Center", UI.HEADER_SIZE)
        header:SetPositionRelativeToParent("Top", 0, 20)
        header:SetStroke(Color.Create(0, 0, 0):ToDecimal(), 2, 1, 15, 15)

        local scrollList = bg:AddChild("Items", "GenericUI_Element_ScrollList")
        scrollList:SetFrame(UI.SCROLL_LIST_FRAME:unpack())
        scrollList:SetMouseWheelEnabled(true)
        scrollList:SetPosition(15, 80)
        scrollList:SetScrollbarSpacing(-30)
        UI.ItemsList = scrollList
    end

    UI._Initialized = true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Close the UI when escape is pressed, or when a mouse press occurs outside the UI.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if ev.InputID == "escape" and UI:IsVisible() then
        UI.Close()
        ev:Prevent()
    end
end)
Input.Events.MouseButtonPressed:Subscribe(function (_)
    if UI:IsVisible() and not UI._IsCursorOverUI then
        UI.Close()
    end
end)

-- Add option to equipment context menus.
Client.UI.ContextMenu.RegisterVanillaMenuHandler("Item", function(item)
    if Item.IsEquipment(item) then
        Client.UI.ContextMenu.AddElement({
            {id = "epip_Feature_EquipmentSwap", type = "button", text = "Quick Swap..."},
        })
    end
end)

-- Listen for context menu button being pressed.
Client.UI.ContextMenu.RegisterElementListener("epip_Feature_EquipmentSwap", "buttonPressed", function(item, _)
    UI.Setup(Client.GetCharacter(), Item.GetItemSlot(item))
end)