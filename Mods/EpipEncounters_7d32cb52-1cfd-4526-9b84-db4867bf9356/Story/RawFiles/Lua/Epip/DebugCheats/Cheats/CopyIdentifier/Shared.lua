
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local _ = DebugCheats.RegisterAction("CopyIdentifier", {
    Name = DebugCheats.TranslatedStrings.CopyIdentifier_Name,
    Description = DebugCheats.TranslatedStrings.CopyIdentifier_Description,
    Contexts = {
        "TargetGameObject",
    }
})