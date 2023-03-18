
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local _ = DebugCheats.RegisterAction("CopyPosition", "Feature_DebugCheats_Action_Position", {
    Name = DebugCheats.TranslatedStrings.CopyPosition_Name,
    Description = DebugCheats.TranslatedStrings.CopyPosition_Description,
}) -- TODO change to entity