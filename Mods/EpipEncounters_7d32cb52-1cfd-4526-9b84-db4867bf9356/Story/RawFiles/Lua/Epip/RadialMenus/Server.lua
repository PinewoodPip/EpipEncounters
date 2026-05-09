
---@class Features.RadialMenus
local RadialMenus = Epip.GetFeature("Features.RadialMenus")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle requests to chain/unchain characters.
Net.RegisterListener(RadialMenus.NETMSG_TOGGLE_CHAIN, function (payload)
    local char = payload:GetCharacter()
    local target = Character.Get(payload.TargetNetID)
    if Osi.CharactersAreGrouped(char.MyGuid, target.MyGuid) == 1 then
        Osi.CharacterDetachFromGroup(char.MyGuid)
    else
        Osi.CharacterAttachToGroup(char.MyGuid, target.MyGuid)
    end
end)