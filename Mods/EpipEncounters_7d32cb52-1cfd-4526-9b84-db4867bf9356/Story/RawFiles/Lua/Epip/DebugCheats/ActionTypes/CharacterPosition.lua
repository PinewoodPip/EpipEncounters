
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---@class Feature_DebugCheats_Action_CharacterPosition : Feature_DebugCheats_Action_Position, Feature_DebugCheats_Action_Character
---@field Subscribe fun(self:Feature_DebugCheats_Action_CharacterPosition, handler:fun(ev:Feature_DebugCheats_Event_ActionExecuted_Character|Feature_DebugCheats_Event_ActionExecuted_Position), opts:Event_Options?)
local _CharacterPositionAction = {}
DebugCheats:RegisterClass("Feature_DebugCheats_Action_CharacterPosition", _CharacterPositionAction, {"Feature_DebugCheats_Action_Position", "Feature_DebugCheats_Action_Character"})

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an action.
---@param data Feature_DebugCheats_Action_CharacterPosition
---@return Feature_DebugCheats_Action_CharacterPosition
function _CharacterPositionAction.Create(data)
    local instance = _CharacterPositionAction:__Create(data) ---@type Feature_DebugCheats_Action_CharacterPosition

    return instance
end