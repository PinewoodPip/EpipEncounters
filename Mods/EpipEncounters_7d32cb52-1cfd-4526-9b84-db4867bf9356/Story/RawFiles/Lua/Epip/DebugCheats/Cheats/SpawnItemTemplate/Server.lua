
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local action = DebugCheats.GetAction("SpawnItemTemplate") ---@cast action Feature_DebugCheats_Action_ParametrizedCharacter

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the action being executed.
action:Subscribe(function (ev)
    local char = ev.Context.TargetCharacter
    local template = ev.Context.String
    local amount = ev.Context.Amount
    
    Osiris.ItemTemplateAddTo(template, char, amount, 1)
end)