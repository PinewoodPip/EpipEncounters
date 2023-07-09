
---@class EpicEncounters_SourceInfusionLib
local SourceInfusion = EpicEncounters.SourceInfusion

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests to cast the Source Infuse spell from the client character.
function SourceInfusion.RequestInfuse()
    Net.PostToServer(SourceInfusion.NETMSG_REQUEST_INFUSE, {
        CharacterNetID = Client.GetCharacter().NetID,
    })
end