
---@class TestingLib.Test : Class
---@field ID string
---@field Function fun(inst:CoroutineInstance) Can be coroutinable, but may only sleep, not yield.
local _Test = {}
Testing:RegisterClass("TestingLib.Test", _Test)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Library.Test.Events.Finished
---@field Result "Passed"|"Failed"

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a test.
---@param data TestingLib.Test
function _Test:Create(data)
    data = self:__Create(data) ---@cast data TestingLib.Test

    return data
end

---@param handler fun(ev:Library.Test.Events.Finished)
function _Test:Run(handler)
    local coro = Coroutine.Create(self.Function)
    local succeeded = false
    local subscriberID = Text.GenerateGUID()

    -- Should be registered before beginning the coroutine.
    coro.Events.Finished:Subscribe(function (_)
        succeeded = true
        handler({
            Result = "Passed",
        })
        GameState.Events.Tick:Unsubscribe(subscriberID)
    end)

    local success, errorMsg = pcall(coro.Continue, coro)
    if not success then -- Report failure from initial call.
        error(errorMsg)
    else -- Otherwise monitor the coroutine for failures.
        GameState.Events.Tick:Subscribe(function (_)
            if not succeeded and coro:IsDead() then
                handler({
                    Result = "Failed"
                })
                GameState.Events.Tick:Unsubscribe(subscriberID)
            elseif coro:IsDead() then
                GameState.Events.Tick:Unsubscribe(subscriberID)
            end
        end, {StringID = subscriberID})
    end
end
