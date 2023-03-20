
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local _ = DebugCheats.RegisterAction("SpawnItemTemplate", {
    Name = DebugCheats.TranslatedStrings.SpawnItemTemplate_Name,
    Description = DebugCheats.TranslatedStrings.SpawnItemTemplate_Description,
    Contexts = {
        "Amount",
        "String",
        "TargetCharacter",
    },
})