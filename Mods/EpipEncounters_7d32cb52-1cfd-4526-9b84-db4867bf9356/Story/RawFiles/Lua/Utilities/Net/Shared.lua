

---@class NetLib : Library
Net = {
    INVALID_USER_ID = -65536,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        MessageReceived = {}, ---@type Event<Net_Event_MessageReceived>
    },
}
Epip.InitializeLibrary("Net", Net)

Game.Net = Net -- Backwards compatibility

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class NetLib_Message : Class
---@field Channel string
local _Payload = {}
Net:RegisterClass("NetLib_Payload", _Payload)

---@package
---@param data NetLib_Message
---@return NetLib_Message
function _Payload:___Create(data)
    local instance = self:__Create(data) ---@cast instance NetLib_Message

    -- Cast position field to vector.
    local positionField = instance["Position"]
    if positionField and type(positionField) == "table" then
        ---@cast instance NetLib_Message_Position
        instance.Position = Vector.Create(positionField)
    end

    return instance
end

---Checks whether the payload has a field;
---throws an error if it doesn't.
---@protected
---@param funcName string
---@param field string
function _Payload:_CheckField(funcName, field)
    if not self[field] then
        Net:Error("Payload:" .. funcName, "Payload", self.Channel, "has no field", field)
    end
end

---@class NetLib_Message_Character : NetLib_Message
---@field CharacterNetID NetId
local _CharacterPayload = _Payload -- The inheritance here is a lie, there is technically no distinction between the payload classes - it's for IDE autocompletion only

---Returns the character associated with the payload.
---@return Character
function _CharacterPayload:GetCharacter()
    self:_CheckField("GetCharacter", "CharacterNetID")

    return Character.Get(self.CharacterNetID)
end

---@class NetLib_Message_Item : NetLib_Message
---@field ItemNetID NetId
local _ItemPayload = _Payload

---Returns the item associated with the payload.
---@return Item
function _ItemPayload:GetItem()
    self:_CheckField("GetItem", "ItemNetID")

    return Item.Get(self.ItemNetID)
end

---@class NetLib_Message_NetID : NetLib_Message
---@field NetID NetId

---@class NetLib_Message_State : NetLib_Message
---@field State boolean

---@class NetLib_Message_Position : NetLib_Message
---@field Position Vector

---------------------------------------------
-- EVENTS
---------------------------------------------

---@generic T
---@class Net_Event_MessageReceived<T>
---@field Channel string
---@field Message `T`|any Will be a primitive if the payload sent wasn't a table.
---@field UserID UserId

---------------------------------------------
-- METHODS
---------------------------------------------

---Sends a message to all peers.
---@generic T
---@param channel `T`
---@param message T?
---@param excludedChar GUID?
function Net.Broadcast(channel, message, excludedChar)
    message = message or {}

    Ext.Net.BroadcastMessage(channel, Utilities.Stringify(message), excludedChar)
end

---Sends a message to the user that currently controls char. Fails if char is a summon.
---@generic T
---@param char Character|GUID|NetId
---@param channel `T`
---@param message T?
function Net.PostToCharacter(char, channel, message)
    if GetExtType(char) ~= nil then char = char.MyGuid end

    Ext.Net.PostMessageToClient(char, channel, Utilities.Stringify(message or {}))
end

---Sends a message to a user.
---@generic T
---@param user UserId|Character
---@param channel `T`
---@param message T?
function Net.PostToUser(user, channel, message)
    if GetExtType(user) ~= nil then user = user.ReservedUserID end
    if Ext.IsClient() and user.ReservedForPlayerId < 0 then -- Use reserved user ID if the character is assigned to a player but not currently controlled.
        user = user.ReservedForPlayerId
    end

    Ext.Net.PostMessageToUser(user, channel, Utilities.Stringify(message))
end

---Sends a message to the owner of char. Use if you suspect the char might be a summon.
---@param char Character
---@param channel string
---@param message any
function Net.PostToOwner(char, channel, message)
    local owner = char
    if char.HasOwner then
        -- Mildly annoying inconsistency with field names.
        if Ext.IsClient() then
            owner = Character.Get(char.OwnerCharacterHandle)
        else
            owner = Character.Get(char.OwnerHandle)
        end
    end

    Net.PostToCharacter(owner, channel, message)
end

---Wrapper for Ext.RegisterNetListener that parses json payloads and fires an event afterwards.
---@generic T
---@param channel `T`
---@param func fun(payload:`T`)
function Net.RegisterListener(channel, func)
    local event = Net._GetChannelMessageEvent(channel)

    event:Subscribe(function (ev)
        ---@diagnostic disable-next-line: redundant-parameter, undefined-field
        func(ev.Message, ev.Message) -- Second param is for backwards compatibility with listeners that expected the first param to be the channel name.
    end)
end

---Returns the event associated with the passed message channel.
---@generic T
---@param channel string`T`
---@return Event<Net_Event_MessageReceived<`T`>>
function Net._GetChannelMessageEvent(channel)
    local event = Net.Events[channel]

    if not event then
        event = Net:AddSubscribableEvent(channel)
    end

    return event
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Forward Net messages to corresponding events.
Ext.Events.NetMessageReceived:Subscribe(function(ev)
    -- Try parsing json payloads
    local rawPayload = ev.Payload -- Fallback if parsing fails (ex. a raw string payload)
    local success, parsedPayload = pcall(Ext.Json.Parse, ev.Payload) -- Note: parse returns non-string for non-string primitives.
    if success then
        rawPayload = parsedPayload
    end
    local payload

    -- Only create a Payload instance if the message was a table.
    if type(rawPayload) == "table" then
        payload = _Payload:___Create(rawPayload)
    else
        payload = rawPayload
    end

    local event = {Message = payload, Channel = ev.Channel, UserID = ev.UserID} ---@type Net_Event_MessageReceived
    local subscribableEvent = Net._GetChannelMessageEvent(ev.Channel)

    subscribableEvent:Throw(event)

    -- The generic listener goes last.
    Net.Events.MessageReceived:Throw(event)
end)