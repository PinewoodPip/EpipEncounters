
---------------------------------------------
-- Script for client-side timers, powered by the flash UI. 
---------------------------------------------

Client.Timer = {
    UI = nil,
    Root = nil,

    eventHandlers = {},

    ---@type ClientTimerEntry[]
    activeTimers = {},
    previousTime = nil,
}
Epip.InitializeLibrary("Timer", Client.Timer)

---@class ClientTimerEntry
---@field Event string
---@field DurationLeft number
---@field InitiialDuration number
---@field Handler function

local Timer = Client.Timer

function Timer.Start(event, seconds, handler)
    seconds = seconds or 0.001

    -- Timer.eventHandlers[event] = handler
    -- Game.Net.PostToServer("EPIPENCOUNTERS_Timer", {Event = event, Seconds = seconds, NetID = Client.GetCharacter().NetID})

    -- Timer.Root.startTimer(event, seconds)

    table.insert(Timer.activeTimers, {
        Event = event,
        InitialDuration = seconds,
        DurationLeft = seconds,
        Handler = handler,
    })
end

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

---------------------------------------------
-- LISTENERS
---------------------------------------------
local function OnTimerComplete(ui, method, event)
    if Timer.eventHandlers[event] then
        Timer.eventHandlers[event]()
    end

    Utilities.Hooks.FireEvent("Timer", "TimerComplete_" .. event)
end

-- TEMP
Game.Net.RegisterListener("EPIPENCOUNTERS_Timer", function(cmd, payload)
    OnTimerComplete(nil, nil, payload.Event)
end)

Ext.Events.SessionLoaded:Subscribe(function()
    -- TODO separate UI
    -- Timer.UI = Client.UI.ContextMenu.UI
    -- Timer.Root = Client.UI.ContextMenu.Root

    -- Ext.RegisterUICall(Timer.UI, "pipTimerComplete", OnTimerComplete)
end)