
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local _ = DebugCheats.RegisterAction("TeleportTo", "Feature_DebugCheats_Action_CharacterPosition", {
    Name = DebugCheats.TranslatedStrings.TeleportTo_Name,
    Description = DebugCheats.TranslatedStrings.TeleportTo_Description,
})