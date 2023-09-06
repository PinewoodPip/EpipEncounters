
---@class InputLib
local Input = Client.Input

Input._Actions = {} ---@type table<string, InputLib_Action>
Input._InputMap = {} ---@type table<string, string[]> Maps inputs to a list of actions that are bound to it.
Input._lastActionMapping = nil
Input._CurrentAction = nil ---@type string? ID of the action whose mapping is currently being held.
Input._ActionBindingSettingPrefix = "InputLib_Binding_"

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

---@class InputLib_Action : Class, I_Identifiable, I_Describable
---@field ID string
---@field DefaultInput1 InputLib_Action_KeyCombination?
---@field DefaultInput2 InputLib_Action_KeyCombination?
---@field DeveloperOnly boolean? If true, the action will only be usable in developer mode.
local _Action = {}
Interfaces.Apply(_Action, "I_Identifiable")
Interfaces.Apply(_Action, "I_Describable")
Input:RegisterClass("InputLib_Action", _Action)

---Creates an action.
---@param data InputLib_Action
---@return InputLib_Action
function _Action.Create(data)
    local instance = _Action:__Create(data) ---@cast instance InputLib_Action

    return instance
end

---@class InputLib_Action_KeyCombination
---@field Keys InputRawType[]

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers an action.
---@param id string
---@param data InputLib_Action
---@return InputLib_Action
function Input.RegisterAction(id, data)
    data.ID = id
    local action = _Action.Create(data)

    Input._Actions[action.ID] = action

    Settings.RegisterSetting({
        ID = Input._ActionBindingSettingPrefix .. id,
        ModTable = "InputLib",
        Type = "InputBinding",
        Context = "Client",
        Name = data.Name or data.NameHandle,
        Description = data.Description or data.DescriptionHandle,
        DefaultValue = {data.DefaultInput1, data.DefaultInput2},
        TargetActionID = id,
    })

    return action
end

---Returns an action by its ID.
---@param id string
---@return InputLib_Action
function Input.GetAction(id)
    return Input._Actions[id]
end

---Returns all registered actions.
---@return table<string, InputLib_Action>
function Input.GetActions()
    local actions = {}
    for k,v in pairs(Input._Actions) do
        actions[k] = v
    end
    return actions
end

---Returns all actions currently bound to the key combination.
---@param keyCombination InputLib_Action_KeyCombination
---@return InputLib_Action[] -- Empty if no actions are bound to the combination.
function Input.GetBoundActions(keyCombination)
    local actionIDs = Input._InputMap[Input.StringifyBinding(keyCombination)] or {}
    local actions = {}
    for i,id in ipairs(actionIDs) do
        actions[i] = Input.GetAction(id)
    end
    return actions
end

---Returns the setting that stores an action's bindings.
---@param actionID string
---@return SettingsLib.Settings.InputBinding
function Input.GetActionBindingSetting(actionID)
    local setting = Settings.GetSetting("InputLib", Input._ActionBindingSettingPrefix .. actionID) ---@cast setting SettingsLib.Settings.InputBinding
    return setting
end

---Returns the bindings of an action.
---@return InputLib_Action_KeyCombination[]
function Input.GetActionBindings(actionID)
    return Settings.GetSettingValue("InputLib", Input._ActionBindingSettingPrefix .. actionID)
end

---Sets the bindings for an action.
---@param actionID string
---@param bindings InputLib_Action_KeyCombination[]
function Input.SetActionBindings(actionID, bindings)
    Settings.SetValue("InputLib", Input._ActionBindingSettingPrefix .. actionID, bindings)
    Input._SaveActionBindings()
    Input._UpdateInputMap()
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
        local keybinds = Input.GetActionBindings(id)

        for _,keybind in ipairs(keybinds) do
            addAction(keybind, id)
        end
    end

    Input._InputMap = map

    return map
end

---Saves the user's bindings to the disk.
function Input._SaveActionBindings()
    Settings.Save("InputLib")
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

    local actions = Input.GetBoundActions(dummyBinding)
    for _,action in ipairs(actions) do
        if Input.CanExecuteAction(action:GetID()) then
            Input.Events.ActionExecuted:Throw({
                Character = Client.GetCharacter(),
                Action = action,
            })

            if Input._CurrentAction then
                Input._FireActionReleasedEvent()
            end

            Input._CurrentAction = action:GetID()
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