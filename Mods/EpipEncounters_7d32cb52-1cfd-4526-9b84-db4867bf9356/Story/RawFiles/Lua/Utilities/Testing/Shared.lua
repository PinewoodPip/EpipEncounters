
---@class TestingLib : Library
Testing = {
    _Testables = {}, ---@type table<table, true>
}
Epip.InitializeLibrary("Testing", Testing)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class TestingLib.TestMixin
---@field ___Tests table<string, TestingLib.Test>

---@class TestingLib.TestResults
---@field TotalTests integer
---@field CompletedTests integer Amount of tests passed before the first failed one. Will be equal to `TotalTests` if no tests failed. 
---@field Result "Passed"|"Failed"

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a test.
---@param tbl table
---@param test TestingLib.Test Will be instantiated.
function Testing.RegisterTest(tbl, test)
    if not OOP.IsClass(test) then
        test = Testing:GetClass("TestingLib.Test"):Create(test)
    end
    Testing._InitializeMixin(tbl)
    ---@cast tbl TestingLib.TestMixin
    tbl.___Tests[test.ID] = test
end

---Returns the tests registered for a table.
---@param tbl TestingLib.TestMixin
---@return table<string, TestingLib.Test>
function Testing.GetTests(tbl)
    return tbl.___Tests
end

---Runs the tests registered for a table.
---@async
---@param tbl table
---@param callback fun(ev:TestingLib.TestResults)
function Testing.RunTests(tbl, callback)
    if not Testing._HasTests(tbl) then
        Testing:__Error("RunTests", "Table has no tests registered")
    end

    -- Create a list of tests sorted by ID
    ---@cast tbl TestingLib.TestMixin
    local tests = {} ---@type TestingLib.Test[]
    for _,test in pairs(tbl.___Tests) do
        table.insert(tests, test)
    end
    table.sort(tests, function (a, b)
        return a.ID < b.ID
    end)

    local totalTests = #tests
    local subscriberID = Text.GenerateGUID()
    local running = false
    local result = nil
    GameState.Events.Tick:Subscribe(function (_)
        if tests[1] and not running then
            local test = tests[1]
            table.remove(tests, 1)
            running = true

            Testing:__Log(tbl, "Running test", test.ID)
            test:Run(function (ev)
                if ev.Result == "Failed" then -- Set final result if the test failed
                    Testing:__Log(tbl, "Test failed", test.ID)
                    result = ev.Result
                    callback({
                        TotalTests = totalTests,
                        CompletedTests = totalTests - #tests,
                        Result = "Failed",
                    })
                end
                if not next(tests) then -- Set final result if no more tests remain
                    result = ev.Result
                end
                running = false
            end)
        end
        -- End the listener once a result has been reached (all tests passed or any failed)
        if result then
            Testing:__Log(tbl, result == "Passed" and "Tests finished" or "Tests failed")
            callback({
                TotalTests = totalTests,
                CompletedTests = totalTests - #tests,
                Result = result,
            })
            GameState.Events.Tick:Unsubscribe(subscriberID)
        end
    end, {StringID = subscriberID})
end

---Runs all registered tests.
function Testing.RunAll()
    local testables = {} ---@type TestingLib.TestMixin[]
    for testable,_ in pairs(Testing._Testables) do
        table.insert(testables, testable)
    end

    local subscriberID = Text.GenerateGUID()
    local running = false
    GameState.Events.Tick:Subscribe(function (_)
        if testables[1] and not running then
            local testable = testables[1]
            table.remove(testables, 1)
            running = true
            Testing:__Log(testable, "Running all tests for ", testable)
            Testing.RunTests(testable, function (ev)
                if ev.Result == "Failed" then
                    Ext.Utils.PrintWarning("Test failed for", testable)
                    GameState.Events.Tick:Unsubscribe(subscriberID)
                end
                running = false
            end)
        elseif not testables[1] and not running then
            GameState.Events.Tick:Unsubscribe(subscriberID)
            Testing:__Log("All tests finished")
        end
    end, {StringID = subscriberID})
end

---Initializes the test holder for a table.
---@param tbl table
function Testing._InitializeMixin(tbl)
    ---@cast tbl TestingLib.TestMixin
    if not tbl.___Tests then
        tbl.___Tests = {}
        Testing._Testables[tbl] = true
    end
end

---Returns whether a table has tests registered.
---@param tbl TestingLib.TestMixin
---@return boolean
function Testing._HasTests(tbl)
    return tbl.___Tests and next(tbl.___Tests) ~= nil
end
