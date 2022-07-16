
local PlayerInfo = Client.UI.PlayerInfo
local OptionsSettings = Client.UI.OptionsSettings

---@class StatusSortingFeature : Feature
local StatusSorting = {
    FILTERED_STATUSES = {

    },
    STATUS_PATTERNS = {
        ["PlayerInfo_Filter_SourceGen"] = {Text.PATTERNS.STATUSES.SOURCE_GENERATION},
        ["PlayerInfo_Filter_BatteredHarried"] = {Text.PATTERNS.STATUSES.BATTERED, Text.PATTERNS.STATUSES.HARRIED},
    },
    STATUS_ORDER = {
        "LEADERSHIP",
        {Pattern = Text.PATTERNS.STATUSES.SOURCE_GENERATION},

        -- B/H
        {Pattern = Text.PATTERNS.STATUSES.BATTERED},
        {Pattern = Text.PATTERNS.STATUSES.HARRIED},

        -- Battered Statuses
        {Pattern = "AMER_ATAXIA_%d"},
        {Pattern = "AMER_ENTHRALLED_%d"},
        {Pattern = "AMER_DECAYING_%d"},
        {Pattern = "AMER_WEAKENED_%d"},

        -- Harried Statuses
        {Pattern = "AMER_SLOWED_%d"},
        {Pattern = "AMER_TERRIFIED_%d"},
        {Pattern = "AMER_SQUELCHED_%d"},
        {Pattern = "AMER_BLIND_%d"},

    },
    SUB_SETTINGS = {
        ["PlayerInfo_Filter_SourceGen"] = "Checkbox",
        ["PlayerInfo_Filter_BatteredHarried"] = "Checkbox",
        ["PlayerInfo_SortingFunction"] = "Dropdown",
    },
    USE_LEGACY_EVENTS = false,
    Events = {
        ---@type SubscribableEvent<StatusSortingFeature_Event_ShouldFilterStatus>
        ShouldFilterStatus = {},
    },
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

            StatusSorting:DebugLog("Sorting:", statusData.Status.StatusId)

            if event.Filter then
                table.remove(list, i)
                StatusSorting:DebugLog("Removing: ", statusData.Status.StatusId)
            else -- Assign sorting index
                local index = nil

                for sortingIndex,status in ipairs(StatusSorting.STATUS_ORDER) do
                    local isStatus = false

                    if type(status) == "table" then
                        isStatus = statusData.Status.StatusId:match(status.Pattern) ~= nil
                    else
                        isStatus = status == statusData.Status.StatusId
                    end

                    if isStatus then
                        index = sortingIndex
                        break
                    end
                end

                if index then
                    StatusSorting:DebugLog("Setting " .. statusData.Status.StatusId .. " to " .. index)
                    statusData.SortingIndex = #StatusSorting.STATUS_ORDER - index
                else
                    StatusSorting:DebugLog("Ignoring: ", statusData.Status.StatusId)
                end
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

local function UpdateOptionAvailability(sortingEnabled)
    if sortingEnabled == nil then sortingEnabled = OptionsSettings.GetOptionValue("EpipEncounters", "PlayerInfo_EnableSortingFiltering") end

    for id,elementType in pairs(StatusSorting.SUB_SETTINGS) do
        if not sortingEnabled and elementType == "Checkbox" then -- Reset checkboxes
            OptionsSettings.SetOptionValue("EpipEncounters", id, OptionsSettings.GetOptionData(id).DefaultValue)
        end

        OptionsSettings.SetElementEnabled(id, sortingEnabled, elementType)
    end
end

OptionsSettings:RegisterListener("CheckboxClicked", function(element, active)
    if element and element.ID == "PlayerInfo_EnableSortingFiltering" then
        UpdateOptionAvailability(active)
    end
end)

-- Enable/disable the sorting settings depending on whether sorting itself is enabled.
OptionsSettings.Events.TabRendered:RegisterListener(function (customTab, _)
    if customTab and customTab.Mod == "EpipEncounters" then
        UpdateOptionAvailability()
    end
end)