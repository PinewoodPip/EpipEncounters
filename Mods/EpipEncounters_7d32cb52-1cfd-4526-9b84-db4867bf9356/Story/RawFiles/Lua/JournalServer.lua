
function OpenChangelog(char)
    Ext.Net.PostMessageToClient(char, "EPIPENCOUNTERS_OpenChangelog", Ext.Json.Stringify({
        mod = mod,
    }))
end

-- Open changelog from a choice box.
Ext.Osiris.RegisterListener("MessageBoxChoiceClosed", 3, "after", function(char, message, result)
    if result == "Open Patch Notes" then
        OpenChangelog(char)
    end
end)