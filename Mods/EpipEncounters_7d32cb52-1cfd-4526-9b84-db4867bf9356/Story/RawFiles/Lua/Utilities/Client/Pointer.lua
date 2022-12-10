
---@class PointerLib : Library
---@field private CurrentHandles table
Pointer = {
    CurrentHandles = {
        HoverCharacter = {EventName = "HoverCharacterChanged", EntityEventFieldName = "Character", CurrentHandle = nil},
        HoverCharacter2 = {EventName = "HoverCharacter2Changed", EntityEventFieldName = "Character", CurrentHandle = nil},
        HoverItem = {EventName = "HoverItemChanged", EntityEventFieldName = "Item", CurrentHandle = nil},
        PlaceableEntity = {EventName = "HoverEntityChanged", EntityEventFieldName = "Entity", CurrentHandle = nil},
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS= false,

    Events = {
        HoverCharacterChanged = {}, ---@type Event<PointerLib_Event_HoverCharacterChanged>
        HoverCharacter2Changed = {}, ---@type Event<PointerLib_Event_HoverCharacter2Changed>
        HoverItemChanged = {}, ---@type Event<PointerLib_Event_HoverItemChanged>
        HoverEntityChanged = {}, ---@type Event<PointerLib_Event_HoverEntityChanged>
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