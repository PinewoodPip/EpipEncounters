
---------------------------------------------
-- Implements a user interface for binding InputLib actions.
---------------------------------------------

local Input = Client.Input

---@class Features.InputBinder : Feature
local InputBinder = {
    _CurrentRequest = nil, ---@type {ActionID:string, BindingIndex:integer}?

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    TranslatedStrings = {
        Header = {
           Handle = "h40211dabgcdfdg4c44gab1fgec11d398b801",
           Text = "Bind '%s'",
           ContextDescription = "Header for the UI. %s is replaced with the name of the action to bind.",
        },
        Hint = {
           Handle = "he0a23e3cgbf9cg4f6eg8aecg454ee29fe9d7",
           Text = "Press a key combination...",
           ContextDescription = "Hint on how to use the UI.",
        },
    },

    Events = {
        BindingRequested = {}, ---@type Event<{Action:InputLib_Action}>
        RequestCancelled = {}, ---@type Event<EmptyEvent>
        RequestCompleted = {}, ---@type Event<{Action:InputLib_Action, Binding:InputLib_Action_KeyCombination, Index:integer}>
    }
}
Epip.RegisterFeature("InputBinder", InputBinder)

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests setting the binding for an action.
---@param action InputLib_Action
---@param index integer
function InputBinder.RequestBinding(action, index)
    InputBinder._CurrentRequest = {
        ActionID = action:GetID(),
        BindingIndex = index,
    }

    InputBinder.Events.BindingRequested:Throw({
        Action = action,
    })
end

---Returns the action that is currently awaiting binding.
---@return InputLib_Action?
function InputBinder.GetCurrentRequest()
    return InputBinder._CurrentRequest and Input.GetAction(InputBinder._CurrentRequest.ActionID) or nil
end

---Completes the current binding request.
---@param binding InputLib_Action_KeyCombination?
function InputBinder.CompleteRequest(binding)
    if not InputBinder._CurrentRequest then
        InputBinder:Error("CompleteRequest", "There is no current request.")
    end

    local actionID = InputBinder._CurrentRequest.ActionID
    local index = InputBinder._CurrentRequest.BindingIndex
    local bindings = Input.GetActionBindings(actionID)
    if binding == nil then
        table.remove(bindings, index)
    elseif index > 1 and bindings[index - 1] == nil then -- Insert to the bindings if we're trying to bind to an index way beyond the list boundary
        table.insert(bindings, binding)
    else -- Otherwise push-back / replace
        bindings[index] = binding
    end

    InputBinder:DebugLog("Bound", actionID, index)
    InputBinder:Dump(bindings)

    Input.SetActionBindings(actionID, bindings)
    InputBinder.Events.RequestCompleted:Throw({
        Action = Input.GetAction(actionID),
        Binding = binding,
        Index = index,
    })
    InputBinder._CurrentRequest = nil
end

---Cancels the current binding request.
function InputBinder.CancelRequest()
    InputBinder._CurrentRequest = nil
    InputBinder.Events.RequestCancelled:Throw()
end