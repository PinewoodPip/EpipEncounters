
function Net.PostToServer(channel, message)
    message = message or {}
    if type(message) ~= "string" then
        message = Ext.Json.Stringify(message)
    end
    Ext.Net.PostMessageToServer(channel, message)
end