
local Set = DataStructures.Get("DataStructures_Set")

---@class PointerLib : Library
---@field private CurrentHandles table
Pointer = {
    CurrentHandles = {
        HoverCharacter = {EventName = "HoverCharacterChanged", EntityEventFieldName = "Character", CurrentHandle = nil},
        HoverCharacter2 = {EventName = "HoverCharacter2Changed", EntityEventFieldName = "Character", CurrentHandle = nil},
        HoverItem = {EventName = "HoverItemChanged", EntityEventFieldName = "Item", CurrentHandle = nil},
        PlaceableEntity = {EventName = "HoverEntityChanged", EntityEventFieldName = "Entity", CurrentHandle = nil},
    },
    _PlayersWithDragDrop = Set.Create(), ---@type DataStructures_Set<integer>

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS= false,

    Events = {
        HoverCharacterChanged = {}, ---@type Event<PointerLib_Event_HoverCharacterChanged>
        HoverCharacter2Changed = {}, ---@type Event<PointerLib_Event_HoverCharacter2Changed>
        HoverItemChanged = {}, ---@type Event<PointerLib_Event_HoverItemChanged>
        HoverEntityChanged = {}, ---@type Event<PointerLib_Event_HoverEntityChanged>
        DragDropStateChanged = {}, ---@type Event<PointerLib_Event_DragDropStateChanged>
        UIDragStarted = {}, ---@type Event<PointerLib.Events.UIDrag>
        UIDragEnded = {}, ---@type Event<PointerLib.Events.UIDrag>
    },
}
Epip.InitializeLibrary("Pointer", Pointer)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class PointerLib_PickingState
---@field WorldPosition Vector3D?
---@field WalkablePosition Vector3D
---@field HoverCharacter EntityHandle?
---@field HoverCharacter2 EntityHandle? Used for corpses.
---@field HoverCharacterPosition Vector3D? Corresponds to HoverCharacter's position.
---@field HoverItem EntityHandle?
---@field HoverItemPosition Vector3D?
---@field PlaceableEntity EntityHandle?
---@field PlaceablePosition Vector3D?

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class PointerLib_Event_HoverCharacterChanged
---@field Character EclCharacter?

---Fired when the corpse character over the pointer changes.
---@class PointerLib_Event_HoverCharacter2Changed
---@field Character EclCharacter?

---@class PointerLib_Event_HoverItemChanged
---@field Item EclItem?

---@class PointerLib_Event_HoverEntityChanged
---@field Entity Entity?

---Fired when a player starts or ends a drag drop. 
---@class PointerLib_Event_DragDropStateChanged
---@field State DragDropManagerPlayerDragInfo? `nil` if the player stopped dragging.
---@field PlayerIndex integer

---@class PointerLib.Events.UIDrag
---@field UI UIObject

---------------------------------------------
-- METHODS
---------------------------------------------

---@param playerIndex integer? Defaults to 1.
---@param includeDead boolean? Defaults to false.
---@return EclCharacter?
function Pointer.GetCurrentCharacter(playerIndex, includeDead)
    local char = Pointer._GetCurrentEntity(playerIndex, "HoverCharacter") ---@type EclCharacter

    -- Check HoverCharacter2 for corpses.
    if not char and includeDead then
        char = Pointer._GetCurrentEntity(playerIndex, "HoverCharacter2") ---@type EclCharacter
    end

    return char
end

---@param playerIndex integer? Defaults to 1.
---@return EclItem?
function Pointer.GetCurrentItem(playerIndex)
    ---@diagnostic disable-next-line: return-type-mismatch
    return Pointer._GetCurrentEntity(playerIndex, "HoverItem")
end

---@param playerIndex integer? Defaults to 1.
---@return Entity?
function Pointer.GetCurrentEntity(playerIndex)
    return Pointer._GetCurrentEntity(playerIndex, "HoverEntity")
end

---@param playerIndex integer? Defaults to 1.
---@return Vector3D
function Pointer.GetWalkablePosition(playerIndex)
    local state = Ext.UI.GetPickingState(playerIndex or 1)
    local position

    if state then
        position = Vector.Create(table.unpack(state.WalkablePosition))
    end

    return position
end

---@param playerIndex integer? Defaults to 1.
---@return Vector3D
function Pointer.GetWorldPosition(playerIndex)
    local state = Ext.UI.GetPickingState(playerIndex or 1)
    local position

    if state then
        position = Vector.Create(state.WorldPosition)
    end

    return position
