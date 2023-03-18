
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---@class Feature_DebugCheats_Action : Class, I_Identifiable, I_Describable
---@field ID string
local _Action = {}
DebugCheats:RegisterClass("Feature_DebugCheats_Action", _Action)
Interfaces.Apply(_Action, "I_Identifiable")
Interfaces.Apply(_Action, "I_Describable")

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an action.
---@param data Feature_DebugCheats_Action
---@return Feature_DebugCheats_Action
function _Action.Create(data)
    local instance = _Action:__Create(data) ---@cast instance Feature_DebugCheats_Action

    return instance
end

---Registers a handler for the action.
---@param handler fun(ev:Feature_DebugCheats_Event_ActionExecuted)
---@param opts Event_Options?
function _Action:Subscribe(handler, opts)
    DebugCheats.Events.ActionExecuted:Subscribe(function (ev)
        if ev.Action:GetID() == self:GetID() then
            handler(ev)
        end
    end, opts)
end