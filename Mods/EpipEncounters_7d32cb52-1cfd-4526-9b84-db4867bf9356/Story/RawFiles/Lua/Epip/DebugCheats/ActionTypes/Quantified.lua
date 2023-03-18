
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---@class Feature_DebugCheats_Action_Quantified : Feature_DebugCheats_Action
---@field Subscribe fun(self:Feature_DebugCheats_Action_Quantified, handler:fun(ev:Feature_DebugCheats_Event_ActionExecuted_Quantified), opts:Event_Options?)
local _QuantifiedAction = {}
DebugCheats:RegisterClass("Feature_DebugCheats_Action_Quantified", _QuantifiedAction, {"Feature_DebugCheats_Action"})

---------------------------------------------
-- STRUCTS
---------------------------------------------

---@class Feature_DebugCheats_Action_Context_Quantified
---@field Amount number

---@class Feature_DebugCheats_Event_ActionExecuted_Quantified : Feature_DebugCheats_Event_ActionExecuted
---@field Context Feature_DebugCheats_Action_Context_Quantified

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an action.
---@param data Feature_DebugCheats_Action_Quantified
---@return Feature_DebugCheats_Action_Quantified
function _QuantifiedAction.Create(data)
    local instance = _QuantifiedAction:__Create(data) ---@type Feature_DebugCheats_Action_Quantified

    return instance
end