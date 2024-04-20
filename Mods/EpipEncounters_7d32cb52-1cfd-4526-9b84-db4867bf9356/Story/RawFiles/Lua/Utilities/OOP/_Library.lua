
---------------------------------------------
-- Utility class for libraries.
-- Provides logging and Observer implementations.
---------------------------------------------

local Print = Ext.Utils.Print

---@class Library : Class
---@field UserVariables table<string, UserVarsLib_UserVar> Initializable.
---@field _Classes table<string, Class> Subclasses registered for this library.
---@field __ID string
---@field __ModTable string
---@field __IsDebug boolean
----@field TranslatedStrings table<TranslatedStringHandle, Library_TranslatedString> Initializable.
----@field Events table<string, Event> Initializable. -- These 2 fields cannot be included as they break auto-complete.
----@field Hooks table<string, Event> Initializable.
local Library = {
    TSK = {}, ---@type table<TranslatedStringHandle, string> Automatically managed.
    _localTranslatedStringKeys = {}, ---@type table<string, TranslatedStringHandle>

    USE_LEGACY_EVENTS = true,
    USE_LEGACY_HOOKS = true,
}
OOP.RegisterClass("Library", Library)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Library_TranslatedString : TextLib_TranslatedString
---@field LocalKey string? Usable with Feature.TSK - but not globally. Use when you want TSK keys without needing to prefix them to avoid collisions.

---@class Library.Listenable : Event
---@field Context context? If set, the event will only be registered on that context and throw when accessed in an invalid one.
---@field Legacy boolean?

---Creates an unusable listenable that throws upon indexing.
---@param name string
---@param listenableType listenabletype
local function CreateInvalidListenable(name, listenableType, context)
    local invalidListenable = {}
    setmetatable(invalidListenable, {
        __index = function (_, _)
            error(string.format("%s %s is %s-only", listenableType, name, context))
        end
    })
    return invalidListenable
end

---@class Library.Event : Library.Listenable
---@class Library.Hook : Library.Listenable

---------------------------------------------
-- METHODS
---------------------------------------------

---Initializes a table as a Library.
---@param modTable string
---@param id string
---@param data Library
---@return Library
function Library.Create(modTable, id, data)
    local library = data

    data.UserVariables = data.UserVariables or {}
    data.__ID = id
    data.__ModTable = modTable
    data.__name = id -- DEPRECATED! TODO
    data.__IsDebug = false

    local lib = OOP.GetClass("Library"):__Create(data) ---@cast lib Library

    -- Initialize events and hooks.
    data.Events = data.Events or {}
    for ev,opts in pairs(data.Events) do
        ---@cast opts Library.Event
        if opts.Legacy == false or data.USE_LEGACY_EVENTS == false then
            -- Check if context is invalid
            if opts.Context and ((opts.Context == "Client" and Ext.IsServer()) or (opts.Context == "Server" and Ext.IsClient())) then
                data.Events[ev] = CreateInvalidListenable(ev, "Event", opts.Context)
            else
                data:AddSubscribableEvent(ev, opts.Preventable)
            end
        else
            data:AddEvent(ev, opts)
        end
    end
    data.Hooks = data.Hooks or {}
    for hook,opts in pairs(data.Hooks) do
        ---@cast opts Library.Hook
        if opts.Legacy == false or data.USE_LEGACY_HOOKS == false then
            -- Check if context is invalid
            if opts.Context and ((opts.Context == "Client" and Ext.IsServer()) or (opts.Context == "Server" and Ext.IsClient())) then
                data.Events[hook] = CreateInvalidListenable(hook, "Hook", opts.Context)
            else
                data:AddSubscribableHook(hook, opts.Preventable)
            end
        else
            data:AddHook(hook, opts)
        end
    end
    -- Initialize PersistentVars - TODO rename it
    if Ext.IsServer() then
        if not PersistentVars.Features[data.__ModTable] then
            PersistentVars.Features[data.__ModTable] = {}
        end
        PersistentVars.Features[data.__ModTable][data.__name] = {}
    end

    -- Initialize translated strings
    library._localTranslatedStringKeys = {}
    library.TranslatedStrings = library.TranslatedStrings or {}
    local tsksWithStringKey = {}
    for handle,tsk in pairs(library.TranslatedStrings) do
        library:RegisterTranslatedString(handle, tsk)

        -- Make indexing via string key work as well.
        if tsk.StringKey then
            tsksWithStringKey[tsk.StringKey] = tsk
        end
    end
    for key,tsk in pairs(tsksWithStringKey) do -- Needs to be done outside of table iteration to avoid re-registering keys
        library.TranslatedStrings[key] = tsk
    end

    -- Create TSK table
    local TSKmetatable = {
        __index = function (_, key)
            local obj = library.TranslatedStrings[key]

            -- Lookup using local key name instead
            if not obj then
                local handle = library._localTranslatedStringKeys[key]

                obj = handle and library.TranslatedStrings[handle]
            end

            if not obj then
                error("Tried to get TSK for handle not from this feature " .. key)
            end

            return obj:GetString()
        end
    }
    library.TSK = {}
    setmetatable(library.TSK, TSKmetatable)

    -- Create class holder
    data._Classes = {}

    -- Initialize user variables
    for userVarID,userVar in pairs(data.UserVariables) do
        data:RegisterUserVariable(userVarID, userVar)
    end

    -- Run Setup() and Test() methods when session loads
    Ext.Events.SessionLoaded:Subscribe(function (_)
        local success, msg = pcall(function ()
            ---@diagnostic disable-next-line: invisible
            lib:__Setup()

            if lib:IsDebug() and Epip.IsDeveloperMode(true) then
                Timer.Start(2, function (_)
                    ---@diagnostic disable-next-line: invisible
                    lib:__Test()
                end)
            end
        end)
        if not success then
            Ext.Utils.PrintError("Error during Library SessionLoaded:", msg)
        end
    end, {Priority = -9999})

    return lib
