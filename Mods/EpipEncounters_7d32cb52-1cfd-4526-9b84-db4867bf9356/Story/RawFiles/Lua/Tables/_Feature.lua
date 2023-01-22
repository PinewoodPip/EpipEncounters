
---@meta Library: Feature, ContextShared, Feature

---------------------------------------------
-- Base table for features and libraries.
---------------------------------------------

---@class Feature
---@field NAME string Used for logging, event handling. Do not set!
---@field MOD_TABLE string
---@field CONTEXT Context Set automatically.
---@field Disabled boolean
---@field Logging integer Logging level.
---@field Settings table<string, SettingsLib_Setting>
---@field LOGGING_LEVEL table<string, integer> Valid logging levels.
---@field REQUIRED_MODS table<GUID, string> The feature will be automatically disabled if any required mods are missing.
---@field FILEPATH_OVERRIDES table<string, string>
---@field AddEvent fun(self, name:string, data:Event?)
---@field AddHook fun(self, name:string, data:Hook?):Hook
---@field IsEnabled fun(self):boolean
---@field __Setup fun(self)
---@field Disable fun(self)
---@field OnFeatureInit fun(self)
---@field RegisterListener fun(self, event:string, handler:function)
---@field FireEvent fun(self, event:string, ...:any)
---@field RegisterHook fun(self, event:string, handler:function)
---@field ReturnFromHooks fun(self, event:string, defaultValue:any, ...:any)
---@field FireGlobalEvent fun(self, event:string, ...:any)
---@field Debug fun(self)
---@field IsDebug fun(self):boolean
---@field Mute fun(self)
---@field ShutUp fun(self)
---@field DebugLog fun(self, ...:any)
---@field Dump fun(self, msg:string)
---@field RawLog fun(self, ...:any)
---@field LogWarning fun(self, msg)
---@field LogError fun(self, msg)
---@field MOD_TABLE_ID string
---@field DoNotExportTSKs boolean? If `true`, TSKs will not be exported to localization templates.
local Feature = {
    Disabled = false,
    Logging = 0,

    Settings = {}, ---@type table<string, SettingsLib_Setting>

    Events = {},
    Hooks = {},
    TranslatedStrings = {}, ---@type table<TranslatedStringHandle, Feature_TranslatedString>
    TSK = {}, ---@type table<TranslatedStringHandle, string> Automatically managed.
    UserVariables = {}, ---@type table<string, UserVarsLib_UserVar>
    _localTranslatedStringKeys = {}, ---@type table<string, TranslatedStringHandle>

    CONTEXT = nil,

    ---@enum Feature_LoggingLevel
    LOGGING_LEVEL = {
        ALL = 0,
        WARN = 1,
        MUTED = 2, -- Errors only.
    },
    REQUIRED_MODS = {},
    FILEPATH_OVERRIDES = {},
    USE_LEGACY_EVENTS = true,
    USE_LEGACY_HOOKS = true,
    DEVELOPER_ONLY = false,

    _Tests = {}, ---@type Feature_Test[]
}
_Feature = Feature

-- .CONTEXT is... context-dependent.
if Ext.IsClient() then
    Feature.CONTEXT = "Client"
else
    Feature.CONTEXT = "Server"
end

---@class Feature_Test
---@field Name string
---@field Function function Can be coroutinable, but may only sleep, not yield.
---@field State "NotRun"|"Failed"|"Passed"
---@field Coroutine CoroutineInstance
local _Test = {}

---@return boolean, string -- Success, message
function _Test:Run(...)
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

---Add an event to the Events field.
---@param name string
---@param data? Event
---@return Event
function Feature:AddEvent(name, data)
    local event = data or {Module = self.NAME, Event = name}
    event.Module = self.NAME
    event.Event = name

    Inherit(event, _Event)

    self.Events[name] = event

    return event
end

---@param evName string
---@param preventable boolean? Defaults to false.
---@return Event
function Feature:AddSubscribableEvent(evName, preventable)
    local event = SubscribableEvent:New(evName, preventable)

    self.Events[evName] = event

    return event
end

---@param evName string
---@param preventable boolean? Defaults to false.
---@return Event
function Feature:AddSubscribableHook(evName, preventable)
    local event = SubscribableEvent:New(evName, preventable)

    self.Hooks[evName] = event

    return event
end

---Add a hook to the Hooks field.
---@param name string
---@param data? Hook
---@return Hook
function Feature:AddHook(name, data)
    local hook = data or {Module = self.NAME, Event = name}
    hook.Module = self.NAME
    hook.Event = name

    Inherit(hook, _Hook)

    self.Hooks[name] = hook

    return hook
end

---------------------------------------------
-- METHODS
---------------------------------------------

---WIP. Do not use! Use Epip.RegisterFeature() for the time being.
---@param feature Feature
---@return Feature
function Feature.Create(feature)
    -- Initialize translated strings
    feature._localTranslatedStringKeys = {}
    for handle,data in pairs(feature.TranslatedStrings) do
        local localKey = data.Handle and handle or data.LocalKey -- If Handle is manually set, use table key as localKey

        data.Handle = data.Handle or handle
        data.ModTable = feature.MOD_TABLE_ID
        data.FeatureID = feature.MODULE_ID

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

    -- Initialize PersistentVars
    if Ext.IsServer() then
        if not PersistentVars.Features[feature.MOD_TABLE_ID] then
            PersistentVars.Features[feature.MOD_TABLE_ID] = {}
        end
        PersistentVars.Features[feature.MOD_TABLE_ID][feature.MODULE_ID] = {}
    end

    -- Initialize settings
    for id,setting in pairs(feature.Settings) do
        setting.ID = id
        setting.ModTable = feature:GetSettingsModuleID()

        Settings.RegisterSetting(setting)
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

