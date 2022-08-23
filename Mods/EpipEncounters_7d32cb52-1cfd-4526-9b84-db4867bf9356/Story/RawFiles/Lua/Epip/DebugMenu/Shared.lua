
---@class Feature_DebugMenu : Feature
local DebugMenu = {
    SAVE_FILENAME = "Epip_DebugMenu.json",
    SAVE_VERSION = 1,

    ---@type table<string, table<string, DebugMenu_State>>
    State = {},
}
Epip.RegisterFeature("DebugMenu", DebugMenu)

---@class DebugMenu_State
---@field Debug boolean
---@field LoggingLevel Feature_LoggingLevel
---@field Enabled boolean
---@field GetFeature fun(self:DebugMenu_State):Feature

---------------------------------------------
-- METHODS
---------------------------------------------

---@param modTable string
---@param featureID string
function DebugMenu.GetState(modTable, featureID)
    local allStates = DebugMenu.State
    local state = {Debug = false, ShutUp = false, Enabled = true} ---@type DebugMenu_State
    setmetatable(state, {
        __index = function(self, key, ...)
            if key == "GetFeature" then
                return function(...) return Epip.GetFeature(modTable, featureID) end
            end
        end
    })

    if not allStates[modTable] then allStates[modTable] = {} end

    if allStates[modTable][featureID] then
        state = allStates[modTable][featureID]
    else -- Initialize state
        DebugMenu.State[modTable][featureID] = state
    end

    return state
end

---@param path string?
function DebugMenu.LoadConfig(path)
    path = path or DebugMenu.SAVE_FILENAME

    local config = Utilities.LoadJson(path)

    -- No backwards compatibility for DebugMenu configs.
    if config and config.Version == DebugMenu.SAVE_VERSION then
        for modTable,features in pairs(config.State) do
            for id,storedState in pairs(features) do
                local s, state = pcall(DebugMenu.GetState, modTable, id)

                -- The pcall fails if the feature is not on the current context.
                if s then
                    local feature = state:GetFeature()
    
                    state.Debug = storedState.Debug
                    state.Enabled = storedState.Enabled
                    state.LoggingLevel = storedState.LoggingLevel
    
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
    local save = {State = table.deepCopy(DebugMenu.State)}
    save.Version = DebugMenu.SAVE_VERSION

    Utilities.SaveJson(path or DebugMenu.SAVE_FILENAME, save)
end

---@param modTable string
---@param featureID string
---@param enabled boolean
function DebugMenu.SetEnabledState(modTable, featureID, enabled)
    local state = DebugMenu.GetState(modTable, featureID)

    state.Enabled = enabled

    state:GetFeature().Disabled = not enabled
end

---@param modTable string
---@param featureID string
---@param enabled boolean
function DebugMenu.SetDebugState(modTable, featureID, enabled)
    local state = DebugMenu.GetState(modTable, featureID)
    state.Debug = enabled

    state:GetFeature().IS_DEBUG = enabled
end

---@param modTable string
---@param featureID string
---@param level Feature_LoggingLevel
function DebugMenu.SetLoggingState(modTable, featureID, level)
    local state = DebugMenu.GetState(modTable, featureID)
    state.LoggingLevel = level

    state:GetFeature().Logging = level
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function (ev)
    DebugMenu.LoadConfig()
end)