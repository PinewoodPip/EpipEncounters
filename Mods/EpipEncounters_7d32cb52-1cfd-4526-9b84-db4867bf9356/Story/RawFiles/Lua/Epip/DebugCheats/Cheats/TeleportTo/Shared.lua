
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local _ = DebugCheats.RegisterAction("TeleportTo", {
    Name = DebugCheats.TranslatedStrings.TeleportTo_Name,
    Description = DebugCheats.TranslatedStrings.TeleportTo_Description,
    Contexts = {
        "TargetPosition",
        "SourceCharacter",
        "AffectParty",
    },
    InputActionID = "EpipEncounters_DebugTeleport",
})