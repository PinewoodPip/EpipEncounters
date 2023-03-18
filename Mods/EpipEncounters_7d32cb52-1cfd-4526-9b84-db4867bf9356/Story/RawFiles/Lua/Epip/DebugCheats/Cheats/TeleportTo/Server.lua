
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local action = DebugCheats.GetAction("TeleportTo") ---@cast action Feature_DebugCheats_Action_CharacterPosition

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the action being executed.
action:Subscribe(function (ev)
    local char = ev.Context.SourceCharacter
    local pos = ev.Context.Position
    
    Osiris.TeleportToPosition(char, pos[1], pos[2], pos[3], "", false, false)
end)