
---------------------------------------------
-- Base table for features and libraries.
---------------------------------------------

---@class Feature : Library
---@field Disabled boolean
---@field REQUIRED_MODS table<GUID, string> The feature will be automatically disabled if any required mods are missing.
---@field FILEPATH_OVERRIDES table<string, string>
---@field IsEnabled fun(self):boolean
---@field __Setup fun(self)
---@field _Classes table<string, table>
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
local Feature = {
    Disabled = false,
    Logging = 0,

    TSK = {}, ---@type table<TranslatedStringHandle, string> Automatically managed.
    UserVariables = {}, ---@type table<string, UserVarsLib_UserVar>
    _localTranslatedStringKeys = {}, ---@type table<string, TranslatedStringHandle>

    REQUIRED_MODS = {},
    FILEPATH_OVERRIDES = {},
    DEVELOPER_ONLY = false,

    _Tests = {}, ---@type Feature_Test[]
}
_Feature = Feature
OOP.GetClass("Library").Create("EpipEncounters", "_Feature", Feature)
OOP.RegisterClass("Feature", Feature)

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
    feature = OOP.GetClass("Library").Create(modTable, id, feature)
    feature = Feature:__Create(feature) ---@type Feature
    feature.MODULE_ID, feature.MOD_TABLE_ID = id, modTable -- TODO remove

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

    -- Create class holder
    feature._Classes = {}

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
    feature.Settings = feature.Settings or {}
    for settingID,setting in pairs(feature.Settings) do
        feature:RegisterSetting(settingID, setting)
    end

    -- Initialize user variables
    for id,data in pairs(feature.UserVariables) do
        feature:RegisterUserVariable(id, data)
    end

    return feature
end

---Returns whether the feature has *not* been disabled. Use to condition your feature's logic.
---@return boolean
function Feature:IsEnabled()
    return not self.Disabled
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
function Feature:RegisterSetting(id, data)
    data.ID = id
    data.ModTable = self:GetSettingsModuleID()
    data.Context = data.Context or Mod.GetCurrentContext()

    Settings.RegisterSetting(data)

    self.Settings[id] = data
end

---@param setting string|SettingsLib_Setting
function Feature:GetSettingValue(setting)
    if type(setting) == "table" then
        setting = setting.ID
    end

    return Settings.GetSettingValue(self:GetSettingsModuleID(), setting)
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

---Registers a user variable.
---@param name string
---@param data UserVarsLib_UserVar?
function Feature:RegisterUserVariable(name, data)
    name = self:_GetUserVarsKey(name)

    self.UserVariables[name] = UserVars.Register(name, data)
end

---Gets the value of a user variable on an entity component.
---@param component EntityLib_Component
---@param variable string|UserVarsLib_UserVar
---@return any
function Feature:GetUserVariable(component, variable)
    if type(variable) == "table" then variable = variable.ID end
    local userVarName = self:_GetUserVarsKey(variable)

    return component.UserVars[userVarName]
end

---Sets the value of a user variable.
---@param component EntityLib_Component
---@param variable string|UserVarsLib_UserVar
---@param value any
function Feature:SetUserVariable(component, variable, value)
    if type(variable) == "table" then variable = variable.ID end
    local userVarName = self:_GetUserVarsKey(variable)

    component.UserVars[userVarName] = value
end

---@param suffix string?
---@return string
function Feature:_GetUserVarsKey(suffix)
    local key = self.MOD_TABLE_ID .. "_" .. self.MODULE_ID

    if suffix then
        key = key .. "_" .. suffix
    end

    return key
end

---------------------------------------------
-- OOP
---------------------------------------------

---Registers a class.
---@param className string
---@param class table Class table.
function Feature:RegisterClass(className, class)
    self._Classes[className] = class
end

---Returns a class's base table.
---@generic T
---@param className `T`
---@return `T`
function Feature:GetClass(className)
    return self._Classes[className]
end