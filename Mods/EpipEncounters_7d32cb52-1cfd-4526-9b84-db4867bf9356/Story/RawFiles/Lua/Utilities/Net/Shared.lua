

---@class Net : Feature
Net = {
    INVALID_USER_ID = -65536,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        MessageReceived = {}, ---@type SubscribableEvent<Net_Event_MessageReceived>
    },
}
Epip.InitializeLibrary("Net", Net)

Game.Net = Net -- Backwards compatibility

---------------------------------------------
-- EVENTS
---------------------------------------------

---@generic T
---@class Net_Event_MessageReceived<T>
---@field Channel string
---@field Message `T`
---@field UserID UserId

---------------------------------------------
-- METHODS
---------------------------------------------

function Net.Broadcast(channel, message, excludedChar)
    message = message or {}
    Ext.Net.BroadcastMessage(channel, Utilities.Stringify(message), excludedChar)
end

function Net.PostToCharacter(char, channel, message)
    if GetExtType(char) ~= nil then char = char.MyGuid end
    
    Ext.Net.PostMessageToClient(char, channel, Utilities.Stringify(message or {}))
end

function Net.PostToUser(user, channel, message, excludedChar)
    if type(user) == "userdata" then user = user.ReservedUserID end
    
    Ext.Net.PostMessageToUser(user, channel, Utilities.Stringify(message), excludedChar)
end

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
        ---@diagnostic disable-next-line: redundant-parameter
        func(ev.Message, ev.Message) -- Second param is for backwards compatibility with listeners that expected the first param to be the channel name.
    end)
end

---@generic T
---@param channel string`T`
---@return SubscribableEvent<Net_Event_MessageReceived<`T`>>
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

Ext.Events.NetMessageReceived:Subscribe(function(ev)
    local payload = Ext.Json.Parse(ev.Payload)
    local event = {Message = payload, Channel = ev.Channel, UserID = ev.UserID} ---@type Net_Event_MessageReceived

    local subscribableEvent = Net._GetChannelMessageEvent(ev.Channel)

    subscribableEvent:Throw(event)

    -- The generic listener goes last.
    Net.Events.MessageReceived:Throw(event)
end)