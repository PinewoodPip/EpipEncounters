
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---@class Feature_DebugCheats_Action_ParametrizedCharacter : Feature_DebugCheats_Action_QuantifiedCharacter, Feature_DebugCheats_Action_String
---@field Subscribe fun(self:Feature_DebugCheats_Action_ParametrizedCharacter, handler:fun(ev:Feature_DebugCheats_Event_ActionExecuted_Quantified|Feature_DebugCheats_Event_ActionExecuted_String|Feature_DebugCheats_Event_ActionExecuted_Character), opts:Event_Options?)
local _ParametrizedCharacter = {}
DebugCheats:RegisterClass("Feature_DebugCheats_Action_ParametrizedCharacter", _ParametrizedCharacter, {"Feature_DebugCheats_Action_QuantifiedCharacter", "Feature_DebugCheats_Action_String"})

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an action.
---@param data Feature_DebugCheats_Action_ParametrizedCharacter
---@return Feature_DebugCheats_Action_ParametrizedCharacter
function _ParametrizedCharacter.Create(data)
    local instance = _ParametrizedCharacter:__Create(data) ---@type Feature_DebugCheats_Action_ParametrizedCharacter

    return instance
end