if Ext.IsServer() then

    ---Returns the feature's PersistentVars table.
    ---@return table
    function Feature:GetPersistentVariables()
        return PersistentVars.Features[self.MOD_TABLE_ID][self.MODULE_ID]

    end
    ---Sets a persistent variable.
    ---@param key string
    ---@param value any
    function Feature:SetPersistentVariable(key, value)
        local tbl = self:GetPersistentVariables()

        tbl[key] = value
    end

    ---Gets a persistent value by key.
    ---@param key string
    ---@return any
    function Feature:GetPersistentVariable(key)
        local tbl = self:GetPersistentVariables()

        return tbl[key]
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
-- LISTENER/HOOK FUNCTIONS
---------------------------------------------

---Register an event listener.
---To define events with multiple variables, you can easily create a wrapper function for this (and FireEvent)
---that registers an event listener with a prefix(es).
---@param event string
---@param handler function
function Feature:RegisterListener(event, handler)
    Utilities.Hooks.RegisterListener(self.NAME, event, handler)
end

---Fire an event.
---@param event string
---@vararg any Event parameters, passed to listeners.
function Feature:FireEvent(event, ...)
    Utilities.Hooks.FireEvent(self.NAME, event, ...)
end

---Register a hook.
---@param event string
---@param handler function
function Feature:RegisterHook(event, handler)
    Utilities.Hooks.RegisterHook(self.NAME, event, handler)
end

---Get a value from registered hook listeners.
---@param event string
---@param defaultValue any Default value, will be passed to the first listener.
---@vararg any Additional parameters (non-modifiable)
function Feature:ReturnFromHooks(event, defaultValue, ...)
    return Utilities.Hooks.ReturnFromHooks(self.NAME, event, defaultValue, ...)
end

---Fire an event to all contexts and peers.
---@param event string
---@vararg any Event parameters.
function Feature:FireGlobalEvent(event, ...)
    self:FireEvent(event, ...)

    -- Fire event 
    Ext.Net.BroadcastMessage("EPIPFeature_GlobalEvent", Ext.Json.Stringify({
        Module = self.MODULE_ID,
        Event = event,
        Args = {...},
    }))
end

Ext.RegisterNetListener("EPIPFeature_GlobalEvent", function(_, payload)
    payload = Ext.Json.Parse(payload)

    Utilities.Hooks.FireEvent(payload.Module, payload.Event, table.unpack(payload.Args))
end)

---------------------------------------------
-- LOGGING FUNCTIONS
---------------------------------------------

---Show debug-level logging from this feature.
---Only work in Developer mode.
function Feature:Debug()
    if Epip.IsDeveloperMode() then
        self.IS_DEBUG = true
    end
end

---Returns whether :Debug() has been ran successfully.
---@return boolean
function Feature:IsDebug()
    return self.IS_DEBUG
end

---Stop all non-error, non-warning logging from this feature.
function Feature:Mute()
    self.Logging = self.LOGGING_LEVEL.WARN
end

---Stop all non-error logging.
function Feature:ShutUp()
    self.Logging = self.LOGGING_LEVEL.MUTED
end

---Log a value in Debug mode.
---@vararg any
function Feature:DebugLog(...)
    if self:IsDebug() and not IS_IMPROVED_HOTBAR then
        Utilities._Log(self.NAME, "", ...)
    end
end

---Log a message in the format "[MODULE] method(): msg"
---@param method any
---@param ... any
function Feature:LogMethod(method, ...)
    if self:IsDebug() and not IS_IMPROVED_HOTBAR then
        Utilities._Log(self.NAME, string.format("%s():", method), ...)
    end
end

---Dump a value to the console, in Debug mode.
---@param msg any
function Feature:Dump(msg)
    if self:IsDebug() then
        _D(msg)
    end
end

---Log a value.
---@param msg any
function Feature:Log(msg)
    if self.Logging <= self.LOGGING_LEVEL.ALL then
        Utilities.Log(self.NAME, msg)
    end
end

---Log values without any prefixing.
---@vararg any
function Feature:RawLog(...)
    if self.Logging <= self.LOGGING_LEVEL.ALL then
        print(...)
    end
end

---Log a warning.
---@param msg any
function Feature:LogWarning(msg)
    if self.Logging <= self.LOGGING_LEVEL.WARN then
        Utilities.LogWarning(self.NAME, msg)
    end
end

---Logs a "Not implemented" warning. Use as a placeholder.
---@param methodName string
function Feature:LogNotImplemented(methodName)
    self:LogWarning("Not implemented: " .. methodName)
end

---Log an error.
---@param msg any
function Feature:LogError(msg)
    Utilities.LogError(self.NAME, msg)
end

---Throws an error.
---@param method string
function Feature:Error(method, ...)
    local params = {...}
    local str = Text.Join(params, " ")
    error(Text.Format("%s(): %s", {FormatArgs = {method, str}}))
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Initialize persistent vars.
if Ext.IsServer() then
    if not PersistentVars.Features then
        PersistentVars.Features = {}
    end
end