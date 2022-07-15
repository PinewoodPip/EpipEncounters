
local PlayerInfo = Client.UI.PlayerInfo

---@class StatusSortingFeature : Feature
local StatusSorting = {
    FILTERED_STATUSES = {

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

-- Filter Source Gen.
StatusSorting.Events.ShouldFilterStatus:Subscribe(function (e)
    local isSourceGen = e.Status.StatusId:match("^AMER_SOURCEGEN_DISPLAY_%d+$")

    if isSourceGen then
        e.Filter = true
    end
end)