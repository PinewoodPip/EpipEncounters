
---------------------------------------------
-- Library for running callbacks on a timer.
-- Available on both contexts; mainly used for client scripting.
---------------------------------------------

local MonotonicTime = Ext.Utils.MonotonicTime

---@class TimerLib : Feature
Timer = {
    UI = nil,
    Root = nil,

    _ActiveTimers = {}, ---@type TimerLib_Entry[]
    _Timers = {}, ---@type table<string, TimerLib_Entry>

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
---@field _MaxRepeatCount integer The maximum amount of times the timer can fire. Values below 0 indicate no limit.
---@field ___Handlers fun(self)[]
---@field Paused boolean
local _TimerEntry = {
    _MaxRepeatCount = 1,
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
    self._MaxRepeatCount = repeats
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
    return self.RepeatCount >= self._MaxRepeatCount and self._MaxRepeatCount >= 0
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
        _MaxRepeatCount = 1,
        RepeatCount = 0,
        ___Handlers = {},
    }
    Inherit(entry, timerTable)

    -- Replace the old timer, if any.
    if id and id ~= "" then
        local oldTimer = Timer.GetTimer(id)
        if oldTimer then
            oldTimer:Cancel()
        end
    end

    -- Auto-subscribe handler
    if handler then
        ---@diagnostic disable-next-line: invisible
        entry.___Handlers[1] = handler
    end

    -- Track the timer
    table.insert(Timer._ActiveTimers, entry)
    if id then
        -- Note: it is possible to register multiple timers with the same ID at once.
        -- They will tick properly through _ActiveTimers, but only the latest one
        -- will be retrievable by ID.
        Timer._Timers[id] = entry
    end

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

---Returns the **latest-registered** running timer with the passed string ID.
---@param stringID string
---@return TimerLib_Entry
function Timer.GetTimer(stringID)
    return Timer._Timers[stringID]
end

---@param timer TimerLib_Entry
function Timer.Remove(timer)
    local index

    for i,entry in ipairs(Timer._ActiveTimers) do
        if entry == timer then
            index = i
            break
        end
    end

    if timer.ID then
        Timer._Timers[timer.ID] = nil -- TODO re-assign to any previous existing timer with the ID?
    end

    if index then
        table.remove(Timer._ActiveTimers, index)

        -- Unsubscribe listeners
        Timer.Events.TimerCompleted:RemoveNodes(function(node)
            return node.Options._TimerLib_Entry == timer
        end)
    else
        Timer:__LogError("Failed to remove timer")
        Timer:Dump(timer)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

local _PreviousTime = nil

-- Decrement timer durations.
Ext.Events.Tick:Subscribe(function()
    local time = MonotonicTime()
    if not _PreviousTime then
        _PreviousTime = time
    else
        local deltaTime = time - _PreviousTime
        for _,timer in ipairs(Timer._ActiveTimers) do
            if not timer.Paused then
                if timer:TickDown(deltaTime) then
                    -- Dispatch handlers
                    local handlers = timer.___Handlers
                    for _,handler in ipairs(handlers) do
                        handler(timer)
                    end

                    -- Only throw global event if anything is listening to it.
                    if Timer.Events.TimerCompleted.First then
                        Timer.Events.TimerCompleted:Throw({
                            Timer = timer,
                        })
                    end
                end
            end
        end

        -- Remove timers once they deplete their repeats
        for i=#Timer._ActiveTimers,1,-1 do
            local timer = Timer._ActiveTimers[i]
            if timer:IsFinished() then
                Timer.Remove(timer)
            end
        end

        Timer.previousTime = time
    end
end)
