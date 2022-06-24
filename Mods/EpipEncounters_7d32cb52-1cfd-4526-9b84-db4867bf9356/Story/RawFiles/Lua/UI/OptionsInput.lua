
---@class OptionsInputUI : Feature
---@field CUSTOM_TABS table<string, OptionsInputTab>
---@field TAB_ORDER string[]
---@field nextCustomTabID integer
---@field renderedCustomTabs table<integer, string>
---@field tabIndexes table<string, integer>
---@field nextEntryID integer
---@field entries table<integer, string>
---@field keyBeingBound? string
---@field indexBeingBound? integer
---@field potentialBinding? string
---@field BINDINGS table<string, OptionsInputSavedKeybind>
---@field ACTIONS table<string, OptionsInputKeybind>
---@field INPUT_MAP table<string, string[]> Maps keyboard inputs to a list of actions that are bound to it.

---@type OptionsInputUI
local Options = {
    CUSTOM_TABS = {

    },
    TAB_ORDER = {

    },
    nextCustomTabID = 20,
    ---@type table<integer, string>
    renderedCustomTabs = {},
    tabIndexes = {},
    nextEntryID = 200,
    entries = {},
    keyBeingBound = nil,
    indexBeingBound = nil,
    potentialBinding = nil,

    ACTIONS = {},
    BINDINGS = {},
    INPUT_MAP = {},

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/optionsInput.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/optionsInput.swf",
    },
    SAVE_FORMAT = 0,
    SAVE_FILENAME = "EpipEncounters_Input.json",

    Events = {
        ---@type OptionsInput_Event_ActionExecuted
        ActionExecuted = {},
    },
}
Epip.InitializeUI(13, "OptionsInput", Options)
Client.UI.OptionsInput = Options
Options:Debug()

---@class OptionsInputTab
---@field ID string
---@field Name string
---@field Label string?
---@field Keybinds OptionsInputKeybind[]

---@type OptionsInputTab
local _Tab = {Keybinds = {}, Name = "NO NAME"}

---@class OptionsInputKeybind
---@field Name string
---@field ID string
---@field DefaultInput1 string TODO
---@field DefaultInput2 string TODO

---@class OptionsInputSavedKeybind
---@field ID string
---@field Input1 OptionsInputBinding
---@field Input2 OptionsInputBinding

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class OptionsInput_Event_ActionExecuted : Event
---@field RegisterListener fun(self, listener:fun(action:string, binding:string))
---@field Fire fun(self, action:string, binding:string)

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

---Loads the user's bindings from the disk.
function Options.LoadBindings()
    local save = Utilities.LoadJson(Options.SAVE_FILENAME)

    if save and save.Bindings then
        Options.BINDINGS = save.Bindings
    end
end

---@param actionID string
---@param bindingIndex integer
---@param keybind string
function Options.SetKeybind(actionID, bindingIndex, keybind)
    local savedBind = Options.GetKeybinds(actionID)

    if keybind then
        savedBind["Input" .. RemoveTrailingZeros(bindingIndex)] = string.upper(keybind)
    else
        savedBind["Input" .. RemoveTrailingZeros(bindingIndex)] = nil
    end

    Options.BINDINGS[actionID] = savedBind

    Options.SaveBindings()
end

---Updates the input map. Call this every time after modifying the user's keybindings.
---@return table<string, string[]>
function Options.UpdateInputMap()
    local map = {}

    local function addAction(binding, actionID)
        if not map[binding] then
            map[binding] = {}
        end

        table.insert(map[binding], actionID)
    end

    for id,action in pairs(Options.ACTIONS) do
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

---@type OptionsInputSavedKeybind
local _SavedKeybind = {}

---@param index integer
function _SavedKeybind:GetShortInputString(index)
    local field = "Input" .. RemoveTrailingZeros(index)
    local input = self[field]
    local str = ""

    if input then
        str = input:gsub("SHIFT ", "^")
        str = str:gsub(" ", "")

        str = str:gsub("EX1", OptionsMenu:GetKey(243, true) or "")
        str = str:gsub("EX2", OptionsMenu:GetKey(253, true) or "")
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
---@return OptionsInputKeybind
function Options.GetActionData(action)
    return Options.ACTIONS[action]
end

---@param action OptionsInputKeybind
function Options.RegisterAction(action)
    Options.ACTIONS[action.ID] = action
end

---@param id string
---@param tab OptionsInputTab
function Options.RegisterTab(id, tab)
    tab.ID = id

    Options.CUSTOM_TABS[id] = tab
    table.insert(Options.TAB_ORDER, id)

    for k,bind in pairs(tab.Keybinds) do
        Options.RegisterAction(bind)
    end
end

---@param tabID string
---@param keybind OptionsInputKeybind
function Options.AddEntry(tabID, keybind)
    local tabIndex = Options.tabIndexes[tabID]
    local root = Options:GetRoot()
    local id = keybind.ID
    local label = keybind.Name
    local savedBindings = Options.GetKeybinds(keybind.ID)

    root.addEntry(tabIndex, Options.nextEntryID, label, savedBindings.Input1 or "", savedBindings.Input2 or "")

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

---@param key string
function Options.SetPotentialBinding(key)
    if not Options.IsBindingKey() then Options:LogError("SetPotentialBinding called out of context!!!") return nil end

    Options.potentialBinding = key

    local root = Options:GetRoot()

    root.changeOverlayText(string.upper(key))
end

local function BindingFinished()
    Options.keyBeingBound = nil
    Options.potentialBinding = nil
    Options.indexBeingBound = nil

    Options.UpdateInputMap()

    Options:GetRoot().hideOverlay()
end

local function PreppendModifiers(key)
    local shiftHeld = Client.Input.IsHoldingModifierKey()

    if shiftHeld then
        key = "Shift + " .. key
    end

    return key
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.Input.Events.KeyPressed:RegisterListener(function (key)
    key = PreppendModifiers(key)
    key = string.upper(key)

    local actions = Options.INPUT_MAP[key]
    if actions and not Utilities.isPaused then
        for i,actionID in ipairs(actions) do
            Options.Events.ActionExecuted:Fire(actionID, key)
        end
    end
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

Client.UI.Input.Events.KeyPressed:RegisterListener(function (key)
    if Options.IsBindingKey() then
        key = PreppendModifiers(key)

        Options.SetPotentialBinding(key)
    end
end)

Options:RegisterCallListener("inputAcceptPressed", function(ev)
    if Options.keyBeingBound then
        local actionID = Options.keyBeingBound

        Options:DebugLog("Bound " .. Options.keyBeingBound .. " to " .. Options.potentialBinding)

        Options.SetKeybind(actionID, Options.indexBeingBound + 1, Options.potentialBinding)

        Options:GetRoot().setInput(ReverseLookup(Options.entries, Options.keyBeingBound), Options.indexBeingBound, string.upper(Options.potentialBinding))

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

-- TODO figure out a better way to display these
-- Options:RegisterInvokeListener("addEntry", function(ev, tabID, id, str1, str2, str3)

--     if id == 243 or id == 253 then
--         Options:GetRoot().addEntry(1, id, str1, str2, str3)

--         ev:PreventAction()
--     end
-- end)

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
                Options.AddEntry(tabID, keybind)
            end
        end)


        Options.nextCustomTabID = Options.nextCustomTabID + 1
    end

    -- root.controlsMenu_mc.menuBtnList.positionElements()
end, "After")