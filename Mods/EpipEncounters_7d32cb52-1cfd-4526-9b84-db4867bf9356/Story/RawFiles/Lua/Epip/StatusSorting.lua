
local PlayerInfo = Client.UI.PlayerInfo
local OptionsSettings = Client.UI.OptionsSettings

---@class StatusSortingFeature : Feature
local StatusSorting = {
    FILTERED_STATUSES = {

    },
    STATUS_PATTERNS = {
        ["PlayerInfo_Filter_SourceGen"] = {"^AMER_SOURCEGEN_DISPLAY_%d+$"},
        ["PlayerInfo_Filter_BatteredHarried"] = {Text.PATTERNS.STATUSES.BATTERED, Text.PATTERNS.STATUSES.HARRIED},
    },
    USE_LEGACY_EVENTS = false,
    Events = {
        ---@type SubscribableEvent<StatusSortingFeature_Event_ShouldFilterStatus>
        ShouldFilterStatus = {},
    }
}
Epip.AddFeature("StatusSorting", "StatusSorting", StatusSorting)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class StatusSortingFeature_Event_ShouldFilterStatus
---@field Status EclStatus
---@field Filter boolean Defaults to false.

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

PlayerInfo.Events.StatusesUpdated:Subscribe(function (e)
    for _,list in pairs(e.Data) do
        for i,statusData in ipairs(list) do
            local event = {
                Status = statusData.Status,
                Filter = false,
            }
            StatusSorting.Events.ShouldFilterStatus:Throw(event)

            if event.Filter then
                table.remove(list, i)
            end
        end
    end
end)

-- Filter statuses based on patterns.
StatusSorting.Events.ShouldFilterStatus:Subscribe(function (e)
    for setting,patternList in pairs(StatusSorting.STATUS_PATTERNS) do
        if OptionsSettings.GetOptionValue("EpipEncounters", setting) == false then
            for _,pattern in ipairs(patternList) do
                local shouldFilter = e.Status.StatusId:match(pattern)

                if shouldFilter then
                    e.Filter = true
                    return nil
                end
            end
        end
    end
end)