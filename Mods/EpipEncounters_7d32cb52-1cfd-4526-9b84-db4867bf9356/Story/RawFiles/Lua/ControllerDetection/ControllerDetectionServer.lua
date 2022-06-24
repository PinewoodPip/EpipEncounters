
Ext.RegisterNetListener("EPICENCOUNTERS_ControllerUser_Answer", function(cmd, payload)
    local userId = Ext.Json.Parse(payload)

    -- storing the char guid is not good enough because you can reallocate characters between users with different input methods. We need the reserved user id
    local charGuid = Osi.GetCurrentCharacter(tonumber(userId))
    local char = Ext.GetCharacter(charGuid)

    Ext.Print("Received controller usage confirmation from player of " .. char.PlayerCustomData.Name)

    -- write to db in the next osiris frame
    Osi.DB_AMER_GEN_OUTPUT_Integer(userId)
end)

-- Clear the DB at the start of a session, as the reserved user ids become invalid. Then do a user event
Ext.Osiris.RegisterListener("SavegameLoaded", 4, "before", function(major, minor, patch, build)
    if (#Osi.DB_AMER_GEN_OUTPUT_Integer:Get(nil) > 0) then
        Osi.DB_AMER_GEN_OUTPUT_Integer:Delete(nil)
    end

    Osi.IterateUsers("PIP_ControllerUsageCheck")
end)

-- ask all users if they're using a controller
Ext.Osiris.RegisterListener("UserEvent", 2, "after", function(user, event)
    if event == "PIP_ControllerUsageCheck" then
        local char = Osi.GetCurrentCharacter(user) -- we need char guid to send it to a specific client

        Ext.Net.PostMessageToClient(char, "EPICENCOUNTERS_ControllerUser_Request", Ext.Json.Stringify(user))
    end
end)