end

---Returns the package prefix for this library's subclasses.
---@return string
function Library:GetPackagePrefix()
    return string.format("%s_%s_", self.__ModTable, self.__name)
end

---Invoked on SessionLoaded if the feature is not disabled.
---Override to run initialization routines.
---@virtual
function Library:__Setup() end

---Invoked on a small delay after SessionLoaded if Epip.IsDeveloperMode(true) is true and the feature is being debugged.
---@virtual
function Library:__Test() end

---------------------------------------------
-- USERVARS
---------------------------------------------

---Registers a user variable.
---@param name string
---@param data UserVarsLib_UserVar?
function Library:RegisterUserVariable(name, data)
    name = self:_GetUserVarsKey(name)

    self.UserVariables[name] = UserVars.RegisterUserVariable(name, data)
end

---Gets the value of a user variable on an entity component.
---@param component UserVarsLib_CompatibleComponent
---@param variable string|UserVarsLib_UserVar
---@return any
function Library:GetUserVariable(component, variable)
    if type(variable) == "table" then variable = variable.ID end
    local userVarName = self:_GetUserVarsKey(variable)

    return UserVars.GetUserVarValue(component, userVarName)
end

---Sets the value of a user variable.
---@param component UserVarsLib_CompatibleComponent
---@param variable string|UserVarsLib_UserVar
---@param value any
function Library:SetUserVariable(component, variable, value)
    if type(variable) == "table" then variable = variable.ID end
    local userVarName = self:_GetUserVarsKey(variable)

    component.UserVars[userVarName] = value
end

---@param suffix string?
---@return string
function Library:_GetUserVarsKey(suffix)
    local key = self.__ModTable .. "_" .. self.__name

    if suffix then
        key = key .. "_" .. suffix
    end

    return key
end

---Registers a mod variable.
---@param modGUID GUID
---@param name string
---@param data UserVarsLib_ModVar
function Library:RegisterModVariable(modGUID, name, data)
    local key = self:_GetUserVarsKey(name)

    UserVars.RegisterModVariable(modGUID, key, data)
end

---Returns the value of a mod variable.
---@param modGUID GUID
---@param name string
---@return any
function Library:GetModVariable(modGUID, name)
    return UserVars.GetModVarValue(modGUID, self:_GetUserVarsKey(name))
end

---Sets the value of a mod variable.
---@param modGUID GUID
---@param name string
---@param value any
function Library:SetModVariable(modGUID, name, value)
    local vars = UserVars.GetModVariables(modGUID)

    vars[self:_GetUserVarsKey(name)] = value

    Ext.Vars.SyncModVariables()
end

---------------------------------------------
-- TSK METHODS
---------------------------------------------

---@param localKey string
---@return TranslatedStringHandle?
function Library:GetTranslatedStringHandleForKey(localKey)
    return self._localTranslatedStringKeys[localKey]
end

---Table-only overload.
---@param tsk Library_TranslatedString ModTable, FeatureID and Handle fields are auto-initialized.
---@return Library_TranslatedString
---@diagnostic disable-next-line
function Library:RegisterTranslatedString(tsk) end

