
---@class CoroutineLib : Feature
Coroutine = {

}
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
        Finished = SubscribableEvent:New("Finished"), ---@type SubscribableEvent<EmptyEvent>
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
---@vararg any Variables yielded. Discarded if the coroutine is resuming from sleeping, as there is no caller.
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

---------------------------------------------
-- TESTS
---------------------------------------------

-- Ext.Events.SessionLoaded:Subscribe(function (e)
--     if Ext.IsClient() then
--         Timer.Start("", 2, function()
--             print("Creating")
--             -- local inst = Coroutine.Create(function(inst)
--             --     inst:Sleep(1, "beforeSleep")
    
--             --     print("after sleep")
    
--             --     -- inst:Continue("test2")
--             -- end)
    
--             -- local inst2 = Coroutine.Create(function (inst_, ...)
--             --     inst_:Yield("test")
--             --     inst_:Sleep(1.1, "beforeSleep2")
    
--             --     print("after sleep2", ...)
--             -- end)
    
--             -- print(inst:Continue())
--             -- print(inst2:Continue(1, 2))
--             -- print(inst2:Continue(1, 2))
--             -- inst2:Continue(1, 2) -- "Attempted to yield from sleeping coroutine" warning

--             ------
--             local fun = function (inst, guid, name)

--                 -- Sleep 2 seconds and yield a string
--                 inst:Sleep(2, "Starting")

--                 Client.UI.ChatLog:PlaySound("Item_Potion_Consume")
    
--                 -- Sleep until the active client character is Ifan
--                 inst:Sleep(function()
--                     return Client.GetCharacter().MyGuid == guid
--                 end)
    
--                 local char = Character.Get(guid)
--                 assert(not Character.IsDead(char), name .. " is dead")
--             end
    
--             local test = Coroutine.Create(fun)
--             local test2 = Coroutine.Create(fun)
    
--             print(test:Continue("ad9a3327-4456-42a7-9bf4-7ad60cc9e54f", "Ifan")) -- "Starting"
--             print(test2:Continue("02a77f1f-872b-49ca-91ab-32098c443beb", "Fane")) -- "Starting"
--         end)
--     end
-- end)