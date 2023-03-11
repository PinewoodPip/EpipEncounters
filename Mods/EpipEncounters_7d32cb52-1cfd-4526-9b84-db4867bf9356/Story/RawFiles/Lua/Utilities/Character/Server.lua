
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

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Forward status application events.
Ext.Events.BeforeStatusApply:Subscribe(function (ev)
    local status = ev.Status ---@type EsvStatus
    local owner = ev.Owner ---@type EsvCharacter|EsvItem

    Character.Events.StatusApplied:Throw({
        Status = status,
        SourceHandle = status.OwnerHandle,
        Victim = owner,
    })

    local ownerNetID = owner.NetID
    local statusNetID = status.NetID
    Timer.Start(0.2, function (_) -- Needs a delay. This message would otherwise arrive before the object is created on the client. TODO seek improvements
        Net.Broadcast("EPIP_CharacterLib_StatusApplied", {
            OwnerNetID = ownerNetID,
            StatusNetID = statusNetID,
        })
    end)
end, {Priority = -999999999})

-- Forward item equipped events.
Osiris.RegisterSymbolListener("ItemEquipped", 2, "after", function(itemGUID, charGUID)
    local char, item = Character.Get(charGUID), Item.Get(itemGUID)
    
    Character._ThrowItemEquippedEvent(char, item)

    Net.Broadcast("EPIP_CharacterLib_ItemEquipped", {
        CharacterNetID = char.NetID,
        ItemNetID = item.NetID,
    })
end)