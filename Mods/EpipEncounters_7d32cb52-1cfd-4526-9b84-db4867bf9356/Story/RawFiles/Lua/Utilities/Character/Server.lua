
---@class CharacterLib
local Character = Character

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns a list of party members of char's party. Char must be a player.
---@param char EsvCharacter
---@return EsvCharacter[] Includes the char passed per param.
function Character.GetPartyMembers(char)
    local members = {}

    local players = Osiris.DB_IsPlayer:GetTuples(nil)

    for _,tuple in ipairs(players) do
        local playerGUID = tuple[1]

        if char.MyGuid == playerGUID or Osiris.CharacterIsInPartyWith(char, playerGUID) == 1 then
            table.insert(members, Character.Get(playerGUID))
        end
    end

    return members
end