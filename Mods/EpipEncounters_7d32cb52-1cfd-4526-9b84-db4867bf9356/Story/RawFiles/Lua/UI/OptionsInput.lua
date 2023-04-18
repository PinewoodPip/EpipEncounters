
local Input = Client.Input

---@class OptionsInputUI : UI
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

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/optionsInput.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/optionsInput.swf",
    },

    Events = {
    },
    Hooks = {
        ---@type OptionsInput_Hook_ShouldRenderEntry
        ShouldRenderEntry = {},
    },
}
Epip.InitializeUI(13, "OptionsInput", Options)

---@class OptionsInputTab
---@field ID string
---@field Name string
---@field Label string?
---@field Keybinds InputLib_Action[]

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class OptionsInput_Hook_ShouldRenderEntry : Hook
---@field RegisterHook fun(self, handler:fun(render:boolean, entry:InputLib_Action))
---@field Return fun(self, render:boolean, entry:InputLib_Action)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether a keybind should show up in the UI.
---@param entry InputLib_Action
---@return boolean
function Options.ShouldRenderEntry(entry)
    ---@diagnostic disable-next-line: missing-return-value
    return Options.Hooks.ShouldRenderEntry:Return(true, entry)
end

---@param id string
---@param tab OptionsInputTab
function Options.RegisterTab(id, tab)
    tab.ID = id

    Options.CUSTOM_TABS[id] = tab
    table.insert(Options.TAB_ORDER, id)

    for _,bind in pairs(tab.Keybinds) do
        Input.RegisterAction(bind.ID, bind)
    end
end

---@param tabID string
---@param keybind InputLib_Action
function Options.AddEntry(tabID, keybind)
    local tabIndex = Options.tabIndexes[tabID]
    local root = Options:GetRoot()
    local id = keybind.ID
    local label = keybind.Name
    local savedBindings = Input.GetActionKeybinds(keybind.ID)

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

---@param binding InputLib_Action_KeyCombination
function Options.SetPotentialBinding(binding)
    if not Options.IsBindingKey() then Options:LogError("SetPotentialBinding called out of context!!!") return nil end

    Options.potentialBinding = binding

    local root = Options:GetRoot()

    root.changeOverlayText(Input.StringifyBinding(binding))
end

local function BindingFinished()
    Options.keyBeingBound = nil
    Options.potentialBinding = nil
    Options.indexBeingBound = nil

    Input._UpdateInputMap()

    Options:GetRoot().hideOverlay()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

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
    local dummyBinding = GetPressedKeys()
    if #dummyBinding.Keys == 0 then Input._lastActionMapping = nil return end
    local mapping = Input.StringifyBinding(dummyBinding)
    if mapping == Input._lastActionMapping then return end -- Prevents action spam from pressing excepted keys (ex. mouse) while holding others

    Input:DebugLog("Mapping pressed: ", mapping)

    if Options:IsVisible() then -- Set potention binding
        Options.SetPotentialBinding(dummyBinding)
    end
end)

Options.Hooks.ShouldRenderEntry:RegisterHook(function (render, entry)
    if entry.DeveloperOnly and not Epip.IsDeveloperMode() then
        render = false
    end
    ---@diagnostic disable-next-line: redundant-return-value
    return render
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

        Options:DebugLog("Bound " .. Options.keyBeingBound .. " to " .. Input.StringifyBinding(Options.potentialBinding))

        Input.SetActionKeybind(actionID, Options.indexBeingBound + 1, Options.potentialBinding)

        Options:GetRoot().setInput(table.reverseLookup(Options.entries, Options.keyBeingBound), Options.indexBeingBound, Input.StringifyBinding(Options.potentialBinding))

        BindingFinished()
        ev:PreventAction()

        Options:Dump(Input._Bindings)
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

        Input.SetActionKeybind(actionID, Options.indexBeingBound + 1, nil)
        
        Options:GetRoot().setInput(table.reverseLookup(Options.entries, Options.keyBeingBound), Options.indexBeingBound, "")

        BindingFinished()

        ev:PreventAction()
    end
end)

Options:RegisterCallListener("pipCustomTabPressed", function(_, buttonID)
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

Options:RegisterInvokeListener("initDone", function(_)
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
        --local previousElement = list[#list - 2]

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
            for _,keybind in ipairs(tab.Keybinds) do

                if Options.ShouldRenderEntry(keybind) then
                    Options.AddEntry(tabID, keybind)
                end
            end
        end)


        Options.nextCustomTabID = Options.nextCustomTabID + 1
    end

    -- root.controlsMenu_mc.menuBtnList.positionElements()
end, "After")