end

---Returns the drag-drop system state for a player.
---@param playerIndex integer? Defaults to 1.
---@return DragDropManagerPlayerDragInfo
function Pointer.GetDragDropState(playerIndex)
    return Ext.UI.GetDragDrop().PlayerDragDrops[playerIndex or 1]
end

---Returns the skill being dragged by a player.
---@param playerIndex integer? Defaults to 1.
---@return string? --Can be an action as well.
function Pointer.GetDraggedSkill(playerIndex)
    local dragDrop = Pointer.GetDragDropState(playerIndex)
    local skill = nil

    if dragDrop.DragId ~= "" then
        skill = dragDrop.DragId
    end

    return skill
end

---Returns the item being dragged by a player.
---@param playerIndex integer? Defaults to 1.
---@return EclItem?
function Pointer.GetDraggedItem(playerIndex)
    local dragDrop = Pointer.GetDragDropState(playerIndex)
    local item = nil

    if Ext.Utils.IsValidHandle(dragDrop.DragObject) then
        item = Item.Get(dragDrop.DragObject)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return item
end

---Returns whether the player's cursor is dragging anything.
---@param playerIndex integer? Defaults to 1.
---@return boolean
function Pointer.IsDragging(playerIndex)
    return Pointer.GetDragDropState(playerIndex).IsDragging
end

---@param playerIndex integer? Defaults to 1.
---@param fieldName string
---@return Entity
function Pointer._GetCurrentEntity(playerIndex, fieldName)
    local state = Ext.UI.GetPickingState(playerIndex or 1)
    local entity

    if state then
        local handle = state[fieldName]

        if handle then
            entity = Ext.Entity.GetGameObject(handle) ---@type Entity
        end
    end

    return entity
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for pointer entities changing.
GameState.Events.RunningTick:Subscribe(function (_)
    local state = Ext.UI.GetPickingState(1) -- TODO support more players

    for field,data in pairs(Pointer.CurrentHandles) do
        local newHandle = state[field]

        -- Fire events when the pointer entities change
        if newHandle ~= data.CurrentHandle then
            local event = {}

            if newHandle then
                event[data.EntityEventFieldName] = Ext.Entity.GetGameObject(newHandle)
            end

            Pointer.Events[data.EventName]:Throw(event)

            data.CurrentHandle = newHandle
        end
    end
end)

-- Listen for drag-drop states changing.
GameState.Events.RunningTick:Subscribe(function (_)
    local dragDrops = Ext.UI.GetDragDrop().PlayerDragDrops

    for id,dragDrop in ipairs(dragDrops) do
        local wasDragging = Pointer._PlayersWithDragDrop:Contains(id)

        if wasDragging and not dragDrop.IsDragging then
            Pointer.Events.DragDropStateChanged:Throw({
                PlayerIndex = id,
                State = nil,
            })

            Pointer._PlayersWithDragDrop:Remove(id)
        elseif not wasDragging and dragDrop.IsDragging then
            Pointer.Events.DragDropStateChanged:Throw({
                PlayerIndex = id,
                State = dragDrop,
            })

            Pointer._PlayersWithDragDrop:Add(id)
        end
    end
end)

-- Listen for UI drag-drops starting and ending.
Ext.Events.UICall:Subscribe(function (ev)
    if ev.When == "After" then
        if ev.Function == "startMoveWindow" then
            Pointer.Events.UIDragStarted:Throw({
                UI = ev.UI,
            })
        elseif ev.Function == "cancelMoveWindow" then
            Pointer.Events.UIDragEnded:Throw({
                UI = ev.UI,
            })
        end
    end
end)

---------------------------------------------
-- TESTS
---------------------------------------------

-- Pointer.Events.HoverCharacter2Changed:Subscribe(function (ev)
--     print("HoverCharacter2Changed:", ev.Character)
-- end)

-- Pointer.Events.HoverCharacterChanged:Subscribe(function (ev)
--     print("HoverCharacterChanged:", ev.Character)
-- end)

-- Pointer.Events.HoverEntityChanged:Subscribe(function (ev)
--     print("HoverEntityChanged:", ev.Entity)
-- end)

-- Pointer.Events.HoverItemChanged:Subscribe(function (ev)
--     print("HoverItemChanged:", ev.Item)
-- end)