
---@class EpicEncounters.MeditateLib
local Meditate = EpicEncounters.Meditate

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests to cast the meditate skill from the client character.
function Meditate.RequestMeditate()
    Net.PostToServer(Meditate.NETMSG_REQUEST_MEDITATE, {
        CharacterNetID = Client.GetCharacter().NetID,
    })
end