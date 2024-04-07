
local DefaultTable = DataStructures.Get("DataStructures_DefaultTable")

---@class ProfilingLib : Library
Profiling = {
    _SessionStack = {}, ---@type ProfilingLib.Session[]
    _FinishedSessions = DefaultTable.Create({}), ---@type table<string, ProfilingLib.Session[]> Stores the latest finished session of each session ID.

    _REPORT_DIVIDER = "---------------------",
}
Epip.InitializeLibrary("Profiling", Profiling)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class ProfilingLib.Session.StepReport
---@field ID string
---@field Amount integer
---@field TotalTime integer
---@field AverageTime number
---@field BestTime integer
---@field WorstTime integer

---@class ProfilingLib.Session : Class
---@field ID string Initializable.
---@field StartTime monotonictimestamp Defaults to current time.
---@field EndTime monotonictimestamp
---@field Steps ProfilingLib.Session[]
---@field SubSessions ProfilingLib.Session[]
---@field _SubSessionCount integer
---@field _StepCount integer
---@field _LatestStep ProfilingLib.Session?
local Session = {}
Profiling:RegisterClass("Session", Session)

---Creates a Session.
---@param data ProfilingLib.Session
---@return ProfilingLib.Session
function Session.Create(data)
    local instance = Session:__Create(data) ---@cast instance ProfilingLib.Session

    instance.StartTime = data.StartTime or Ext.Utils.MonotonicTime()
    instance.Steps = {}
    instance.SubSessions = {}
    instance._StepCount = 0
    instance._SubSessionCount = 0

    return instance
end

---Adds a subsession.
---@param subSession ProfilingLib.Session
function Session:AddSubSession(subSession)
    self.SubSessions[self._SubSessionCount + 1] = subSession
    self._SubSessionCount = self._SubSessionCount + 1
end

---Adds a step to the session.
---@param step ProfilingLib.Session
function Session:AddStep(step)
    self.Steps[self._StepCount + 1] = step
    self._StepCount = self._StepCount + 1
    self._LatestStep = step
end

---Returns the total time of the session.
---@return integer? -- In milliseconds. `nil` if the session hasn't ended.
function Session:GetTotalTime()
    local totalTime = 0

    -- Add time from each step
    for _,subSession in ipairs(self.Steps) do
        totalTime = totalTime + (subSession.EndTime - subSession.StartTime)
    end

    -- Add time between last step and the end of the session
    local lastStepTimeStamp = self:GetLastStepTimeStamp()
    totalTime = totalTime + (self.EndTime - lastStepTimeStamp)

    return totalTime
end

---Ends the session and sets the end time.
function Session:End()
    self.EndTime = Ext.Utils.MonotonicTime()
end

---Returns the end time stamp of the last step,
---or the start of the profiling session if no steps have been made yet.
function Session:GetLastStepTimeStamp()
    local lastStep = self:GetLatestStep()
    return lastStep and lastStep.EndTime or self.StartTime
end

---Returns the latest step of the session.
---@return ProfilingLib.Session
function Session:GetLatestStep()
    return self._LatestStep
end

---Returns information on the steps performed during the session.
---@return ProfilingLib.Session.StepReport[]
function Session:GetStepReports()
    local reports = {} ---@type ProfilingLib.Session.StepReport[]
    local reportsByType = {} ---@type table<string, ProfilingLib.Session.StepReport>

    for _,step in ipairs(self.Steps) do
        local report = reportsByType[step.ID]
        local time = step:GetTotalTime()

        if report then
            report.Amount = report.Amount + 1
            report.TotalTime = report.TotalTime + time
            report.BestTime = math.min(report.BestTime, time)
            report.WorstTime = math.max(report.WorstTime, time)
        else
            reportsByType[step.ID] = {
                ID = step.ID,
                TotalTime = time,
                BestTime = time,
                WorstTime = time,
                Amount = 1,
            }
            table.insert(reports, reportsByType[step.ID])
        end
    end

    -- Calculate average times for each step type
    for _,report in pairs(reportsByType) do
        report.AverageTime = report.TotalTime / report.Amount
    end

    return reports
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Starts a profiling session.
---@param id string
---@return ProfilingLib.Session
function Profiling.Start(id)
    local session = Session.Create({
        ID = id,
    })

    table.insert(Profiling._SessionStack, session)

    return session
end

---Denotes the end of a step within the current profiling session.
---@param name string?
function Profiling.Step(name)
    local session = Profiling.GetCurrentSession()
    if not session then Profiling:Error("Step", "No session running") end
    local step = Session.Create({
        ID = name or "Unnamed",
    })
    step.StartTime = session:GetLastStepTimeStamp()
    step.EndTime = Ext.Utils.MonotonicTime()

    session:AddStep(step)
