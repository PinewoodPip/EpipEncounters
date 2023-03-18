
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---@class Feature_DebugCheats_Action_Item : Feature_DebugCheats_Action
---@field Subscribe fun(self:Feature_DebugCheats_Action_Item, handler:fun(ev:Feature_DebugCheats_Event_ActionExecuted_Item), opts:Event_Options?)
local _ItemAction = {}
DebugCheats:RegisterClass("Feature_DebugCheats_Action_Item", _ItemAction, {"Feature_DebugCheats_Action"})

---------------------------------------------
-- STRUCTS
---------------------------------------------

---@class Feature_DebugCheats_Action_Context_Item
---@field TargetItem Item

---@class Feature_DebugCheats_Event_ActionExecuted_Item : Feature_DebugCheats_Event_ActionExecuted
---@field Context Feature_DebugCheats_Action_Context_Item

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an action.
---@param data Feature_DebugCheats_Action_Item
---@return Feature_DebugCheats_Action_Item
function _ItemAction.Create(data)
    local instance = _ItemAction:__Create(data) ---@type Feature_DebugCheats_Action_Item

    return instance
end