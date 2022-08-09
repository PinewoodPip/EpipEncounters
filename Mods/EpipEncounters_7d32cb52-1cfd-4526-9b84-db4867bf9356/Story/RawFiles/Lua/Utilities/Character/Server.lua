
---@class CharacterLib
local Character = Game.Character

---Returns a list of party members of char's party. Char must be a player.
---@param char EsvCharacter
---@return EsvCharacter[] Includes the char passed per param.
function Character.GetPartyMembers(char)
    local members = {}

    local players = Osiris.DB_IsPlayer:GetTuples(nil)

    for _,playerGUID in ipairs(players) do
        if char.MyGuid == playerGUID or Osi.CharacterIsInPartyWith(char.MyGuid, playerGUID) == 1 then
            table.insert(members, Character.Get(playerGUID))
        end
    end

    return members
end