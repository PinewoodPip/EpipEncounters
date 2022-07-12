
---@meta Library: Feature, ContextShared, Feature

---------------------------------------------
-- Base table for features and libraries.
---------------------------------------------

---@class Feature
---@field Name string Used for logging, event handling. Do not set!
---@field CONTEXT Context Set automatically.
---@field Disabled boolean
---@field Logging integer Logging level.
---@field Events table<string, Event> Metatables initialized automatically.
---@field Hooks table<string, Hook> Metatables initialized automatically.
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
---@field Log fun(self, msg:string)
---@field RawLog fun(self, ...:any)
---@field LogWarning fun(self, msg)
---@field LogError fun(self, msg)

---@type Feature
local Feature = {
    Name = "",
    Disabled = false,
    Logging = 0,

    Events = {},
    Hooks = {},

    CONTEXT = nil,
    LOGGING_LEVEL = {
        DEBUG = -1,
        ALL = 0,
        WARN = 1,
        MUTED = 2, -- Errors only.
    },
    REQUIRED_MODS = {},
    FILEPATH_OVERRIDES = {},
}
_Feature = Feature

-- .CONTEXT is... context-dependent.
if Ext.IsClient() then
    Feature.CONTEXT = "Client"
else
    Feature.CONTEXT = "Server"
end

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Add an event to the Events field.
---@param name string
---@param data? Event
---@return Event
function Feature:AddEvent(name, data)
    local event = data or {Module = self.Name, Event = name}
    event.Module = self.Name
    event.Event = name

    setmetatable(event, {__index = _Event})

    self.Events[name] = event

    return event
end

---Add a hook to the Hooks field.
---@param name string
---@param data? Hook
---@return Hook
function Feature:AddHook(name, data)
    local hook = data or {Module = self.Name, Event = name}
    hook.Module = self.Name
    hook.Event = name

    setmetatable(hook, {__index = _Hook})

    self.Hooks[name] = hook

    return hook
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether the feature has *not* been disabled. Use to condition your feature's logic.
---@return boolean
function Feature:IsEnabled()
    return not self.Disabled
end

---Invoked on SessionLoaded if the feature is not disabled.
---Override to run initialization routines.
function Feature:__Setup() end

---Sets the Disabled flag.
function Feature:Disable()
    -- TODO fix
    self.Disabled = true
    if self._initialized then
        for old,new in pairs(self.FILEPATH_OVERRIDES) do
            self:LogError(self.Name .. " cannot be disabled post-startup as it uses FILEPATH_OVERRIDES!")
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
-- LISTENER/HOOK FUNCTIONS
---------------------------------------------

---Register an event listener.
---To define events with multiple variables, you can easily create a wrapper function for this (and FireEvent)
---that registers an event listener with a prefix(es).
---@param event string
---@param handler function
function Feature:RegisterListener(event, handler)
    Utilities.Hooks.RegisterListener(self.Name, event, handler)
end

---Fire an event.
---@param event string
---@vararg any Event parameters, passed to listeners.
function Feature:FireEvent(event, ...)
    Utilities.Hooks.FireEvent(self.Name, event, ...)
end

---Register a hook.
---@param event string
---@param handler function
function Feature:RegisterHook(event, handler)
    Utilities.Hooks.RegisterHook(self.Name, event, handler)
end

---Get a value from registered hook listeners.
---@param event string
---@param defaultValue any Default value, will be passed to the first listener.
---@vararg any Additional parameters (non-modifiable)
function Feature:ReturnFromHooks(event, defaultValue, ...)
    return Utilities.Hooks.ReturnFromHooks(self.Name, event, defaultValue, ...)
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
    if Ext.IsDeveloperMode() then
        self.IS_DEBUG = true
        self.Logging = self.LOGGING_LEVEL.DEBUG
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
    if self.Logging == self.LOGGING_LEVEL.DEBUG and not IS_IMPROVED_HOTBAR then
        Utilities._Log(self.Name, "", ...)
    end
end

---Dump a value to the console, in Debug mode.
---@param msg any
function Feature:Dump(msg)
    if self.Logging == self.LOGGING_LEVEL.DEBUG then
        _D(msg)
    end
end

---Log a value.
---@param msg any
function Feature:Log(msg)
    if self.Logging <= self.LOGGING_LEVEL.ALL then
        Utilities.Log(self.Name, msg)
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
        Utilities.LogWarning(self.Name, msg)
    end
end

---Log an error.
---@param msg any
function Feature:LogError(msg)
    Utilities.LogError(self.Name, msg)
end