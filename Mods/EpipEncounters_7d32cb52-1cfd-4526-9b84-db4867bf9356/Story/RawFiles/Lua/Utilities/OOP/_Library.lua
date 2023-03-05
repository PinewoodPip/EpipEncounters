

---------------------------------------------
-- Utility class for libraries.
-- Provides logging and Observer implementations.
---------------------------------------------

---@class Library : Class
---@field _Classes table<string, Class> Subclasses registered for this library.
---@field protected __ModTable string
---@field protected __LoggingLevel Library_LoggingLevel
---@field protected __IsDebug boolean
local Library = {
    ---@enum Library_LoggingLevel
    LOGGING_LEVELS = {
        ALL = 0,
        WARN = 1,
        MUTED = 2, -- Errors only.
    },
    USE_LEGACY_EVENTS = true,
    USE_LEGACY_HOOKS = true,
}
OOP.RegisterClass("Library", Library)

---------------------------------------------
-- METHODS
---------------------------------------------

---Initializes a table as a Library.
---@param modTable string
---@param id string
---@param data Library
---@return Library
function Library.Create(modTable, id, data)
    ---@diagnostic disable: invisible
    data.__ModTable = modTable
    data.__name = id
    data.__IsDebug = false
    data.__LoggingLevel = Library.LOGGING_LEVELS.ALL
    ---@diagnostic enable: invisible

    ---@type Library
    local lib = OOP.GetClass("Library"):__Create(data)
    
    -- Initialize events and hooks.
    data.Events = data.Events or {}
    for ev,opts in pairs(data.Events) do
        -- TODO resolve Event class
        ---@diagnostic disable-next-line: undefined-field
        if opts.Legacy == false or data.USE_LEGACY_EVENTS == false then
            data:AddSubscribableEvent(ev, opts.Preventable)
        else
            data:AddEvent(ev, opts)
        end
    end
    data.Hooks = data.Hooks or {}
    for hook,opts in pairs(data.Hooks) do
        ---@diagnostic disable-next-line: undefined-field
        if opts.Legacy == false or data.USE_LEGACY_HOOKS == false then
            data:AddSubscribableHook(hook, opts.Preventable)
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
    
    -- Create class holder
    data._Classes = {}

    return lib
end

---Returns the package prefix for this library's subclasses.
---@return string
function Library:GetPackagePrefix()
    return string.format("%s_%s_", self.__ModTable, self.__name)
end

---------------------------------------------
-- DEBUGGING
---------------------------------------------

---Show debug-level logging from this library.
---Only work in Developer mode.
function Library:Debug()
    if Epip.IsDeveloperMode() then
        self.IS_DEBUG = true
    end
end

---Returns whether :Debug() has been ran successfully.
---@return boolean
function Library:IsDebug()
    return self.IS_DEBUG
end

---------------------------------------------
-- LOGGING
---------------------------------------------

---Stop all non-error, non-warning logging from this feature.
function Library:Mute()
    self.__LoggingLevel = self.LOGGING_LEVELS.WARN
end

---Stop all non-error logging.
function Library:ShutUp()
    self.__LoggingLevel = self.LOGGING_LEVELS.MUTED
end

---Log a value in Debug mode.
---@vararg any
function Library:DebugLog(...)
    if self:IsDebug() then
        Utilities._Log(self.__name, "", ...)
    end
end

---Log a message in the format "[MODULE] method(): msg"
---@param method any
---@param ... any
function Library:LogMethod(method, ...)
    if self:IsDebug() then
        Utilities._Log(self.__name, string.format("%s():", method), ...)
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
---@param msg any
function Library:Log(msg)
    if self.__LoggingLevel <= self.LOGGING_LEVELS.ALL then
        Utilities.Log(self.__name, msg)
    end
end

---Log values without any prefixing.
---@vararg any
function Library:RawLog(...)
    if self.__LoggingLevel <= self.LOGGING_LEVELS.ALL then
        print(...)
    end
end

---Log a warning.
---@param msg any
function Library:LogWarning(msg)
    if self.__LoggingLevel <= self.LOGGING_LEVELS.WARN then
        Utilities.LogWarning(self.__name, msg)
    end
end

---Logs a "Not implemented" warning. Use as a placeholder.
---@param methodName string
function Library:LogNotImplemented(methodName)
    self:LogWarning("Not implemented: " .. methodName)
end

---Log an error.
---@param msg any
function Library:LogError(msg)
    Utilities.LogError(self.__name, msg)
end

---Throws an error.
---@param method string
function Library:Error(method, ...)
    local params = {...}
    local str = Text.Join(params, " ")
    error(Text.Format("%s(): %s", {FormatArgs = {method, str}}))
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
        Library:Error("GetClass", "Attemped to fetch an unregistered class: ", className, "- Make sure the class is from this library.")
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

    self.Events[evName] = event

    return event
end

---Registers a new hook.
---@param evName string
---@param preventable boolean? Defaults to false.
---@return Event
function Library:AddSubscribableHook(evName, preventable)
    local event = SubscribableEvent:New(evName, preventable)

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

    self.Events[name] = event

    return event
end

---Add a hook to the Hooks field.
---@deprecated Use `AddSubscribableHook()` instead.
---@param name string
---@param data? Hook
---@return Hook
function Library:AddHook(name, data)
    local hook = data or {Module = self.__name, Event = name}
    hook.Module = self.__name
    hook.Event = name

    Inherit(hook, _Hook)

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
-- SETUP
---------------------------------------------

-- Initialize persistent vars.
if Ext.IsServer() then
    if not PersistentVars.Features then
        PersistentVars.Features = {}
    end
end