
---@class OptionsInputUI : Feature
local Options = {
    nextCustomTabID = 20,
    ---@type table<integer, string>
    renderedCustomTabs = {},
    tabIndexes = {},
    nextEntryID = 200,
    entries = {},
    keyBeingBound = nil,
    indexBeingBound = nil,
    potentialBinding = nil,

    CUSTOM_TABS = {}, ---@type table<string, OptionsInputTab>
    TAB_ORDER = {},
    ACTIONS = {}, ---@type table<string, OptionsInputAction>
    BINDINGS = {}, ---@type table<string, OptionsInputSavedKeybind>
    INPUT_MAP = {}, ---@type table<string, string[]> Maps keyboard inputs to a list of actions that are bound to it.

    WHITELISTED_MOUSE_INPUTS = {
        -- left2 = true, -- Causes an issue with pressing the accept button, lol
        right2 = true,
        middle = true,
        wheel_xpos = true,
        wheel_xneg = true,
        wheel_ypos = true,
        wheel_yneg = true,
        x1 = true,
        x2 = true,
    },

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/optionsInput.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/optionsInput.swf",
    },
    SAVE_FORMAT = 1,
    SAVE_FILENAME = "EpipEncounters_Input.json",

    Events = {
        ---@type OptionsInput_Event_ActionExecuted
        ActionExecuted = {},
    },
    Hooks = {
        ---@type OptionsInput_Hook_ShouldRenderEntry
        ShouldRenderEntry = {},
        ---@type OptionsInput_Hook_CanExecuteAction
        CanExecuteAction = {},
    },
}
if IS_IMPROVED_HOTBAR then
    Options.FILEPATH_OVERRIDES = {}
end
Epip.InitializeUI(13, "OptionsInput", Options)
Client.UI.OptionsInput = Options
Options:Debug()

---@class OptionsInputTab
---@field ID string
---@field Name string
---@field Label string?
---@field Keybinds OptionsInputAction[]

---@class OptionsInputKeybind
---@field Keys InputRawType[]