---Registers a TSK.
---@param handle TranslatedStringHandle
---@param tsk Library_TranslatedString ModTable, FeatureID and Handle fields are auto-initialized.
---@return Library_TranslatedString
---@diagnostic disable-next-line: duplicate-set-field
function Library:RegisterTranslatedString(handle, tsk)
    if type(handle) == "table" then -- Table overload.
        handle, tsk = handle.Handle, handle
    end
    local localKey = tsk.Handle and handle or tsk.LocalKey -- If Handle is manually set, use table key as localKey

    tsk.Handle = tsk.Handle or handle
    tsk.ModTable = self.__ModTable
    tsk.FeatureID = self.__name

    if localKey then
        self._localTranslatedStringKeys[localKey] = handle
    end

    local registeredTSK = Text.RegisterTranslatedString(tsk) ---@cast registeredTSK Library_TranslatedString

    return registeredTSK
end

---------------------------------------------
-- DEBUGGING
---------------------------------------------

---Show debug-level logging from this library.
---Only works in Developer mode.
function Library:Debug()
    if Epip.IsDeveloperMode() then
        self.IS_DEBUG = true
    end
end

---Returns whether `:Debug()` has been ran successfully.
---@return boolean
function Library:IsDebug()
    return self.IS_DEBUG
end

---------------------------------------------
-- LOGGING
---------------------------------------------

---Stop all non-error, non-warning logging from this feature.
function Library:Mute()
    self.__LoggingLevel = OOP.LOGGING_LEVELS.WARN
end

---Stop all non-error logging.
function Library:ShutUp()
    self.__LoggingLevel = OOP.LOGGING_LEVELS.MUTED
end

---Log a value in Debug mode.
---@vararg any
function Library:DebugLog(...)
    if self:IsDebug() then
        Print(self:__GetLoggingPrefix(), ...)
    end
end

---Log a message in the format "[MODULE] method(): msg"
---@param method any
---@param ... any
function Library:LogMethod(method, ...)
    if self:IsDebug() then
        Print(self:__GetLoggingPrefix(), string.format("%s():", method), ...)
    end
end

---Dump a value to the console, in Debug mode.
---@param msg any
function Library:Dump(msg)
    if self:IsDebug() then
        _D(msg)
    end
end

---Log a value.
---@deprecated Use `Class:__Log()`.
---@param ... any
function Library:Log(...)
    self:__Log(...)
end

---Log a warning.
---Requires logging level to be set to WARN or lower.
---@deprecated Use `Class:__LogWarning()`.
---@param ... any
function Library:LogWarning(...)
    self:__LogWarning(...)
end

---Logs a "Not implemented" warning. Use as a placeholder.
---@deprecated Use `Class:__LogNotImplemented()`.
---@param methodName string
function Library:LogNotImplemented(methodName)
    self:__LogNotImplemented(methodName)
end

---Throws a "Not implemented" error. Use as a placeholder.
---@deprecated Use `Class:__ThrowNotImplemented()`.
---@param methodName string
function Library:ThrowNotImplemented(methodName)
    self:__ThrowNotImplemented(methodName)
end

---Logs an error without halting execution.
---@deprecated Use `Class:__LogError()`.
---@param ... any
function Library:LogError(...)
    self:__LogError(...)
end

---Throws an error prefixed with the library and method name, blaming the third-level function in the stack - usually user code.
---@deprecated Use `Class:__Error()`.
---@param ... any
---@param method string
function Library:Error(method, ...)
    self:__Error(method, ...)
end

---Throws an error prefixed with the library and method name caused at the callee function.
---@deprecated Use `Class:__InternalError()`.
---@param method string
---@param ... any
function Library:InternalError(method, ...)
    self:__InternalError(method, ...)
end

---------------------------------------------
-- PERSISTENCE
---------------------------------------------

if Ext.IsServer() then
    ---Returns the feature's PersistentVars table.
    ---@return table
    function Library:GetPersistentVariables()
        return PersistentVars.Features[self.__ModTable][self.__name]

    end
    ---Sets a persistent variable.
    ---@param key string
    ---@param value any
    function Library:SetPersistentVariable(key, value)
        local tbl = self:GetPersistentVariables()

        tbl[key] = value
    end

    ---Gets a persistent value by key.
    ---@param key string
    ---@return any
    function Library:GetPersistentVariable(key)
        local tbl = self:GetPersistentVariables()

        return tbl[key]
    end
end

---------------------------------------------
-- OOP
---------------------------------------------

