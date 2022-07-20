
local PlayerInfo = Client.UI.PlayerInfo
local ContextMenu = Client.UI.ContextMenu
local OptionsSettings = Client.UI.OptionsSettings

---@class StatusSortingFeature : Feature
local StatusSorting = {
    currentHoveredStatus = nil,

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
-- METHODS
---------------------------------------------

---@param statusID string
---@param filtered boolean
function StatusSorting.SetStatusFilter(statusID, filtered)
    if filtered then
        StatusSorting.FILTERED_STATUSES[statusID] = true
    else
        StatusSorting.FILTERED_STATUSES[statusID] = nil
    end
end

---Returns whether a status has been chosen to be manually filtered by the user.
---@param statusID string
---@return boolean
function StatusSorting.IsFiltered(statusID)
    return StatusSorting.FILTERED_STATUSES[statusID]
end

-- TODO rework
function StatusSorting.GetContextMenuOption()
    local option1, option2

    if StatusSorting.currentHoveredStatus then
        option1 = {id = "StatusSorting_FilterStatus", type = "checkbox", checked = StatusSorting.IsFiltered(StatusSorting.currentHoveredStatus), text = "Hide Status"}

    end

    if not table.isEmpty(StatusSorting.FILTERED_STATUSES) then
        option2 = {id = "StatusSorting_SubMenu", type = "subMenu", text = "", subMenu = "StatusSorting_FilteredStatuses"}
    end
    

    return option1, option2
end

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class StatusSortingFeature_Event_ShouldFilterStatus
---@field Status EclStatus
---@field Filter boolean Defaults to false.

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.ContextMenu.RegisterMenuHandler("playerInfoStatus", function(char, statusFlashHandle)
    local status = Ext.GetStatus(char.NetID, Ext.UI.DoubleToHandle(statusFlashHandle))
    if not status or not OptionsSettings.GetOptionValue("EpipEncounters", "PlayerInfo_EnableSortingFiltering") or true then return nil end -- TODO finish

    StatusSorting.currentHoveredStatus = status.StatusId

    Client.UI.ContextMenu.Setup({
        menu = {
            id = "main",
            entries = {
                {id = "playerInfo_Header", type = "header", text = Text.Format("— %s —", {FormatArgs = {status.StatusId}})},

                StatusSorting.GetContextMenuOption()
            }
        }
    })

    Client.UI.ContextMenu.Open()
end)

ContextMenu.RegisterElementListener("StatusSorting_FilterStatus", "buttonPressed", function(_, _)
    local statusID = StatusSorting.currentHoveredStatus
    local filtered = StatusSorting.IsFiltered(statusID)

    StatusSorting.SetStatusFilter(statusID, not filtered)
end)

PlayerInfo.Events.StatusesUpdated:Subscribe(function (e)
    for _,list in pairs(e.Data) do
        for i,statusData in ipairs(list) do
            if statusData.Status then
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
                        statusData.SortingIndex = #StatusSorting.STATUS_ORDER - index - (i * 0.01)
                    else
                        StatusSorting:DebugLog("Ignoring: ", statusData.Status.StatusId)
                    end
                end
            end
        end
    end
end)

-- Filter statuses based on user settings.
StatusSorting.Events.ShouldFilterStatus:Subscribe(function (e)
    if StatusSorting.IsFiltered(e.Status.StatusId) then
        e.Filter = true
        -- e:StopPropagation()
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
                    -- e:StopPropagation()
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
    if customTab and customTab.Mod == "EpipEncounters" and Ext.Debug.IsDeveloperMode() then
        UpdateOptionAvailability()
    end
end)

-- Show status filter menu.
ContextMenu.RegisterMenuHandler("epip_Cheats_Stats_FlexStats_Immunities", function()
    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_Cheats_Stats_FlexStats_Immunities",
            entries = FLEXSTAT_CHEATS.Immunity
        }
    })
end)