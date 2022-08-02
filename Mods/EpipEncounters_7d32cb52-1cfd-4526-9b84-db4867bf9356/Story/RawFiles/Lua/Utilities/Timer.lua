
---------------------------------------------
-- Script for timers.
---------------------------------------------

Timer = {
    UI = nil,
    Root = nil,

    eventHandlers = {},

    ---@type ClientTimerEntry[]
    activeTimers = {},
    previousTime = nil,
}
Epip.InitializeLibrary("Timer", Timer)

---@class ClientTimerEntry
---@field Event string
---@field DurationLeft number
---@field InitiialDuration number
---@field Handler function

---------------------------------------------
-- METHODS
---------------------------------------------

function Timer.Start(event, seconds, handler)
    seconds = seconds or 0.001

    table.insert(Timer.activeTimers, {
        Event = event,
        InitialDuration = seconds,
        DurationLeft = seconds,
        Handler = handler,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Decrement timer durations.
Ext.Events.Tick:Subscribe(function()
    local time = Ext.MonotonicTime()

    if not Timer.previousTime then
        Timer.previousTime = time
        return nil
    end

    local deltaTime = time - Timer.previousTime

    for i,timer in ipairs(Timer.activeTimers) do
        timer.DurationLeft = timer.DurationLeft - (deltaTime / 1000)

        if timer.DurationLeft <= 0 then
            if timer.Handler then
                pcall(timer.Handler)
            end
            Utilities.Hooks.FireEvent("Timer", "TimerComplete_" .. timer.Event)

            Timer:DebugLog("Timer finished: " .. timer.Event)

            table.remove(Timer.activeTimers, i)
        end
    end

    Timer.previousTime = time
end)

-- Registers a function to be called when a timer completes.
function Timer.RegisterListener(event, handler)
    Utilities.Hooks.RegisterListener("Timer", "TimerComplete_" .. event, handler)
end