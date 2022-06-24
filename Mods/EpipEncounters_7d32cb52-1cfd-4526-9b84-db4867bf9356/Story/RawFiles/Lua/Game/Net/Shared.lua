
INVALID_USER_ID = -65536

function Game.Net.Broadcast(channel, message, excludedChar)
    message = message or {}
    Ext.Net.BroadcastMessage(channel, Utilities.Stringify(message), excludedChar)
end

function Game.Net.PostToCharacter(char, channel, message)
    Ext.Net.PostMessageToClient(char, channel, Utilities.Stringify(message or {}))
end

function Game.Net.PostToUser(user, channel, message, excludedChar)
    Ext.Net.PostMessageToUser(user, channel, Utilities.Stringify(message), excludedChar)
end

function Game.Net.PostToOwner(char, channel, message)
    if char.UserID ~= INVALID_USER_ID then
        Game.Net.PostToUser(char.UserID, channel, message)
    end
end

-- Wrapper for Ext.RegisterNetListener that parses json payload and fires a hookable event afterwards.
function Game.Net.RegisterListener(channel, func)
    Ext.RegisterNetListener(channel, function(cmd, payload)
        local payload = Ext.Json.Parse(payload)
        func(channel, payload)
        Utilities.Hooks.FireEvent("PIP_Net", channel, payload) -- TODO make more easily registerable
    end)
end