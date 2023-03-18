
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---@class Feature_DebugCheats_Action_Position : Feature_DebugCheats_Action
---@field Subscribe fun(self:Feature_DebugCheats_Action_Position, handler:fun(ev:Feature_DebugCheats_Event_ActionExecuted_Position), opts:Event_Options?)
local _PositionAction = {}
DebugCheats:RegisterClass("Feature_DebugCheats_Action_Position", _PositionAction, {"Feature_DebugCheats_Action"})

---------------------------------------------
-- STRUCTS
---------------------------------------------

---@class Feature_DebugCheats_Action_Context_Position
---@field Position Vector Can be of any arity.

---@class Feature_DebugCheats_Event_ActionExecuted_Position : Feature_DebugCheats_Event_ActionExecuted
---@field Context Feature_DebugCheats_Action_Context_Position

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an action.
---@param data Feature_DebugCheats_Action_Position
---@return Feature_DebugCheats_Action_Position
function _PositionAction.Create(data)
    local instance = _PositionAction:__Create(data) ---@type Feature_DebugCheats_Action_Position

    return instance
end