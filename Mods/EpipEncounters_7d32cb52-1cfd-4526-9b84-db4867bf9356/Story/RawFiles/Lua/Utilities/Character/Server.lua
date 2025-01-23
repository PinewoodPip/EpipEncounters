
---@class CharacterLib
local Character = Character

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns a list of party members of char's party. Char must be a player.
---@param char EsvCharacter
---@return EsvCharacter[] -- Includes the char passed per param.
function Character.GetPartyMembers(char)
    local members = {}

    local players = Osiris.QueryDatabase("DB_IsPlayer", nil)

    for _,tuple in ipairs(players) do
        local playerGUID = tuple[1]

        if char.MyGuid == playerGUID or Osiris.CharacterIsInPartyWith(char, playerGUID) == 1 then
            table.insert(members, Character.Get(playerGUID))
        end
    end

    return members
end

---Sets the cooldown of a skill.
---@param char EsvCharacter
---@param skillID skill Must be a skill the character has.
---@param cooldown number In seconds.
function Character.SetSkillCooldown(char, skillID, cooldown)
    local record = Character.GetSkill(char, skillID)
    if not record then Character:__Error("SetSkillCooldown", char.DisplayName, "has no skill", skillID) end

    record.ActiveCooldown = cooldown
    record.ShouldSyncCooldown = true -- Necessary for the change to sync correctly when not setting it to 0.
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

-- Forward death events.
Osiris.RegisterSymbolListener("CharacterDied", 1, "after", function (charGUID)
    Net.Broadcast(Character.NETMSG_CHARACTER_DIED, {
        CharacterNetID = Character.Get(charGUID).NetID,
    })
end)
