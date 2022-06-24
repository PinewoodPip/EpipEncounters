
-- Returns a table containing the pairs of player guids and their EsvChars
function Utilities.GetPlayers()
    local players = {}
    for i,tuple in pairs(Osi.DB_IsPlayer:Get(nil)) do
        local guid = tuple[1]
        players[guid] = Ext.GetCharacter(guid)
    end
    return players
end

-- Gets the highest score all players have in an ability
-- Uses EsvCharacter, not the AMER DB
function Utilities.GetHighestPartyAbility(ability)
    local players = Utilities.GetPlayers()
    local highest = 0

    for guid,player in pairs(players) do
        local score = player.Stats[ability]

        if score > highest then
            highest = score
        end
    end

    return highest
end