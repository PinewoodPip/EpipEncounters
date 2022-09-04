
local WorldTooltip = Client.UI.WorldTooltip

local Filtering = {
    SETTINGS = {
        EMPTY_BODIES = "WorldTooltip_EmptyContainers"
    }
}
Epip.RegisterFeature("WorldTooltipFiltering", Filtering)

---------------------------------------------
-- METHODS
---------------------------------------------

function Filtering._IsSettingEnabled(setting)
    return Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", setting)
end

---@param entry WorldTooltipUI_Entry
---@return boolean
function Filtering.ShouldFilter(entry)
    local shouldFilter = false

    -- Filter out empty bodies/containers
    if not Filtering._IsSettingEnabled(Filtering.SETTINGS.EMPTY_BODIES) then
        if entry.Label:match("%(empty%)") then
            shouldFilter = true
        end
    end

    return shouldFilter
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

WorldTooltip.Hooks.UpdateContent:Subscribe(function (ev)
    local i = 1
    while i <= #ev.Entries do
        local entry = ev.Entries[i]

        if Filtering.ShouldFilter(entry) then
            table.remove(ev.Entries, i)
        else
            i = i + 1
        end
    end
end)