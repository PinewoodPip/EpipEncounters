
---@class CoroutineLib : Feature
Coroutine = {}
Epip.InitializeLibrary("Coroutine", Coroutine)

---------------------------------------------
-- INSTANCE
---------------------------------------------

local _SleepRequest = {}
Inherit(_SleepRequest, {__name = "CoroutineSleepRequest", SleepTime = 0})

---@class CoroutineInstance
local _Instance = {
    thread = nil, ---@type thread
    sleeping = false,
}

---@return boolean
function _Instance:IsSleeping()
    return self.sleeping
end

---@vararg any Passed as params to the function.
---@return ...
function _Instance:Yield(...)
    if not self.sleeping then
        local result = {coroutine.resume(self.thread, self, ...)}

        if result[1] then
            table.remove(result, 1)
            table.remove(result, 1)
        
            return table.unpack(result)
        else
            return nil -- TODO log
        end
    else
        Coroutine:LogWarning("Attempted to yield from sleeping coroutine") -- TODO cancel sleeping and yield
        return nil
    end
end

---@param time number
---@vararg any Variables yielded.
function _Instance:Sleep(time, ...)
    local request = {SleepTime = time}
    Inherit(request, _SleepRequest)

    self.sleeping = true

    Timer.Start("", request.SleepTime, function()
        self.sleeping = false
        self:Yield()
    end)

    coroutine.yield(request, ...)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param fun fun(inst:CoroutineInstance, ...)
---@return CoroutineInstance
function Coroutine.Start(fun)
    local instance = {} ---@type CoroutineInstance
    local thread = coroutine.create(fun)
    Inherit(instance, _Instance)

    instance.thread = thread

    return instance
end

---------------------------------------------
-- TESTS
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function (e)
    Timer.Start("", 2, function()
        print("Creating")
        local inst = Coroutine.Start(function(inst)
            print("yay")
            coroutine.yield("test")

            inst:Sleep(1, "beforeSleep")

            print("after sleep")

            coroutine.yield("test2")
        end)

        print(inst:Yield())
        print(inst:Yield())

        inst:Yield()
    end)
end)