
---@meta Library: TimeUI, ContextClient

---@class TimeUI : UI
---@field DATE_PATTERN string
---@field FLASH_MONTHS table<string, integer>
---@field FLASH_WEEKDAYS table<string, integer>
local Time = {
    ID = "PIP_Time",
    PATH = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/time.swf",
    DATE_PATTERN = "(...) (...) (%d%d?) (%d%d):(%d%d):(%d%d) ?.* ?(%d%d%d%d)",
    FLASH_MONTHS = {
        ["Jan"] = 1,
        ["Feb"] = 2,
        ["Mar"] = 3,
        ["Apr"] = 4,
        ["May"] = 5,
        ["Jun"] = 6,
        ["Jul"] = 7,
        ["Aug"] = 8,
        ["Sep"] = 9,
        ["Oct"] = 10,
        ["Nov"] = 11,
        ["Dec"] = 12,
    },
    FLASH_WEEKDAYS = {
        ["Mon"] = 1,
        ["Tue"] = 2,
        ["Wed"] = 3,
        ["Thu"] = 4,
        ["Fri"] = 5,
        ["Sat"] = 6,
        ["Sun"] = 7,
    },
}
if IS_IMPROVED_HOTBAR then
    Time.PATH = "Public/ImprovedHotbar_53cdc613-9d32-4b1d-adaa-fd97c4cef22c/GUI/time.swf"
end
Epip.InitializeUI(nil, "Time", Time)

---@class DateTime
---@field WeekDay integer
---@field Month integer
---@field Day integer
---@field Hour integer
---@field Minute integer
---@field Second integer
---@field Year integer

---Returns an object holding data about the current date and time.
---Accounts for daylight savings.
---@param utc? boolean Whether to use UTC time. Defaults to false.
---@return DateTime
function Time.GetDate(utc)
    local str = Time.GetDateString(utc)
    local weekDay,month,day,hour,minute,second,year = str:match(Time.DATE_PATTERN)
    local date = {
        WeekDay = Time.FLASH_WEEKDAYS[weekDay],
        Month = Time.FLASH_MONTHS[month],
        Day = tonumber(day),
        Hour = tonumber(hour),
        Minute = tonumber(minute),
        Second = tonumber(second),
        Year = tonumber(year),
    }

    if Time.IsDaylightSavings(date) then
        -- Oh boy
        date.Hour = date.Hour + 1

        if date.Hour >= 24 then
            date.Hour = 0
            date.Day = date.Day + 1
            -- OH MY GOD WHY ARE DATES SO COMPLICATED. TODO FINISH THIS
        end
    end

    return date
end

---Returns the milliseconds since midnight January 1, 1970, universal time
---@return number Milliseconds.
function Time.GetTime()
    return Time:GetRoot().getTime()
end

---Returns whether daylight savings is currently ongoing,
---which adds +1 hour to GetDate()
---@param date DateTime
function Time.IsDaylightSavings(date)
    local daylightSavings = false

    if date.Month == 3 then
        daylightSavings = date.Day >= 27
    elseif date.Month > 3 and date.Month < 10 then
        daylightSavings = true
    elseif date.Month == 10 then
        daylightSavings = date.Day < 30
    end

    return daylightSavings
end

---Returns a string representing the current time and date.
---@param utc? boolean Whether to use UTC time. Defaults to false.
---@return string
function Time.GetDateString(utc)
    local root = Time:GetRoot()
    local date = nil

    if utc then
        date = root.getUTCDate()
    else
        date = root.getDate()
    end

    return date
end

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.UI.Create(Time.ID, Time.PATH, 100)
Time:SetFlag(Client.UI._BaseUITable.UI_FLAGS.PLAYER_INPUT_1, false)