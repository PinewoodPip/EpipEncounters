
---@class Feature_DebugMenu : Feature
local DebugMenu = {
    NETMSG_LIBRARY_STATE_CHANGED = "Features.ControlPanel.NetMsg.LibraryStateChanged",

    SAVE_FILENAME = "Epip_DebugMenu.json",
    SAVE_VERSION = 2,

    ---@type table<string, table<string, DebugMenu_State>>
    State = {},
}
Epip.RegisterFeature("DebugMenu", DebugMenu)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.ControlPanel.NetMsg.LibraryStateChanged
---@field ID string
---@field ModTableID string
---@field Property "Debug"|"Enabled"|"Logging"
---@field Value any

---------------------------------------------
-- STATE
---------------------------------------------

---@class DebugMenu_State
---@field ModTable string
---@field ID string
---@field Library Library
---@field Debug boolean
---@field LoggingLevel Library_LoggingLevel
---@field Enabled boolean
---@field DateTested string
---@field VersionTested integer
---@field TestsPassed integer
local _State = {TEST_CHECK_DELAY = 2}

---@return Feature
function _State:GetFeature()
    local feature = self.Library

    if not feature then
        local s

        s, feature = pcall(Epip.GetFeature, self.ModTable, self.ID)
        if not s then feature = nil end
    end

    return feature
end

---Returns a table representing the state.
---@return table
function _State:GetSaveData()
    return {
        ModTable = self.ModTable,
        ID = self.ID,
        Debug = self.Debug,
        LoggingLevel = self.LoggingLevel,
        Enabled = self.Enabled,
        DateTested = self.DateTested,
        VersionTested = self.VersionTested,
        TestsPassed = self.TestsPassed,
    }
end

function _State:RunTests()
    self.DateTested = Client.GetDateString()
    self.VersionTested = Epip.VERSION
    self.TestsPassed = 0

    for _,test in ipairs(self:GetFeature()._Tests) do
        test:Run()
    end

    -- Check test results after a delay as they might use sleep coroutines.
    Timer.Start(self.TEST_CHECK_DELAY, function (_)
        self:UpdateTestResults()
    end)
end

function _State:UpdateTestResults()
    for _,test in ipairs(self:GetFeature()._Tests) do
        if test:IsFinished() then
            self.TestsPassed[test.Name] = test.State == "Passed"
        end
    end
end

---@return string
function _State:GetTestingLabel()
    local formatting = {Color = Color.BLACK} ---@type TextFormatData
    local label = Text.Format("None available", formatting)
    local feature = self:GetFeature()

    if feature and feature._Tests then -- UIs have no _Tests field. TODO support tests on Library as a whole?
        local testCount = #feature._Tests

        if testCount > 0 then
            local passed = 0
            local ran = 0

            if self.DateTested ~= "Never" then -- Use cached results
                for _,result in pairs(self.TestsPassed) do
                    if result then passed = passed + 1 end
                    ran = ran + 1
                    -- Yes, this does not consider the possibility of failing a test, and then closing the game and going to sleep irl.
                end
            else
                for _,test in ipairs(self:GetFeature()._Tests) do -- Retrieve from tests
                    if test.State == "Passed" then
                        passed = passed + 1
                    end

                    if test.State ~= "NotRun" then
                        ran = ran + 1
                    end
                end
            end

            if testCount == 0 then
                label = Text.Format("None available", formatting)
            elseif self.DateTested == "Never" then
                formatting.FormatArgs = {testCount}
                label = Text.Format("Never ran (%s)", formatting)
            else
                local color = Color.LARIAN.DARK_BLUE
                if passed < ran then color = Color.RED end

                formatting.Color = color
                formatting.FormatArgs = {passed, ran, testCount, self.VersionTested}

                label = Text.Format("%s/%s Passed (total %s) on v%s", formatting)
            end
        end
    end

    return label
end

