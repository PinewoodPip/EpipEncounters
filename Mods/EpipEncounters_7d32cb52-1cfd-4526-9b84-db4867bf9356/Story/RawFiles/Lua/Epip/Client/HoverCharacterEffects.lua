
---------------------------------------------
-- Allows playing client-side effects on characters that the client pointer
-- hovers over.
---------------------------------------------

---@class Feature_HoverCharacterEffects : Feature
local HoverEffects = {
    _CurrentRequest = nil, ---@type Feature_HoverCharacterEffects_Request

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetEffects = {}, ---@type Event<Feature_HoverCharacterEffects_Hook_GetEffects>
    },
}
Epip.RegisterFeature("HoverCharacterEffects", HoverEffects)

---------------------------------------------
-- CLASSES
---------------------------------------------

---Holds information of the effects to be played on a hovered character.
---@class Feature_HoverCharacterEffects_Request
local _Request = {
    _Effects = {}, ---@type string[]
    _VisualHandle = nil, ---@type ComponentHandle
}

---@param entity EclCharacter|EclItem
---@return Feature_HoverCharacterEffects_Request
function _Request.Create(entity)
    local visual ---@type EclLuaVisualClientMultiVisual
    if Entity.IsCharacter(entity) then
        visual = Ext.Visual.CreateOnCharacter(entity.WorldPos, entity)
    elseif Entity.IsItem(entity) then
        visual = Ext.Visual.CreateOnItem(entity.WorldPos, entity)
    else
        HoverEffects:Error("Request.Create", "Unsupported entity type", GetExtType(entity))
    end

    ---@type Feature_HoverCharacterEffects_Request
    local obj = {
        _VisualHandle = visual.Handle,
    }
    Inherit(obj, _Request)

    return obj
end

---Adds an effect to be played.
---@param effectName string
function _Request:AddEffect(effectName)
    local visual = self:GetVisual()

    table.insert(self._Effects, effectName)

    visual:ParseFromStats(effectName)
end

---@return EclLuaVisualClientMultiVisual
function _Request:GetVisual()
    return Ext.Visual.Get(self._VisualHandle)
end

function _Request:Destroy()
    local visual = self:GetVisual()

    if visual then
        visual:Delete()
    else
        HoverEffects:Error("Request:Destroy", "Attempted to destroy a request with no visual")
    end
end

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Feature_HoverCharacterEffects_Hook_GetEffects
---@field Entity EclCharacter|EclItem
---@field Request Feature_HoverCharacterEffects_Request Hookable. Use its methods to manipulate effects to play.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the effect request currently playing.
---Will be nil if the client pointer is not hovering over a supported entity.
---@return Feature_HoverCharacterEffects_Request?
function HoverEffects.GetCurrentRequest()
    return HoverEffects._CurrentRequest
end

---@param ev PointerLib_Event_HoverCharacterChanged|PointerLib_Event_HoverItemChanged
function HoverEffects._ProcessHoverEvent(ev)
    local currentRequest = HoverEffects._CurrentRequest
    local entity = ev.Character or ev.Item

    -- Destroy previous request
    if currentRequest then
        currentRequest:Destroy()
        currentRequest = nil
    end

    -- Don't play effects on the client character
    if entity and Client.GetCharacter() ~= entity then
        currentRequest = _Request.Create(entity)

        HoverEffects.Hooks.GetEffects:Throw({
            Request = currentRequest,
            Entity = entity,
        })
    end

    HoverEffects._CurrentRequest = currentRequest
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for characters and items being hovered over and throw events.
Pointer.Events.HoverCharacterChanged:Subscribe(function (ev)
    HoverEffects._ProcessHoverEvent(ev)
end)
Pointer.Events.HoverItemChanged:Subscribe(function (ev)
    HoverEffects._ProcessHoverEvent(ev)
end)

---------------------------------------------
-- TESTING
---------------------------------------------

function HoverEffects.__Test()
    HoverEffects.Hooks.GetEffects:Subscribe(function (ev)
        ev.Request:AddEffect("RS3_FX_UI_BackStab_Arc_01")
    end)
end