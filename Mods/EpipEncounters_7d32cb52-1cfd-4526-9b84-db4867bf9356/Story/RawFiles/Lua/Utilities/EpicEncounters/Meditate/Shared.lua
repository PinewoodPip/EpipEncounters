
---@class EpicEncountersLib
local EpicEncounters = EpicEncounters

---@class EpicEncounters.MeditateLib
local Meditate = {
    NETMSG_REQUEST_MEDITATE = "EpicEncounters.MeditateLib.NetMsg.RequestMeditate",

    MEDITATE_SKILL_ID = "Shout_NexusMeditate",
}
Epip.InitializeLibrary("EpicEncounters.MeditateLib", Meditate)
EpicEncounters.Meditate = Meditate

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EpicEncounters.MeditateLib.NetMsg.RequestMeditate : NetLib_Message_Character