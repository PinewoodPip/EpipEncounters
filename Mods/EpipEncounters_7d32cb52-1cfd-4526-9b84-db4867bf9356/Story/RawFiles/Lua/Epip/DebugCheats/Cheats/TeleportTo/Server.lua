
-- Listen for requests to teleport.
Net.RegisterListener("EPIPENCOUNTERS_CHEATS_TeleportChar", function(payload)
    local char = payload:GetCharacter()
    local pos = payload.Position
    local teleportParty = payload.TeleportParty
    local charsToTeleport = {}

    if teleportParty then
        local partyChars = Character.GetPartyMembers(char)

        for _,partyMember in ipairs(partyChars) do
            table.insert(charsToTeleport, partyMember)
        end
    else
        charsToTeleport = {char}
    end

    for _,charToTeleport in ipairs(charsToTeleport) do
        Osiris.TeleportToPosition(charToTeleport, pos[1], pos[2], pos[3], "", 0)
    end
end)