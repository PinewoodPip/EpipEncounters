
---------------------------------------------
-- Base table for features and libraries.
---------------------------------------------

---@class Feature : Library
---@field Disabled boolean
---@field REQUIRED_MODS table<GUID, string> The feature will be automatically disabled if any required mods are missing.
---@field FILEPATH_OVERRIDES table<string, string>
---@field IsEnabled fun(self):boolean
---@field __Setup fun(self)
---@field Disable fun(self)
---@field OnFeatureInit fun(self)
---@field RegisterListener fun(self, event:string, handler:function)
---@field FireEvent fun(self, event:string, ...:any)
---@field RegisterHook fun(self, event:string, handler:function)
---@field ReturnFromHooks fun(self, event:string, defaultValue:any, ...:any)
---@field FireGlobalEvent fun(self, event:string, ...:any)
---@field MOD_TABLE_ID string
---@field DoNotExportTSKs boolean? If `true`, TSKs will not be exported to localization templates.
---@field TranslatedStrings table<TranslatedStringHandle, Feature_TranslatedString>
---@field Settings table<string, SettingsLib_Setting>
---@field SupportedGameStates bitfield Defaults to all. See GAME_STATES.
local Feature = {
    Disabled = false,
    Logging = 0,

    TSK = {}, ---@type table<TranslatedStringHandle, string> Automatically managed.
    _localTranslatedStringKeys = {}, ---@type table<string, TranslatedStringHandle>

    GAME_STATES = {
        MAIN_MENU = 1,
        LOADING = 2,
        PAUSED_SESSION = 4,
        RUNNING_SESSION = 8,
    },
    REQUIRED_MODS = {},
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
-- CLASSES
---------------------------------------------

---@class Feature_TranslatedString : TextLib_TranslatedString
---@field LocalKey string? Usable with Feature.TSK - but not globally. Use when you want TSK keys without needing to prefix them to avoid collisions.

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
    feature.TranslatedStrings = feature.TranslatedStrings or {}

    feature = OOP.GetClass("Library").Create(modTable, id, feature)
    feature = Feature:__Create(feature) ---@type Feature
    feature.MODULE_ID, feature.MOD_TABLE_ID = id, modTable -- TODO remove

    -- Defaults to all game states.
    feature.SupportedGameStates = feature.SupportedGameStates or Feature._GetAllSupportedGameStatesBitfield()

    -- Initialize translated strings
    feature._localTranslatedStringKeys = {}
    feature.TranslatedStrings = feature.TranslatedStrings or {}
    for handle,data in pairs(feature.TranslatedStrings) do
        local localKey = data.Handle and handle or data.LocalKey -- If Handle is manually set, use table key as localKey

        data.Handle = data.Handle or handle
        data.ModTable = modTable
        data.FeatureID = id

        if localKey then
            feature._localTranslatedStringKeys[localKey] = handle
        end

        -- Make indexing via string key work as well
        if data.StringKey then
            feature.TranslatedStrings[data.StringKey] = data
        end

        Text.RegisterTranslatedString(data)
    end

    -- Create TSK table
    local TSKmetatable = {
        __index = function (_, key)
            local obj = feature.TranslatedStrings[key]

            -- Lookup using local key name instead
            if not obj then
                local handle = feature._localTranslatedStringKeys[key]

                obj = handle and feature.TranslatedStrings[handle]
            end

            if not obj then
                error("Tried to get TSK for handle not from this feature " .. key)
            end

            return obj:GetString()
        end
    }
    feature.TSK = {}
    setmetatable(feature.TSK, TSKmetatable)

    -- Initialize settings
    for settingID,setting in pairs(feature.Settings) do
        feature:RegisterSetting(settingID, setting)
    end

    return feature
end

---Returns whether the feature has *not* been disabled. Use to condition your feature's logic.
---@return boolean
function Feature:IsEnabled()
    local isEnabled = not self.Disabled

    if self.SupportedGameStates ~= Feature._GetAllSupportedGameStatesBitfield() then
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

---Invoked on SessionLoaded if the feature is not disabled.
---Override to run initialization routines.
function Feature:__Setup() end

---Invoked on a small delay after SessionLoaded if Epip.IsDeveloperMode(true) is true and the feature is being debugged.
function Feature:__Test() end

---Sets the Disabled flag.
function Feature:Disable()
    -- TODO fix
    self.Disabled = true
    if self._initialized then
        for old,new in pairs(self.FILEPATH_OVERRIDES) do
            self:LogError(self.NAME .. " cannot be disabled post-startup as it uses FILEPATH_OVERRIDES!")
            break
        end
    else
        self.Disabled = true
    end
end

---Called after a feature is initialized with Epip.AddFeature(),
---if it is not disabled.
---Override to run initialization routines.
function Feature:OnFeatureInit() end

---Returns the bitfield that supports all game states.
---@return integer
function Feature._GetAllSupportedGameStatesBitfield()
    return 2^table.getKeyCount(Feature.GAME_STATES) - 1
end

---------------------------------------------
-- TSK METHODS
---------------------------------------------

---@param localKey string
---@return TranslatedStringHandle?
function Feature:GetTranslatedStringHandleForKey(localKey)
    return self._localTranslatedStringKeys[localKey]
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

---@return string
function Feature:GetSettingsModuleID()
    return self.MOD_TABLE_ID .. "_" .. self.MODULE_ID
end

function Feature:SaveSettings()
    if Ext.IsServer() then
        Feature:Error("SaveSettings", "SaveSettings() not implemented on server")
    else
        Settings.Save(self:GetSettingsModuleID())
    end
end

---------------------------------------------
-- USERVARS METHODS
---------------------------------------------

---Registers a mod variable.
---@param modGUID GUID
---@param name string
---@param data UserVarsLib_ModVar
function Feature:RegisterModVariable(modGUID, name, data)
    local key = self:_GetUserVarsKey(name)

    UserVars.RegisterModVariable(modGUID, key, data)
end

---Returns the value of a mod variable.
---@param modGUID GUID
---@param name string
---@return any
function Feature:GetModVariable(modGUID, name)
    return UserVars.GetModVariables(modGUID)[self:_GetUserVarsKey(name)]
end

---Sets the value of a mod variable.
---@param modGUID GUID
---@param name string
---@param value any
function Feature:SetModVariable(modGUID, name, value)
    local vars = UserVars.GetModVariables(modGUID)

    vars[self:_GetUserVarsKey(name)] = value

    Ext.Utils.SyncModVariables()
end