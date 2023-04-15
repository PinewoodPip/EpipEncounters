
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")
local Set = DataStructures.Get("DataStructures_Set")

---@class Feature_DebugCheats_Action : Class, I_Identifiable, I_Describable
---@field Contexts DataStructures_Set<Feature_DebugCheats_Context> Can pass a normal table list for constructor.
---@field OptionalContexts DataStructures_Set<Feature_DebugCheats_Context> Can pass a normal table list for constructor.
---@field ID string
---@field InputActionID string? The ID of the InputLib action that will trigger this action.
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
    data.Contexts = data.Contexts or {}
    data.OptionalContexts = data.OptionalContexts or {}
    if not OOP.IsClass(data.Contexts, "DataStructures_Set") then
        data.Contexts = Set.Create(data.Contexts)
    end
    if not OOP.IsClass(data.OptionalContexts, "DataStructures_Set") then
        data.OptionalContexts = Set.Create(data.OptionalContexts)
    end
    local instance = _Action:__Create(data) ---@cast instance Feature_DebugCheats_Action

    return instance
end

---Returns whether this action uses a certain context.
---@param contextID Feature_DebugCheats_Context|Feature_DebugCheats_Context[] A single context of list. If a list is passed, all contexts will need to be required for the function to return true.
---@return boolean
function _Action:RequiresContext(contextID)
    local requires = true

    if type(contextID) == "table" then
        for _,context in ipairs(contextID) do
            if not self.Contexts:Contains(context) and not self.OptionalContexts:Contains(context) then
                requires = false
                break
            end
        end
    else
        requires = self.Contexts:Contains(contextID)
    end

    return requires
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