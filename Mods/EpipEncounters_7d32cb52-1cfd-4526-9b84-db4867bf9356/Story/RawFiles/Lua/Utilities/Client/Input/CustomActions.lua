
---@class InputLib
local Input = Client.Input

Input._Actions = {} ---@type table<string, InputLib_Action>
Input._InputMap = {} ---@type table<string, string[]> Maps inputs to a list of actions that are bound to it.
Input._lastActionMapping = nil
Input._Bindings = {} ---@type table<string, InputLib_Action_Mapping>
Input._CurrentAction = nil ---@type string? ID of the action whose mapping is currently being held.

Input.ACTIONS_SAVE_FORMAT = 1
Input.ACTIONS_SAVE_FILENAME = "EpipEncounters_Input.json"

Input.ACTION_WHITELISTED_MOUSE_INPUTS = {
    -- left2 = true, -- Causes an issue with pressing the accept button, lol
    right2 = true,
    middle = true,
    wheel_xpos = true,
    wheel_xneg = true,
    wheel_ypos = true,
    wheel_yneg = true,
    x1 = true,
    x2 = true,
}

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class InputLib_Event_ActionExecuted
---@field Character EclCharacter
---@field Action InputLib_Action

---@class InputLib_Hook_CanExecuteAction
---@field Character EclCharacter
---@field Action InputLib_Action
---@field CanExecute boolean Hookable. Defaults to `true`.

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class InputLib_Action : Class, I_Identifiable
---@field Name string
---@field ID string
---@field DefaultInput1 InputLib_Action_KeyCombination?
---@field DefaultInput2 InputLib_Action_KeyCombination?
---@field DeveloperOnly boolean? If true, the action will only be usable in developer mode.
local _Action = {}
Interfaces.Apply(_Action, "I_Identifiable")
Input:RegisterClass("InputLib_Action", _Action)

---Creates an action.
---@param data InputLib_Action
---@return InputLib_Action
function _Action.Create(data)
    local instance = _Action:__Create(data) ---@cast instance InputLib_Action

    return instance
end

---@class InputLib_Action_Mapping
---@field ID string Action ID.
---@field Input1 InputLib_Action_KeyCombination
---@field Input2 InputLib_Action_KeyCombination
local _SavedKeybind = {}

---@param index integer
function _SavedKeybind:GetInputString(index)
    local field = "Input" .. Text.RemoveTrailingZeros(index)
    local input = self[field] ---@type InputLib_Action_KeyCombination
    local str = ""

    if input then
        str = Input.StringifyBinding(input)
    end

    return str
end

---@class InputLib_Action_KeyCombination
---@field Keys InputRawType[]

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers an action.
---@param id string
---@param data InputLib_Action
function Input.RegisterAction(id, data)
    data.ID = id
    local action = _Action.Create(data)

    Input._Actions[action.ID] = action
end

---Returns an action by its ID.
---@param id string
---@return InputLib_Action
function Input.GetAction(id)
    return Input._Actions[id]
end

---Get the saved keybinds for an action.
---@param action string
---@return InputLib_Action_Mapping
function Input.GetActionKeybinds(action)
    local keybind

    if Input._Bindings[action] then
        keybind = Input._Bindings[action]
        Inherit(keybind, _SavedKeybind) -- TODO improve
    else
        local actionData = Input.GetAction(action)
        ---@type InputLib_Action_Mapping
        keybind = {
            ID = action,
            Input1 = actionData.DefaultInput1,
            Input2 = actionData.DefaultInput2,
        }
        Inherit(keybind, _SavedKeybind)
    end

    return keybind
end

---@param actionID string
---@param bindingIndex integer
---@param keybind InputLib_Action_KeyCombination?
function Input.SetActionKeybind(actionID, bindingIndex, keybind)
    local savedBind = Input.GetActionKeybinds(actionID)

    if keybind then
        savedBind["Input" .. Text.RemoveTrailingZeros(bindingIndex)] = keybind
    else
        savedBind["Input" .. Text.RemoveTrailingZeros(bindingIndex)] = nil
    end

    Input._Bindings[actionID] = savedBind

    Input._SaveActionBindings()
end

---Returns whether an action can be currently executed.
---@param actionID string
---@return boolean
function Input.CanExecuteAction(actionID)
    local data = Input.GetAction(actionID)
    local canExecute = false

    if data then
        canExecute = Input.Hooks.CanExecuteAction:Throw({
            Character = Client.GetCharacter(),
            Action = data,
            CanExecute = true,
        }).CanExecute
    end

    return canExecute
end

---Stringifies a mapping. Use to compare binds for equality.
---@param binding InputLib_Action_KeyCombination
---@param useShortNames boolean? Defaults to false.
---@return string
function Input.StringifyBinding(binding, useShortNames)
    local keys = table.deepCopy(binding.Keys)
    local order = {
        lctrl = -1,
        rctrl = 0,
        lshift = 1,
        rshift = 2,
        lalt = 3,
        ralt = 4,
        lgui = 5,
        rgui = 6,
    }

    -- Sort keys to have modifiers keys at the front, in the order the regular UI shows them (ctrl, shift, then alt)
    table.sort(keys, function(a, b)
        if order[a] and order[b] then
            return order[a] < order[b]
        elseif order[a] then
            return true
        elseif order[b] then
            return false
        else
            return a < b
        end
    end)

    for i,key in ipairs(keys) do
        keys[i] = Input.GetInputName(key, useShortNames or false)
    end

    return table.concat(keys, " + ")
