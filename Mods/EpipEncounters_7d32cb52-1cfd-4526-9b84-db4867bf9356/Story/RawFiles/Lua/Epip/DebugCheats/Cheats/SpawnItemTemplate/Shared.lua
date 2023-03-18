
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local _ = DebugCheats.RegisterAction("SpawnItemTemplate", "Feature_DebugCheats_Action_ParametrizedCharacter", {
    Name = DebugCheats.TranslatedStrings.SpawnItemTemplate_Name,
    Description = DebugCheats.TranslatedStrings.SpawnItemTemplate_Description
})