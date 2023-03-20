
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local _ = DebugCheats.RegisterAction("CopyPosition", {
    Name = DebugCheats.TranslatedStrings.CopyPosition_Name,
    Description = DebugCheats.TranslatedStrings.CopyPosition_Description,
    Contexts = {
        "TargetPosition",
    }
})