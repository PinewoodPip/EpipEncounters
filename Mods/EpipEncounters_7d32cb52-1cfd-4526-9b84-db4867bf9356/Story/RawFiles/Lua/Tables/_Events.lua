
---------------------------------------------
-- Wrapper classes for invoking events/hooks and registering listeners onto them.
-- Advantage is being able to annotate parameters for listeners/invokes.
---------------------------------------------

---------------------------------------------
-- EVENTS
---------------------------------------------

_Event = {
    Module = "",
    Event = "",
}

---Register a listener.
---@param fun fun(...)
function _Event:RegisterListener(fun)
    Utilities.Hooks.RegisterListener(self.Module, self.Event, fun)
end

---Fire an event.
---@vararg any Event parameters.
function _Event:Fire(...)
    Utilities.Hooks.FireEvent(self.Module, self.Event, ...)
end

---------------------------------------------
-- HOOKS
---------------------------------------------

---Deprecated.
---@see Hook
---@class LegacyHook
---@field Module string
---@field Event string
---@field Options any TODO document
_Hook = {
    Module = "",
    Event = "",
}

---Register a hook.
---@param handler fun(...)
function _Hook:RegisterHook(handler)
    Utilities.Hooks.RegisterHook(self.Module, self.Event, handler)
end

---@param defaultValue any
---@vararg any
function _Hook:Return(defaultValue, ...)
    return Utilities.Hooks.Return(self.Module, self.Event, defaultValue, self.Options, ...)
end