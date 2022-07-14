
-- Ask each char of each user to unlock their inventory upon loading. The client can block this request based on their client settings.

-- When a client requests their inventories to be unlocked,
-- message all clients with the GUIDs of the chars whose inventories need to be unlocked.
local function AutoUnlockInventories(id)
    local chars = {}
    local users = {}

    for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
        local char = v[1]

        local user = CharacterGetReservedUserID(char)
        users[user] = true -- we always need to notify all clients

        chars[char] = user == id

        if chars[char] then
            Utilities.Log("PartyInventory", "Asking " .. char .. " to unlock inventory")
        end
    end

    for user,bool in pairs(users) do
        Ext.Net.PostMessageToUser(user, "EPIPENCOUNTERS_AutoUnlockPartyInventory", Ext.Json.Stringify({Chars = chars}))
    end
end

-- Ext.Osiris.RegisterListener("TimerFinished", 1, "after", function(id)
--     if id == "PIP_AutoUnlockInventories" then
--         AutoUnlockInventories()

--         -- Osi.TimerLaunch("PIP_AutoUnlockInventories", 20)
--     end
-- end)

-- function TestGen(item)
--     for i=1, 30, 1 do
--         Osi.GenerateTreasure(item, "AMER_GEN_Belt_Epic", i, "NULL_00000000-0000-0000-0000-000000000000");
--     end
--     Ext.Print("gend")
-- end

Net.RegisterListener("EPIPENCOUNTERS_AutoUnlockMe", function(cmd, payload)
    local user = CharacterGetReservedUserID(Ext.GetCharacter(payload.NetID).MyGuid)

    -- Osi.TimerLaunch("PIP_AutoUnlockInventories", 2000)
    AutoUnlockInventories(user)
end)