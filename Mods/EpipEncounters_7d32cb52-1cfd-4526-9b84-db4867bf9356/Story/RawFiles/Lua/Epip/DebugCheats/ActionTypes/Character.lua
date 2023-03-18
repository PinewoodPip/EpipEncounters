
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---@class Feature_DebugCheats_Action_Character : Feature_DebugCheats_Action
---@field Subscribe fun(self:Feature_DebugCheats_Action_Character, handler:fun(ev:Feature_DebugCheats_Event_ActionExecuted_Character), opts:Event_Options?)
local _CharacterAction = {}
DebugCheats:RegisterClass("Feature_DebugCheats_Action_Character", _CharacterAction, {"Feature_DebugCheats_Action"})

---------------------------------------------
-- STRUCTS
---------------------------------------------

---@class Feature_DebugCheats_Action_Context_Character
---@field TargetCharacter Character

---@class Feature_DebugCheats_Event_ActionExecuted_Character : Feature_DebugCheats_Event_ActionExecuted
---@field Context Feature_DebugCheats_Action_Context_Character

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an action.
---@param data Feature_DebugCheats_Action_Character
---@return Feature_DebugCheats_Action_Character
function _CharacterAction.Create(data)
    local instance = _CharacterAction:__Create(data) ---@type Feature_DebugCheats_Action_Character

    return instance
end