---@class OptionsInputAction
---@field Name string
---@field ID string
---@field DefaultInput1 OptionsInputKeybind?
---@field DefaultInput2 OptionsInputKeybind?
---@field DeveloperOnly boolean? If true, the binding will not be visible in the UI outside of developer mode (and won't function either)

---@class OptionsInputSavedKeybind
---@field ID string
---@field Input1 OptionsInputKeybind
---@field Input2 OptionsInputKeybind

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class OptionsInput_Event_ActionExecuted : Event
---@field RegisterListener fun(self, listener:fun(action:string, binding:OptionsInputKeybind))
---@field Fire fun(self, action:string, binding:string)

---@class OptionsInput_Hook_ShouldRenderEntry : Hook
---@field RegisterHook fun(self, handler:fun(render:boolean, entry:OptionsInputAction))
---@field Return fun(self, render:boolean, entry:OptionsInputAction)

---@class OptionsInput_Hook_CanExecuteAction : Hook
---@field RegisterHook fun(self, handler:fun(execute:boolean, action:string, data:OptionsInputAction))
---@field Return fun(self, execute:boolean, action:string, data:OptionsInputAction)

---------------------------------------------
-- METHODS
---------------------------------------------

---Saves the user's bindings to the disk.
function Options.SaveBindings()
    local save = {
        Bindings = Options.BINDINGS,
        SaveVersion = Options.SAVE_FORMAT,
    }

    Utilities.SaveJson(Options.SAVE_FILENAME, save)
end

---Returns whether a keybind should show up in the UI.
---@param entry OptionsInputAction
---@return boolean
function Options.ShouldRenderEntry(entry)
    return Options.Hooks.ShouldRenderEntry:Return(true, entry)
end

---Returns whether an action can be currently executed.
---@param actionID string
---@return boolean
function Options.CanExecuteAction(actionID)
    local data = Options.GetActionData(actionID)
    local canExecute = false

    if data then
        canExecute = Options.Hooks.CanExecuteAction:Return(true, actionID, data)
    end

    return canExecute
end

---Loads the user's bindings from the disk.
function Options.LoadBindings()
    local save = Utilities.LoadJson(Options.SAVE_FILENAME)

    if save and save.Bindings and save.SaveVersion > 0 then
        Options.BINDINGS = save.Bindings
    end
end

---@param actionID string
---@param bindingIndex integer
---@param keybind OptionsInputKeybind
function Options.SetKeybind(actionID, bindingIndex, keybind)
    local savedBind = Options.GetKeybinds(actionID)

    if keybind then
        savedBind["Input" .. Text.RemoveTrailingZeros(bindingIndex)] = keybind
    else
        savedBind["Input" .. Text.RemoveTrailingZeros(bindingIndex)] = nil
    end

    Options.BINDINGS[actionID] = savedBind

    Options.SaveBindings()
end

---Stringifies an OptionsInputKeybind table. Use to compare binds for equality.
---@param binding OptionsInputKeybind
---@return string
function Options.StringifyBinding(binding)
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
        keys[i] = Client.Input.GetInputName(key, true)
    end

    return table.concat(keys, " + ")
end

---Updates the input map. Call this every time after modifying the user's keybindings.
---@return table<string, string[]>
function Options.UpdateInputMap()
    local map = {}

    ---@param binding OptionsInputKeybind
    ---@param actionID string
    local function addAction(binding, actionID)
        local bindingStr = Options.StringifyBinding(binding)
        
        if not map[bindingStr] then
            map[bindingStr] = {}
        end

        table.insert(map[bindingStr], actionID)
    end

    for id,_ in pairs(Options.ACTIONS) do
        local keybind = Options.GetKeybinds(id)

        if keybind.Input1 then
            addAction(keybind.Input1, id)
        end
        if keybind.Input2 then
            addAction(keybind.Input2, id)
        end
    end

    Options.INPUT_MAP = map

    return map
end

---@class OptionsInputSavedKeybind
local _SavedKeybind = {}

---@param index integer
function _SavedKeybind:GetInputString(index)
    local field = "Input" .. Text.RemoveTrailingZeros(index)
    local input = self[field] ---@type OptionsInputKeybind
    local str = ""

    if input then
        str = Options.StringifyBinding(input)
    end

    return str
end

---Get the saved keybinds for an action.
---@param action string
---@return OptionsInputSavedKeybind
function Options.GetKeybinds(action)
    local keybind

    if Options.BINDINGS[action] then
        keybind = Options.BINDINGS[action]
        Inherit(keybind, _SavedKeybind) -- TODO improve
    else
        local actionData = Options.GetActionData(action)
        ---@type OptionsInputSavedKeybind
        keybind = {
            ID = action,
            Input1 = actionData.DefaultInput1,
            Input2 = actionData.DefaultInput2,
        }
        Inherit(keybind, _SavedKeybind)
    end

    return keybind
end

---Get the data for a custom action.
---@return OptionsInputAction
function Options.GetActionData(action)
    return Options.ACTIONS[action]
end

---@param action OptionsInputAction
function Options.RegisterAction(action)
    Options.ACTIONS[action.ID] = action
end

---@param id string
---@param tab OptionsInputTab
function Options.RegisterTab(id, tab)
    tab.ID = id

    Options.CUSTOM_TABS[id] = tab
    table.insert(Options.TAB_ORDER, id)

    for _,bind in pairs(tab.Keybinds) do
        Options.RegisterAction(bind)
    end
end

---@param tabID string
---@param keybind OptionsInputAction
function Options.AddEntry(tabID, keybind)
    local tabIndex = Options.tabIndexes[tabID]
    local root = Options:GetRoot()
    local id = keybind.ID
    local label = keybind.Name
    local savedBindings = Options.GetKeybinds(keybind.ID)

    root.addEntry(tabIndex, Options.nextEntryID, label, savedBindings:GetInputString(1) or "", savedBindings:GetInputString(2) or "")

    Options.entries[Options.nextEntryID] = id
    Options.nextEntryID = Options.nextEntryID + 1

    root.controlsMenu_mc.tab_content_array[tabIndex].content_mc.positionElements()

    Options:DebugLog("Added entry " .. id .. " to tab " .. tabID .. " with ID " .. tostring(Options.nextEntryID - 1))
end

---@param tabID integer
function Options.GetTabIndex(tabID)
    local index = 0
    local root = Options:GetRoot()
    local list = root.controlsMenu_mc.tabList.content_array

    for i=0,#list-1,1 do
        local element = list[i]

        if element.id == tabID then
            index = i
            break
        end
    end

    return index
end

---@return boolean
function Options.IsBindingKey()
    return Options.keyBeingBound ~= nil
end

---@param binding OptionsInputKeybind
function Options.SetPotentialBinding(binding)
    if not Options.IsBindingKey() then Options:LogError("SetPotentialBinding called out of context!!!") return nil end

    Options.potentialBinding = binding

    local root = Options:GetRoot()

    root.changeOverlayText(Options.StringifyBinding(binding))
end

local function BindingFinished()
    Options.keyBeingBound = nil
    Options.potentialBinding = nil
    Options.indexBeingBound = nil

    Options.UpdateInputMap()

    Options:GetRoot().hideOverlay()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Options.Hooks.ShouldRenderEntry:RegisterHook(function (render, entry)
    if entry.DeveloperOnly and not Epip.IsDeveloperMode() then
        render = false
    end
    return render
end)

local function GetPressedKeys()
    local dummyBinding = {Keys = {}}

    for key,_ in pairs(Client.Input.pressedKeys) do
        if (not Client.Input.IsMouseInput(key) and not Client.Input.IsTouchInput(key) or Options.WHITELISTED_MOUSE_INPUTS[key]) then
            table.insert(dummyBinding.Keys, key)
        end
    end

    table.simpleSort(dummyBinding.Keys)

    return dummyBinding
end

Client.Input.Events.KeyPressed:Subscribe(function (e)
    local dummyBinding = GetPressedKeys()
    if #dummyBinding.Keys == 0 then Options.lastMappingPressed = nil return nil end
    local mapping = Options.StringifyBinding(dummyBinding)
    if mapping == Options.lastMappingPressed then return nil end -- Prevents action spam from pressing excepted keys (ex. mouse) while holding others

    Options:DebugLog("Mapping pressed: ", mapping)

    if Options.IsBindingKey() then -- Set potention binding
        Options.SetPotentialBinding(dummyBinding)
    else -- Fire action
        local actions = Options.INPUT_MAP[mapping]
        if actions and not GameState.IsPaused() then
            for _,actionID in ipairs(actions) do
                if Options.CanExecuteAction(actionID) then
                    Options.Events.ActionExecuted:Fire(actionID, dummyBinding)
                end
            end
        end
    end

    Options.lastMappingPressed = mapping
end)

Client.Input.Events.KeyReleased:Subscribe(function (e)
    local dummyBinding = GetPressedKeys()
    local mapping = Options.StringifyBinding(dummyBinding)
    Options.lastMappingPressed = mapping
end)

-- Developer-only actions cannot be executed outside of developer mode.
-- Actions cannot be executed in dialogue.
Options.Hooks.CanExecuteAction:RegisterHook(function (execute, action, data)
    if data.DeveloperOnly and not Epip.IsDeveloperMode() then
        execute = false
    end

    if execute then
        execute = not Client.IsInDialogue()
    end

    return execute
end)

-- Save data when the game is paused.
Utilities.Hooks.RegisterListener("GameState", "GamePaused", function()
    Options.SaveBindings()
end)

Ext.Events.SessionLoaded:Subscribe(function()
    Options.LoadBindings()
    Options.UpdateInputMap()
end)

Options:RegisterCallListener("changingKey", function(ev, key, binding)
    if Options.entries[key] then
        Options.keyBeingBound = Options.entries[key]
        Options.indexBeingBound = binding
        ev:PreventAction()
    end
end)

Options:RegisterCallListener("inputAcceptPressed", function(ev)
    if Options.keyBeingBound then
        local actionID = Options.keyBeingBound

        Options:DebugLog("Bound " .. Options.keyBeingBound .. " to " .. Options.StringifyBinding(Options.potentialBinding))

        Options.SetKeybind(actionID, Options.indexBeingBound + 1, Options.potentialBinding)

        Options:GetRoot().setInput(ReverseLookup(Options.entries, Options.keyBeingBound), Options.indexBeingBound, Options.StringifyBinding(Options.potentialBinding))

        BindingFinished()
        ev:PreventAction()

        Options:Dump(Options.BINDINGS)
    end
end)

Options:RegisterCallListener("inputCancelPressed", function(ev)
    if Options.keyBeingBound then
        Options:DebugLog("Cancelled binding")

        BindingFinished()
        ev:PreventAction()
    end
end)

Options:RegisterCallListener("inputClearPressed", function(ev)
    if Options.keyBeingBound then
        local actionID = Options.keyBeingBound

        Options:DebugLog("Cleared binding")

        Options.SetKeybind(actionID, Options.indexBeingBound + 1, nil)
        
        Options:GetRoot().setInput(ReverseLookup(Options.entries, Options.keyBeingBound), Options.indexBeingBound, "")

        BindingFinished()

        ev:PreventAction()
    end
end)

Options:RegisterCallListener("pipCustomTabPressed", function(ev, buttonID)
    local tab = Options.CUSTOM_TABS[Options.renderedCustomTabs[buttonID]]
    local index = Options.tabIndexes[tab.ID]

    Options:DebugLog("Tab selected: " .. tab.Name .. " index " .. tostring(index))

    Options:GetRoot().selectContent(buttonID)

    -- TODO deselect buttons
end)

-- Allow going back to the normal tab without the UI being closed.
Options:RegisterCallListener("switchMenu", function(ev, id)
    if id == 4 then
        ev:PreventAction()

        Options:GetRoot().selectContent(0)
    end
end)

Options:RegisterInvokeListener("initDone", function(ev)
    if IS_IMPROVED_HOTBAR then return nil end
    
    local root = Options:GetRoot()

    Options:DebugLog("Rendering custom tabs")

    Options.tabIndexes = {}
    Options.nextCustomTabID = 20
    Options.nextEntryID = 1337

    for i,tabID in ipairs(Options.TAB_ORDER) do
        local tab = Options.CUSTOM_TABS[tabID]
        local numID = Options.nextCustomTabID
        root.controlsMenu_mc.addMenuButton(tab.Name, "pipCustomTabPressed", Options.nextCustomTabID, root.controlsMenu_mc.oldContent == i) -- TODO iscurrent

        Options.tabIndexes[tabID] = i
        Options.renderedCustomTabs[Options.nextCustomTabID] = tabID

        local list = root.controlsMenu_mc.menuBtnList.content_array
        local element = list[#list - 1]
        local previousElement = list[#list - 2]

        -- Can't get this to work smoothly for some unknown reason.
        Ext.OnNextTick(function()
            root.controlsMenu_mc.menuBtnList.y = root.controlsMenu_mc.menuBtnList.y - element.height - 2

            Ext.OnNextTick(function()
                element.y = element.y + 305
            
            end)

            -- Add tab
            root.addTab(numID, "UNUSED TEXT")

            if tab.Label then
                root.addTitle(i, tab.Label)
            end

            -- TODO finish
            -- root.addEntry(i, 243, label, savedBindings.Input1 or "", savedBindings.Input2 or "")
            -- root.addEntry(i, 253, label, savedBindings.Input1 or "", savedBindings.Input2 or "")

            -- Render keybinds
            for z,keybind in ipairs(tab.Keybinds) do

                if Options.ShouldRenderEntry(keybind) then
                    Options.AddEntry(tabID, keybind)
                end
            end
        end)


        Options.nextCustomTabID = Options.nextCustomTabID + 1
    end

    -- root.controlsMenu_mc.menuBtnList.positionElements()
end, "After")