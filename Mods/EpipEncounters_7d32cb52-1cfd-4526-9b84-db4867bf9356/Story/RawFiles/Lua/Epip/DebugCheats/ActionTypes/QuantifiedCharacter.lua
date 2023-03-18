
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---@class Feature_DebugCheats_Action_QuantifiedCharacter : Feature_DebugCheats_Action_Quantified, Feature_DebugCheats_Action_Character
---@field Subscribe fun(self:Feature_DebugCheats_Action_QuantifiedCharacter, handler:fun(ev:Feature_DebugCheats_Event_ActionExecuted_Character|Feature_DebugCheats_Event_ActionExecuted_Quantified), opts:Event_Options?)
local _QuantifiedCharacterAction = {}
DebugCheats:RegisterClass("Feature_DebugCheats_Action_QuantifiedCharacter", _QuantifiedCharacterAction, {"Feature_DebugCheats_Action_Quantified", "Feature_DebugCheats_Action_Character"})

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an action.
---@param data Feature_DebugCheats_Action_QuantifiedCharacter
---@return Feature_DebugCheats_Action_QuantifiedCharacter
function _QuantifiedCharacterAction.Create(data)
    local instance = _QuantifiedCharacterAction:__Create(data) ---@type Feature_DebugCheats_Action_QuantifiedCharacter

    return instance
end