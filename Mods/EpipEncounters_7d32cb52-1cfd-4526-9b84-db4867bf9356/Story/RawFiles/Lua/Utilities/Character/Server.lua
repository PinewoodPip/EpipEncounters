
---@class CharacterLib
local Character = Character

local _ClientStatusAppliedEventEnabled = false

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
local StatusAppliedEvent = Character.Events.StatusApplied
Ext.Events.BeforeStatusApply:Subscribe(function (ev)
    if StatusAppliedEvent.First == nil and not _ClientStatusAppliedEventEnabled then return end
    local status = ev.Status ---@type EsvStatus
    local owner = ev.Owner ---@type EsvCharacter|EsvItem
    local ownerGUID = owner.MyGuid

    StatusAppliedEvent:Throw({
        Status = status,
        SourceHandle = status.OwnerHandle,
        Victim = owner,
    })

    if _ClientStatusAppliedEventEnabled then
        local ownerNetID = owner.NetID
        local statusNetID = status.NetID
        Timer.Start(0.2, function (_) -- Needs a delay. This message would otherwise arrive before the object is created on the client. TODO seek improvements
            if Osi.ObjectExists(ownerGUID) == 0 then return end -- Do not send message if the entity died in the meantime.
            Net.Broadcast("EPIP_CharacterLib_StatusApplied", {
                OwnerNetID = ownerNetID,
                StatusNetID = statusNetID,
            })
        end)
    end
end, {Priority = -999999999})

-- Forward item equipped events.
Osiris.RegisterSymbolListener("ItemEquipped", 2, "after", function(itemGUID, charGUID)
    if Osi.ObjectExists(charGUID) == 0 or Osi.ObjectExists(itemGUID) == 0 then return end -- Occurs during character creation when dummies are transformed.
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

-- Enable forwarding StatusApplied events to client when requested.
-- These are disabled by default to avoid unnecessary NetMsg overhead.
Net.RegisterListener(Character._NETMSG_ENABLED_STATUS_EVENTS, function (_)
    _ClientStatusAppliedEventEnabled = true
end)