end

---Ends the current profiling session.
function Profiling.End()
    local session = Profiling.GetCurrentSession()
    if not session then Profiling:Error("End", "No session running") end

    session:End()
    Profiling._SessionStack[#Profiling._SessionStack] = nil
    table.insert(Profiling._FinishedSessions[session.ID], session)

    -- If there are sessions remaining in the stack, add this session as a subsession of the previous session in the stack
    local previousSession = Profiling:GetCurrentSession()
    if previousSession then
        previousSession:AddSubSession(session)
    end
end

---Returns the session at the top of the stack.
---@return ProfilingLib.Session?
function Profiling.GetCurrentSession()
    return Profiling._SessionStack[#Profiling._SessionStack]
end

---Returns the finished sessions with a certain ID.
---@param id string
---@return ProfilingLib.Session[]
function Profiling.GetFinishedSessions(id)
    return Profiling._FinishedSessions[id]
end

---Returns a report of the times of sessions with a specific ID.
---@param id string
---@return string
function Profiling.Report(id)
    local sessions = Profiling.GetFinishedSessions(id)
    local sessionsCount = #sessions
    if sessionsCount == 0 then return "No sessions with ID " .. id end
    local report = {}

    table.insert(report, Profiling._REPORT_DIVIDER)
    table.insert(report, string.format("%d %s sessions", sessionsCount, id))
    table.insert(report, Profiling._REPORT_DIVIDER)

    local bestTime = math.maxinteger
    local worstTime = math.mininteger
    local totalTime = 0 -- Total time of all sessions
    for _,session in ipairs(sessions) do -- For each session
        local reports = session:GetStepReports()
        local time = session:GetTotalTime()

        bestTime = math.min(bestTime, time)
        worstTime = math.max(worstTime, time)
        totalTime = totalTime + time

        table.insert(report, string.format("%d ms with %d steps", time, #session.Steps))

        -- Report steps
        for _,stepReport in ipairs(reports) do
            local reportValues = {
                Text.AddPadding(stepReport.ID, 25, nil, "back"),
                string.format("Amount %d", stepReport.Amount),
                string.format("Total %dms", stepReport.TotalTime),
                string.format("Avg %0.2fms", stepReport.AverageTime),
                string.format("Best %0.2fms", stepReport.BestTime),
                string.format("Worst %0.2fms", stepReport.WorstTime),
            }
            local line = {"     "}
            for _,value in ipairs(reportValues) do
                table.insert(line, Text.AddPadding(value, 15, nil, "back"))
            end
            table.insert(report, Text.Join(line, " "))
        end

        -- Report subsessions
        if session.SubSessions[1] then
            local subSessionTypes = DefaultTable.Create({Amount = 0, TotalTime = 0}) ---@type table<string, {Amount:integer, TotalTime:integer}>

            table.insert(report, Profiling._REPORT_DIVIDER)
            table.insert(report, string.format("%d Subsessions", #session.SubSessions))

            for _,subSession in ipairs(session.SubSessions) do
                local record = subSessionTypes[subSession.ID]

                record.Amount = record.Amount + 1
                record.TotalTime = record.TotalTime + subSession:GetTotalTime()
            end

            for subSessionID,subSessionReport in pairs(subSessionTypes) do
                local reportValues = {
                    Text.AddPadding(subSessionID, 50, nil, "back"),
                    string.format("Amount %d", subSessionReport.Amount),
                    string.format("Total %dms", subSessionReport.TotalTime),
                    string.format("Avg %0.2fms", subSessionReport.TotalTime / subSessionReport.Amount),
                }
                local line = {"     "}
                for _,value in ipairs(reportValues) do
                    table.insert(line, Text.AddPadding(value, 15, nil, "back"))
                end
                table.insert(report, Text.Join(line, " "))
            end
        end
        table.insert(report, Profiling._REPORT_DIVIDER)
    end

    table.insert(report, string.format("%d sessions", sessionsCount))
    table.insert(report, "Best time: " .. bestTime .. "ms")
    table.insert(report, "Worst time: " .. worstTime .. "ms")
    table.insert(report, "Average time: " .. totalTime / sessionsCount .. "ms")
    table.insert(report, Profiling._REPORT_DIVIDER)

    return Text.Join(report, "\n")
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Handle console commands.
Ext.RegisterConsoleCommand("profiling", function (_, command, id)
    if command == "report" then
        print(Profiling.Report(id))
    end
end)