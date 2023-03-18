
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---@class Feature_DebugCheats_Action_String : Feature_DebugCheats_Action
---@field Subscribe fun(self:Feature_DebugCheats_Action_String, handler:fun(ev:Feature_DebugCheats_Event_ActionExecuted_String), opts:Event_Options?)
local _StringAction = {}
DebugCheats:RegisterClass("Feature_DebugCheats_Action_String", _StringAction, {"Feature_DebugCheats_Action"})

---------------------------------------------
-- STRUCTS
---------------------------------------------

---@class Feature_DebugCheats_Action_Context_String
---@field String string

---@class Feature_DebugCheats_Event_ActionExecuted_String : Feature_DebugCheats_Event_ActionExecuted
---@field Context Feature_DebugCheats_Action_Context_String

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an action.
---@param data Feature_DebugCheats_Action_String
---@return Feature_DebugCheats_Action_String
function _StringAction.Create(data)
    local instance = _StringAction:__Create(data) ---@type Feature_DebugCheats_Action_String

    return instance
end