
---------------------------------------------
-- Base table for features and libraries.
---------------------------------------------

---@class Feature : Library
---@field _EnabledFunctor (fun():boolean)?
---@field Disabled boolean
---@field FILEPATH_OVERRIDES table<string, string>
---@field RegisterListener fun(self, event:string, handler:function)
---@field FireEvent fun(self, event:string, ...:any)
---@field RegisterHook fun(self, event:string, handler:function)
---@field ReturnFromHooks fun(self, event:string, defaultValue:any, ...:any)
---@field FireGlobalEvent fun(self, event:string, ...:any)
---@field MOD_TABLE_ID string
---@field DoNotExportTSKs boolean? If `true`, TSKs will not be exported to localization templates.
----@field Settings table<string, SettingsLib_Setting>
---@field SupportedGameStates bitfield Defaults to all. See GAME_STATES.
---@field InputActions table<string, InputLib_Action> ID field is auto-initialized from key and prefixed. Only used in Client context.
---@field _DisableRequests table<string, true> Table of requests to keep the feature disabled.
local Feature = {
    Disabled = false,
    Logging = 0,

    GAME_STATES = {
        MAIN_MENU = 1,
        LOADING = 2,
        PAUSED_SESSION = 4,
        RUNNING_SESSION = 8,
    },
    FILEPATH_OVERRIDES = {},
    DEVELOPER_ONLY = false,

    _Tests = {}, ---@type Feature_Test[]
}
_Feature = Feature
OOP.RegisterClass("Feature", Feature, {"Library"})

---@class Feature_Test
---@field Name string
---@field Function function Can be coroutinable, but may only sleep, not yield.
---@field State "NotRun"|"Failed"|"Passed"
---@field Coroutine CoroutineInstance
local _Test = {}

---@return boolean, string -- Success, message
function _Test:Run()
    local coro = Coroutine.Create(self.Function)
    coro.Events.Finished:Subscribe(function (_)
        self.State = "Passed"
    end)
    self.State = "Failed"
    self.Coroutine = coro

    local success, msg = pcall(coro.Continue, coro)

    return success, msg
end

---@return boolean
function _Test:IsFinished()
    return self.Coroutine and self.Coroutine:IsDead()
end

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@param name string
---@param func fun(inst:CoroutineInstance)
---@return Feature_Test
function Feature:RegisterTest(name, func)
    local test = {Name = name, Function = func, State = "NotRun", Coroutine = nil} ---@type Feature_Test
    Inherit(test, _Test)

    table.insert(self._Tests, test)

    return test
end

---------------------------------------------
-- METHODS
---------------------------------------------

---WIP. Do not use! Use Epip.RegisterFeature() for the time being.
---@param modTable string
---@param id string
---@param feature Feature
---@return Feature
function Feature.Create(modTable, id, feature)
    feature.Settings = feature.Settings or {}
    if Ext.IsClient() then
        feature.InputActions = feature.InputActions or {}
    end

    feature = OOP.GetClass("Library").Create(modTable, id, feature)
    feature = Feature:__Create(feature) ---@type Feature
    feature.MODULE_ID, feature.MOD_TABLE_ID = id, modTable -- TODO remove

    feature._DisableRequests = {}

    -- Defaults to all game states.
    feature.SupportedGameStates = feature.SupportedGameStates or Feature._GetAllSupportedGameStatesBitfield()

    -- Initialize settings
    for settingID,setting in pairs(feature.Settings) do
        feature:RegisterSetting(settingID, setting)
    end

    -- Initialize InputLib actions
    if Ext.IsClient() then
        for actionID,actionDef in pairs(feature.InputActions) do
            feature:RegisterInputAction(actionID, actionDef)
        end
    end

    return feature
end

