
---@class TradeUI : UI
local Trade = {
    -- IDs of item grids, called "lists" by the UI.
    ---@enum TradeUI.GridID
    GRID_IDS = {
        PLAYER_INVENTORY = 0,
        PLAYER_OFFER = 1,
        TRADER_OFFER = 2,
        TRADER_INVENTORY = 3,
    },

    _CurrentHoveredSlot = nil, ---@type TradeUI.SlotSelection? Index is zero-based.
}
Epip.InitializeUI(Ext.UI.TypeID.trade, "Trade", Trade)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class TradeUI.Slot
---@field Position TradeUI.SlotSelection
---@field Item EclItem?

---@alias TradeUI.SlotSelection {GridID: TradeUI.GridID, Index: integer}

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the element for a grid.
---@param gridID TradeUI.GridID
---@return FlashMovieClip
function Trade.GetGridElement(gridID)
    local root = Trade:GetRoot()
    local trade = root.trade_mc
    local mc
    if gridID == Trade.GRID_IDS.PLAYER_INVENTORY then
        mc = trade.playerInventoryList
    elseif gridID == Trade.GRID_IDS.PLAYER_OFFER then
        mc = trade.playerExchangeList
    elseif gridID == Trade.GRID_IDS.TRADER_INVENTORY then
        mc = trade.traderInventoryList
    elseif gridID == Trade.GRID_IDS.TRADER_OFFER then
        mc = trade.traderExchangeList
    else
        Trade:__Error("GetGridElement", "unknown grid ID", gridID)
    end
    return mc
end

---Returns the slot element for a slot.
---@param gridID TradeUI.GridID
---@param index integer 0-based.
function Trade.GetSlotElement(gridID, index)
    local grid = Trade.GetGridElement(gridID)
    local slot = grid.content_array[index]
    return slot
end

---Returns the currently-selected slot.
---@return TradeUI.Slot? -- `nil` if no slot is selected.
function Trade.GetSelectedSlot()
    local selection = Trade._CurrentHoveredSlot
    if not selection then return nil end
    local slotElement = Trade.GetSlotElement(selection.GridID, selection.Index)
    ---@type TradeUI.Slot
    local slot = {
        Position = selection,
        Item = (slotElement.itemHandle and slotElement.itemHandle > 0) and Item.Get(slotElement.itemHandle, true) or nil,
    }
    return slot
end

---Returns the party member the player is bartering as.
---@return EclCharacter
function Trade.GetSelectedCharacter()
    local list = Trade:GetRoot().trade_mc.charList.content_array
    local char
    for i=0,#list-1,1 do
        local member = list[i]
        if member.isActive then
            char = Character.Get(member.id, true)
        end
    end
    return char
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for slots being hovered over to track the selected slot.
Trade:RegisterCallListener("slotOver", function (_, listID, pos)
    local slot = Trade.GetSlotElement(listID, pos)
    if slot and slot.itemHandle and slot.itemHandle > 0 then
        Trade._CurrentHoveredSlot = {
            GridID = listID,
            Index = pos,
        }
    else
        -- Possibly redundant, as it is also handled by the slotOut listener.
        Trade._CurrentHoveredSlot = nil
    end
end)
Trade:RegisterCallListener("slotOut", function (_)
    Trade._CurrentHoveredSlot = nil
end)
