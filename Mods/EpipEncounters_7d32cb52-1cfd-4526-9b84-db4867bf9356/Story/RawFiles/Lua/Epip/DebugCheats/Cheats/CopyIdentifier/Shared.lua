
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local _ = DebugCheats.RegisterAction("CopyIdentifier", "Feature_DebugCheats_Action_Character", {
    Name = DebugCheats.TranslatedStrings.CopyIdentifier_Name,
    Description = DebugCheats.TranslatedStrings.CopyIdentifier_Description,
}) -- TODO change to entity