---Returns whether the feature has *not* been disabled. Use to condition your feature's logic.
---@return boolean
function Feature:IsEnabled()
    local isEnabled = not next(self._DisableRequests)

    if isEnabled and self.SupportedGameStates ~= Feature._GetAllSupportedGameStatesBitfield() then
        local featureStates = self.SupportedGameStates
        local STATES = Feature.GAME_STATES

        if featureStates & STATES.MAIN_MENU == 0 then
            isEnabled = isEnabled and not GameState.IsInMainMenu()
        end
        if featureStates & STATES.LOADING == 0 then
            isEnabled = isEnabled and not GameState.IsLoading()
        end
        if featureStates & STATES.PAUSED_SESSION == 0 then
            isEnabled = isEnabled and not GameState.IsPaused()
        end
        if featureStates & STATES.RUNNING_SESSION == 0 then
            isEnabled = isEnabled and not GameState.IsInRunningSession()
        end
    end

    return isEnabled
end

---Requests the feature to be enabled or disabled.
---Features are enabled by default, and stay disabled so long
---as at there stays at least one request to disable them.
---@param requestID string
---@param enabled boolean
function Feature:SetEnabled(requestID, enabled)
    self._DisableRequests[requestID] = (not enabled) or nil
end

---Returns the mod table of the feature.
---@return modtable
function Feature:GetModTable()
    return self.__ModTable
end

---Returns the ID of the feature.
---@return string
function Feature:GetFeatureID()
    return self.__ID
end

---Returns a function that takes no parameters and returns whether the feature is enabled.
---Intended for use with Event options.
---@see Event_Options
---@return fun():boolean
function Feature:GetEnabledFunctor()
    self._EnabledFunctor = self._EnabledFunctor or function () return self:IsEnabled() end

    return self._EnabledFunctor
end

---Called after the feature is registered.
---Override to run initialization routines - this is preferable over initializing things at the root of your script, as it is hookable.
---@see Epip.Events.FeatureInitialization
---@virtual
function Feature:__Initialize() end

---Returns the bitfield that supports all game states.
---@return integer
function Feature._GetAllSupportedGameStatesBitfield()
    return 2^table.getKeyCount(Feature.GAME_STATES) - 1
end

---Returns a string containing the feature's mod table and ID.
---Ex. `"MyModTable_MyFeature"`.
---@return string
function Feature:GetNamespace()
    return self.MOD_TABLE_ID .. "_" .. self.MODULE_ID
end

---------------------------------------------
-- SETTINGSLIB METHODS
---------------------------------------------

---Registers a setting with the feature's module ID.
---@param id string
---@param data SettingsLib_Setting
---@return SettingsLib_Setting
function Feature:RegisterSetting(id, data)
    data.ID = id
    data.ModTable = self:GetSettingsModuleID()
    data.Context = data.Context or Mod.GetCurrentContext()

    Settings.RegisterSetting(data)

    self.Settings[id] = data

    return data
end

---@param setting string|SettingsLib_Setting
function Feature:GetSettingValue(setting)
    -- Table overload.
    if type(setting) == "table" then
        setting = setting.ID
    end

    return Settings.GetSettingValue(self:GetSettingsModuleID(), setting)
end

---Sets the value of a setting.
---@param setting string|SettingsLib_Setting
---@param value any
function Feature:SetSettingValue(setting, value)
    local settingsModuleID = self:GetSettingsModuleID()

    -- Table overload.
    if type(setting) == "table" then
        setting = setting.ID
    end

    Settings.SetValue(settingsModuleID, setting, value)
    Settings.Save(settingsModuleID)
end

---@see Feature.GetNamespace
---@deprecated
---@return string
function Feature:GetSettingsModuleID()
    return self:GetNamespace()
end

function Feature:SaveSettings()
    if Ext.IsServer() then
        Feature:Error("SaveSettings", "SaveSettings() not implemented on server")
    else
        Settings.Save(self:GetNamespace())
    end
end

---------------------------------------------
-- INPUTLIB METHODS
---------------------------------------------

---Registers an InputLib action.
---@param id string Will be prefixed with the mod table and feature ID.
---@param action InputLib_Action
---@return InputLib_Action
function Feature:RegisterInputAction(id, action)
    if not Ext.IsClient() then
        self:Error("RegisterInputAction", "Called outside of client context")
    end
    action.ID = self:GetNamespace() .. "_" .. id
    action = Client.Input.RegisterAction(id, action)

    self.InputActions[id] = action -- Uses non-prefixed ID.

    return action
end