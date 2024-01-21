
---@class CoroutineLib : Library
Coroutine = {}
Epip.InitializeLibrary("Coroutine", Coroutine)

---------------------------------------------
-- INSTANCE
---------------------------------------------

---@class CoroutineInstance
local _Instance = {
    thread = nil, ---@type thread
    sleeping = false,
    sleepFunctionCheckInterval = 0.2,

    Events = {
        Finished = SubscribableEvent:New("Finished"), ---@type Event<Empty>
    },
}

---@return boolean
function _Instance:IsSleeping()
    return self.sleeping
end

---@vararg any Passed as params to the function.
---@return ...
function _Instance:Continue(...)
    if not self.sleeping then
        local result = {coroutine.resume(self.thread, self, ...)}

        if result[1] then
            table.remove(result, 1) -- Success check
            table.remove(result, 1) -- Reserved for future methods

            -- Fire a status when a coroutine ends.
            if self:IsDead() then
                self.Events.Finished:Throw()
            end

            return table.unpack(result)
        else
            local error = result[2]

            Ext.PrintError("Error in coroutine: " .. error)

            return nil
        end
    else
        Coroutine:LogWarning("Attempted to yield from sleeping coroutine") -- TODO cancel sleeping and yield
        return nil
    end
end

---@param time number|function
---@param ... any Variables yielded. Discarded if the coroutine is resuming from sleeping, as there is no caller.
function _Instance:Sleep(time, ...)
    self.sleeping = true

    if type(time) == "function" then -- Sleep until function returns true (checking periodically)
        local fun = time
        Timer.Start("", self.sleepFunctionCheckInterval, function()
            if fun() then
                self.sleeping = false
                self:Continue() -- Resume execution
            else
                self:Sleep(fun)
            end
        end)
    else -- Sleep X seconds
        Timer.Start("", time, function()
            self.sleeping = false
            self:Continue() -- Resume execution
        end)
    end

    coroutine.yield({}, ...) -- Returns to resume() call from Continue()
end

---@vararg any
function _Instance:Yield(...)
    coroutine.yield({}, ...)
end

---@return boolean
function _Instance:IsDead()
    return coroutine.status(self.thread) == "dead"
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param fun fun(inst:CoroutineInstance, ...)
---@return CoroutineInstance
function Coroutine.Create(fun)
    local instance = {} ---@type CoroutineInstance
    local thread = coroutine.create(fun)
    Inherit(instance, _Instance)

    instance.thread = thread

    return instance
end