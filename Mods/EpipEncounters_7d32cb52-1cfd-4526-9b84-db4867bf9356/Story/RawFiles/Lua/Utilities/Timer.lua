
---------------------------------------------
-- Library for running callbacks on a timer.
-- Available on both contexts; mainly used for client scripting.
---------------------------------------------

---@class TimerLib : Feature
Timer = {
    UI = nil,
    Root = nil,

    eventHandlers = {},

    ---@type TimerLib_Entry[]
    activeTimers = {},
    previousTime = nil,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        TimerCompleted = {}, ---@type Event<TimerLib_Event_TimerCompleted>
    },
}
Epip.InitializeLibrary("Timer", Timer)

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class TimerLib_Event_TimerCompleted
---@field Timer TimerLib_Entry

---------------------------------------------
-- TIMER ENTRY
---------------------------------------------

---@class TimerLib_Entry
---@field ID string?
---@field DurationLeft number
---@field InitialDuration number
---@field RepeatCount integer How many times the timer has repeated.
---@field private MaxRepeatCount integer The maximum amount of times the timer can fire. Values below 0 indicate no limit.
---@field Paused boolean
local _TimerEntry = {
    MaxRepeatCount = 1,
    RepeatCount = 0,
    ID = "",
}

function _TimerEntry:Pause()
    self.Paused = true
end

function _TimerEntry:Resume()
    self.Paused = false
end

function _TimerEntry:Cancel()
    Timer.Remove(self)
end

---@param repeats integer Set to -1 to repeat infinitely.
function _TimerEntry:SetRepeatCount(repeats)
    self.MaxRepeatCount = repeats
end

---@param deltaTime number
---@return boolean Whether the timer has finished one iteration due to this call.
function _TimerEntry:TickDown(deltaTime)
    local finished = false

    self.DurationLeft = self.DurationLeft - (deltaTime / 1000)

    if self.DurationLeft <= 0 then
        self.RepeatCount = self.RepeatCount + 1
        self.DurationLeft = self.InitialDuration

        finished = true
    end

    return finished
end

---@return boolean
function _TimerEntry:IsFinished()
    return self.RepeatCount >= self.MaxRepeatCount and self.MaxRepeatCount >= 0
end

---@param fun fun(ev:TimerLib_Event_TimerCompleted)
function _TimerEntry:Subscribe(fun)
    Timer.Events.TimerCompleted:Subscribe(function(ev)
        if ev.Timer == self then
            fun(ev)
        end
    end, {_TimerLib_Entry = self})
end

---------------------------------------------
-- TICK TIMER
---------------------------------------------

---@class TimerLib_TickTimerEntry : TimerLib_Entry
local _TickTimer = {}
Inherit(_TickTimer, _TimerEntry)

function _TickTimer:TickDown(_)
    return _TimerEntry.TickDown(self, 1000) -- Tick timers tick down one unit every call.
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@overload fun(seconds:number, handler?:fun(ev:TimerLib_Event_TimerCompleted), id?:string):TimerLib_Entry|TimerLib_TickTimerEntry
---@param id string?
---@param seconds number
---@param handler fun(ev:TimerLib_Event_TimerCompleted)
---@param timerType ("Normal"|"Tick")? Defaults to `"Normal"`
---@return TimerLib_Entry|TimerLib_TickTimerEntry
function Timer.Start(id, seconds, handler, timerType)
    local timerTable = _TimerEntry
    if timerType then
        if timerType == "Tick" then
            timerTable = _TickTimer
        end
    end

    -- Overload
    if type(id) ~= "string" then
        ---@diagnostic disable-next-line: cast-local-type
        id, seconds, handler = handler, id, seconds
    end

    ---@diagnostic disable-next-line: cast-local-type
    seconds = seconds or 0.001

    ---@type TimerLib_Entry
    local entry = {
        ID = id or "",
        InitialDuration = seconds,
        DurationLeft = seconds,
        MaxRepeatCount = 1,
        RepeatCount = 0,
    }
    Inherit(entry, timerTable)

    -- Replace the old timer, if any.
    if id ~= "" then
        local oldTimer = Timer.GetTimer(id)
        if oldTimer then
            oldTimer:Cancel()
        end
    end

    -- Auto-subscribe handler
    if handler then
        entry:Subscribe(handler)
    end

    table.insert(Timer.activeTimers, entry)

    return entry
end

---@overload fun(ticks:number, handler?:fun(ev:TimerLib_Event_TimerCompleted), id?:string):TimerLib_TickTimerEntry
---@param id string?
---@param ticks number
---@param handler fun(ev:TimerLib_Event_TimerCompleted)
---@return TimerLib_TickTimerEntry
function Timer.StartTickTimer(id, ticks, handler)
    ---@diagnostic disable-next-line: return-type-mismatch
    return Timer.Start(id, ticks, handler, "Tick") -- wtf lmao what is this diagnostic
end

---Returns the timer with the passed string ID.
---@param stringID string
---@return TimerLib_Entry
function Timer.GetTimer(stringID)
    local entry

    for _,timer in ipairs(Timer.activeTimers) do
        if timer.ID == stringID then
            entry = timer
            break
        end
    end

    return entry
end

---@param timer TimerLib_Entry
function Timer.Remove(timer)
    local index

    for i,entry in ipairs(Timer.activeTimers) do
        if entry == timer then
            index = i
            break
        end
    end

    if index then
        table.remove(Timer.activeTimers, index)

        -- Unsubscribe listeners
        Timer.Events.TimerCompleted:RemoveNodes(function(node)
            return node.Options._TimerLib_Entry == timer
        end)
    else
        Timer:LogError("Failed to remove timer")
        Timer:Dump(timer)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Decrement timer durations.
Ext.Events.Tick:Subscribe(function()
    local time = Ext.MonotonicTime()
    if not Timer.previousTime then
        Timer.previousTime = time
    else
        local deltaTime = time - Timer.previousTime

        for _,timer in ipairs(Timer.activeTimers) do
            if not timer.Paused then
                if timer:TickDown(deltaTime) then
                    Timer.Events.TimerCompleted:Throw({
                        Timer = timer,
                    })

                    if timer.ID ~= "" then
                        Timer:DebugLog("Timer finished: " .. timer.ID)
                    end
                end
            end
        end

        -- Remove timers once they deplete their repeats
        for i=#Timer.activeTimers,1,-1 do
            local timer = Timer.activeTimers[i]

            if timer:IsFinished() then
                Timer.Remove(timer)
            end
        end

        Timer.previousTime = time
    end
end)
