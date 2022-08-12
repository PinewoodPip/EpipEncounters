

---@class Net
Net = {
    INVALID_USER_ID = -65536,
}

Game.Net = Net -- Backwards compatibility

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

-- Wrapper for Ext.RegisterNetListener that parses json payload and fires a hookable event afterwards.
function Net.RegisterListener(channel, func)
    Ext.RegisterNetListener(channel, function(cmd, payload)
        local payload = Ext.Json.Parse(payload)
        func(channel, payload)
        Utilities.Hooks.FireEvent("PIP_Net", channel, payload) -- TODO make more easily registerable
    end)
end