
---@class CharacterLib
local Character = Game.Character

---Returns a list of party members of char's party. Char must be a player.
---Depends on PlayerInfo.
---@param char EclCharacter
---@return EclCharacter[] Includes the char passed per param.
function Character.GetPartyMembers(char)
    local members = {}

    if char.IsPlayer then
        members = Client.UI.PlayerInfo.GetCharacters()

        local hasChar = false
        for _,member in ipairs(members) do
            if member.Handle == char.Handle then
                hasChar = true
            end
        end

        -- If char is not in the client's party, we cannot fetch its members.
        if not hasChar then
            Character:LogWarning(char.DisplayName .. " is not in the client's party; cannot fetch their party members on the client.")

            members = {}
        end
    end

    return members
end