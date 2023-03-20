
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local action = DebugCheats.GetAction("TeleportTo")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the action being executed.
action:Subscribe(function (ev)
    local char = ev.Context.SourceCharacter
    local pos = ev.Context.TargetPosition
    
    Osiris.TeleportToPosition(char, pos[1], pos[2], pos[3], "", ev.Context.AffectParty == true, false)
end)