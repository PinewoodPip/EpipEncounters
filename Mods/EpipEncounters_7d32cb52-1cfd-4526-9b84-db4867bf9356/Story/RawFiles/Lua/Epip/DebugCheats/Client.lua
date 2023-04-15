
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_DebugCheats_Hook_GetInputActionContext
---@field DebugCheatsAction Feature_DebugCheats_Action
---@field SourceInputAction InputLib_Action
---@field Context Feature_DebugCheats_Action_ContextData Hookable. See `DebugCheats._GetContextForInputAction()` for default value.

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the context for a cheat executing from a keybind.
---@param debugCheatsAction Feature_DebugCheats_Action
---@param inputAction InputLib_Action
---@return Feature_DebugCheats_Action_ContextData
function DebugCheats._GetContextForInputAction(debugCheatsAction, inputAction)
    local sourceChar = Client.GetCharacter()
    local targetChar = Pointer.GetCurrentCharacter(nil, true)
    local targetItem = Pointer.GetCurrentItem()
    local targetEntity = targetChar or targetItem
    local targetPosition

    if targetEntity then
        targetPosition = Vector.Create(targetEntity.WorldPos)
    else
        targetPosition = Pointer.GetWalkablePosition()
    end

    ---@type Feature_DebugCheats_Action_ContextData
    local context = {
        SourceCharacter = sourceChar,
        TargetCharacter = targetChar,
        SourcePosition = Vector.Create(sourceChar.WorldPos),
        TargetPosition = targetPosition,
        TargetItem = targetItem,
        TargetGameObject = targetEntity,
        String = nil,
        Amount = nil,
        AffectParty = Client.Input.IsShiftPressed(),
    }

    context = DebugCheats.Hooks.GetInputActionContext:Throw({
        SourceInputAction = inputAction,
        DebugCheatsAction = debugCheatsAction,
        Context = context,
    }).Context

    return context
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for input actions that are bound to debug cheat actions.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    local cheatAction = nil ---@type Feature_DebugCheats_Action?

    for _,action in pairs(DebugCheats._Actions) do
        if action.InputActionID == ev.Action:GetID() then
            cheatAction = action
            break
        end
    end

    if cheatAction then
        local context = DebugCheats._GetContextForInputAction(cheatAction, ev.Action)

        DebugCheats.ExecuteAction(cheatAction:GetID(), context)
    end
end)