---Registers a class.
---@generic T
---@param className `T`
---@param class table Class table.
---@param parentClasses string[]? Classes this one inherits from.
---@return `T`
function Library:RegisterClass(className, class, parentClasses)
    self._Classes[className] = class

    return OOP.RegisterClass(className, class, parentClasses)
end

---Returns a class's base table.
---@generic T
---@param className `T`
---@return `T`
function Library:GetClass(className)
    if self._Classes[className] == nil then
        self:Error("GetClass", "Attemped to fetch an unregistered class: ", className, "- Make sure the class is from this library.")
    end

    return OOP.GetClass(className)
end

---------------------------------------------
-- EVENT SYSTEM
---------------------------------------------

---Registers a new event.
---@param evName string
---@param preventable boolean? Defaults to false.
---@return Event
function Library:AddSubscribableEvent(evName, preventable)
    local event = SubscribableEvent:New(evName, preventable)

    ---@diagnostic disable-next-line: undefined-field
    self.Events[evName] = event

    return event
end

---Registers a new hook.
---@param evName string
---@param preventable boolean? Defaults to false.
---@return Event
function Library:AddSubscribableHook(evName, preventable)
    local event = SubscribableEvent:New(evName, preventable)

    ---@diagnostic disable-next-line: undefined-field
    self.Hooks[evName] = event

    return event
end

---Add an event to the Events field.
---@deprecated Use `AddSubscribableEvent()` instead.
---@param name string
---@param data Event?
---@return Event
function Library:AddEvent(name, data)
    local event = data or {Module = self.__name, Event = name}
    event.Module = self.__name
    event.Event = name

    Inherit(event, _Event)

    ---@diagnostic disable-next-line: undefined-field
    self.Events[name] = event

    return event
end

---Add a hook to the Hooks field.
---@deprecated Use `AddSubscribableHook()` instead.
---@param name string
---@param data? LegacyHook
---@return LegacyHook
function Library:AddHook(name, data)
    local hook = data or {Module = self.__name, Event = name}
    hook.Module = self.__name
    hook.Event = name

    Inherit(hook, _Hook)

    ---@diagnostic disable-next-line: undefined-field
    self.Hooks[name] = hook

    return hook
end

---Register an event listener.
---To define events with multiple variables, you can easily create a wrapper function for this (and FireEvent)
---that registers an event listener with a prefix(es).
---@deprecated
---@param event string
---@param handler function
function Library:RegisterListener(event, handler)
    Utilities.Hooks.RegisterListener(self.__name, event, handler)
end

---Fire an event.
---@deprecated
---@param event string
---@vararg any Event parameters, passed to listeners.
function Library:FireEvent(event, ...)
    Utilities.Hooks.FireEvent(self.__name, event, ...)
end

---Register a hook.
---@deprecated
---@param event string
---@param handler function
function Library:RegisterHook(event, handler)
    Utilities.Hooks.RegisterHook(self.__name, event, handler)
end

---Get a value from registered hook listeners.
---@deprecated
---@param event string
---@param defaultValue any Default value, will be passed to the first listener.
---@vararg any Additional parameters (non-modifiable)
function Library:ReturnFromHooks(event, defaultValue, ...)
    return Utilities.Hooks.ReturnFromHooks(self.__name, event, defaultValue, ...)
end

---Fire an event to all contexts and peers.
---@deprecated
---@param event string
---@vararg any Event parameters.
function Library:FireGlobalEvent(event, ...)
    self:FireEvent(event, ...)

    -- Fire event 
    Ext.Net.BroadcastMessage("EPIPFeature_GlobalEvent", Ext.Json.Stringify({
        Module = self.__name,
        Event = event,
        Args = {...},
    }))
end

Ext.RegisterNetListener("EPIPFeature_GlobalEvent", function(_, payload)
    payload = Ext.Json.Parse(payload)

    Utilities.Hooks.FireEvent(payload.Module, payload.Event, table.unpack(payload.Args))
end)

---------------------------------------------
-- PROFILING
---------------------------------------------

---Starts a profiling session.
---**Does nothing outside of Debug mode.**
---@param id string Session ID.
function Library:StartProfiling(id)
    if self.IS_DEBUG then
        Profiling.Start(self:GetPackagePrefix() .. id)
    end
end

---Adds a step to the current profiling session.
---**Does nothing outside of Debug mode.**
---@param stepID string
function Library:AddProfilingStep(stepID)
    if self.IS_DEBUG then
        Profiling.Step(stepID) -- No prefix necessary
    end
end

---Ends the current profiling session.
---**Does nothing outside of Debug mode.**
function Library:EndProfiling()
    if self.IS_DEBUG then
        Profiling.End()
    end
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