---@param testsPassed integer
function _State:SetTestingResults(testsPassed)
    self.DateTested = Client.GetDateString()
    self.TestsPassed = testsPassed
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param modTable string
---@param featureID string
function DebugMenu.GetState(modTable, featureID)
    local allStates = DebugMenu.State
    local state ---@type DebugMenu_State

    if not allStates[modTable] then allStates[modTable] = {} end

    if allStates[modTable][featureID] then
        state = allStates[modTable][featureID]
    else -- Initialize state
        state = {Debug = false, ShutUp = false, Enabled = true, DateTested = "Never", VersionTested = -1, TestsPassed = 0, ModTable = modTable, ID = featureID} ---@type DebugMenu_State

        if modTable == "_Client" and Ext.IsClient() then
            state.Library = Client.UI[featureID]
        end

        Inherit(state, _State)

        DebugMenu.State[modTable][featureID] = state
    end

    return state
end

---@param path string?
function DebugMenu.LoadConfig(path)
    path = path or DebugMenu.SAVE_FILENAME

    local config = IO.LoadFile(path)

    -- No backwards compatibility for DebugMenu configs.
    if config and config.Version == DebugMenu.SAVE_VERSION then
        for modTable,features in pairs(config.State) do
            for id,storedState in pairs(features) do
                local state = DebugMenu.GetState(modTable, id)

                local feature = state:GetFeature()
                if feature then
                    state.Debug = storedState.Debug
                    state.LoggingLevel = storedState.LoggingLevel
                    state.Enabled = storedState.Enabled

                    state.DateTested = storedState.DateTested
                    state.VersionTested = storedState.VersionTested
                    state.TestsPassed = storedState.TestsPassed

                    feature.Logging = state.LoggingLevel

                    if not state.Enabled then -- TODO improve
                        feature:Disable("DebugMenu")
                    end

                    feature.IS_DEBUG = state.Debug
                end
            end
        end
    end
end

---@param path string?
function DebugMenu.SaveConfig(path)
    local save = {
        State = DataStructures.Get("DataStructures_DefaultTable").Create({}),
        Version = DebugMenu.SAVE_VERSION
    }

    for module,states in pairs(DebugMenu.State) do -- Generate save data
        for id,featureState in pairs(states) do
            if not Text.Contains(id, "^PIP_.+") then
                save.State[module][id] = featureState:GetSaveData()
            end
        end
    end

    IO.SaveFile(path or DebugMenu.SAVE_FILENAME, save, nil, true)
end

---@param modTable string
---@param featureID string
---@param enabled boolean
function DebugMenu.SetEnabledState(modTable, featureID, enabled)
    local state = DebugMenu.GetState(modTable, featureID)

    state.Enabled = enabled

    state:GetFeature().Disabled = not enabled

    if Ext.IsClient() then
        Net.PostToServer(DebugMenu.NETMSG_LIBRARY_STATE_CHANGED, {
            ModTableID = modTable,
            ID = featureID,
            Property = "Enabled",
            Value = enabled,
        })
    end
end

---@param modTable string
---@param featureID string
---@param enabled boolean
function DebugMenu.SetDebugState(modTable, featureID, enabled)
    local state = DebugMenu.GetState(modTable, featureID)
    state.Debug = enabled

    state:GetFeature().IS_DEBUG = enabled

    if Ext.IsClient() then
        Net.PostToServer(DebugMenu.NETMSG_LIBRARY_STATE_CHANGED, {
            ModTableID = modTable,
            ID = featureID,
            Property = "Debug",
            Value = enabled,
        })
    end
end

---@param modTable string
---@param featureID string
---@param level Library_LoggingLevel
function DebugMenu.SetLoggingState(modTable, featureID, level)
    local state = DebugMenu.GetState(modTable, featureID)
    state.LoggingLevel = level

    state:GetFeature().Logging = level

    if Ext.IsClient() then
        Net.PostToServer(DebugMenu.NETMSG_LIBRARY_STATE_CHANGED, {
            ModTableID = modTable,
            ID = featureID,
            Property = "Logging",
            Value = level,
        })
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function (_)
    DebugMenu.LoadConfig()
end)