end

---Updates the input map. Call this every time after modifying the user's keybindings.
---@return table<string, string[]>
function Input._UpdateInputMap()
    local map = {}

    ---@param binding InputLib_Action_KeyCombination
    ---@param actionID string
    local function addAction(binding, actionID)
        local bindingStr = Input.StringifyBinding(binding)
        
        if not map[bindingStr] then
            map[bindingStr] = {}
        end

        table.insert(map[bindingStr], actionID)
    end

    for id,_ in pairs(Input._Actions) do
        local keybind = Input.GetActionKeybinds(id)

        if keybind.Input1 then
            addAction(keybind.Input1, id)
        end
        if keybind.Input2 then
            addAction(keybind.Input2, id)
        end
    end

    Input._InputMap = map

    return map
end

---Saves the user's bindings to the disk.
function Input._SaveActionBindings()
    local save = {
        Bindings = Input._Bindings,
        SaveVersion = Input.ACTIONS_SAVE_FORMAT,
    }

    IO.SaveFile(Input.ACTIONS_SAVE_FILENAME, save)
end

---Loads the user's bindings from the disk.
function Input._LoadActionBindings()
    local save = IO.LoadFile(Input.ACTIONS_SAVE_FILENAME)

    if save and save.Bindings and save.SaveVersion > 0 then
        Input._Bindings = save.Bindings
    end
end

---Fires the event for actions being released.
function Input._FireActionReleasedEvent()
    local action = Input.GetAction(Input._CurrentAction)

    if action then
        Input.Events.ActionReleased:Throw({
            Character = Client.GetCharacter(),
            Action = action,
        })
    
        Input._CurrentAction = nil
    else
        Input:LogWarning("_FireActionReleasedEvent() fired with no active action")
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Save data when the game is paused.
Utilities.Hooks.RegisterListener("GameState", "GamePaused", function()
    Input._SaveActionBindings()
end)

-- Load saved keybinds when the session loads.
Ext.Events.SessionLoaded:Subscribe(function()
    Input._LoadActionBindings()
    Input._UpdateInputMap()
end)

-- Default implementation for CanExecuteAction.
Input.Hooks.CanExecuteAction:Subscribe(function (ev)
    local data = ev.Action
    local execute = ev.CanExecute

    if data.DeveloperOnly and not Epip.IsDeveloperMode() then
        execute = false
    end

    if execute then
        execute = not Client.IsInDialogue() -- Cannot execute in dialogue.
        execute = execute and not GameState.IsPaused() -- Cannot execute in pause.
        execute = execute and Client.Input.IsAcceptingInput() -- Cannot execute while a UI is accepting text input.
    end

    ev.CanExecute = execute
end)

-- Listen for inputs and check if they should execute an action.
local function GetPressedKeys()
    local dummyBinding = {Keys = {}}

    for key,_ in pairs(Input.pressedKeys) do
        if (not Input.IsMouseInput(key) and not Input.IsTouchInput(key) or Input.ACTION_WHITELISTED_MOUSE_INPUTS[key]) then
            table.insert(dummyBinding.Keys, key)
        end
    end

    table.simpleSort(dummyBinding.Keys)

    return dummyBinding
end
Input.Events.KeyPressed:Subscribe(function (_)
    if Client.UI.OptionsInput:IsVisible() then return end -- TODO temp
    local dummyBinding = GetPressedKeys()
    if #dummyBinding.Keys == 0 then Input._lastActionMapping = nil return end
    local mapping = Input.StringifyBinding(dummyBinding)
    if mapping == Input._lastActionMapping then return end -- Prevents action spam from pressing excepted keys (ex. mouse) while holding others

    Input:DebugLog("Mapping pressed: ", mapping)

    local actions = Input._InputMap[mapping]
    if actions then
        for _,actionID in ipairs(actions) do
            if Input.CanExecuteAction(actionID) then
                Input.Events.ActionExecuted:Throw({
                    Character = Client.GetCharacter(),
                    Action = Input.GetAction(actionID),
                })

                if Input._CurrentAction then
                    Input._FireActionReleasedEvent()
                end

                Input._CurrentAction = actionID
            end
        end
    end

    Input._lastActionMapping = mapping
end)
Input.Events.KeyReleased:Subscribe(function (_)
    local dummyBinding = GetPressedKeys()
    local mapping = Input.StringifyBinding(dummyBinding)

    -- Fire event for releasing action mappings
    if #GetPressedKeys().Keys == 0 and Input._CurrentAction then
        Input._FireActionReleasedEvent()
    end

    Input._lastActionMapping = mapping
end)