
local Tooltip = Client.Tooltip

---@type Feature
local StatAdjustments = {
    LABEL_REFERENCE_POTION_STAT = "Stats_AMER_FLEXSTAT_DamageBoost_1", -- The stat to check the name of to retrieve the "From Stat Adjustment" label. Eases localization. This label is assumed to be the same across all Stat Adjustment statuses.
    BOOST_PATTERN = "(%+?-?%d*%.?%d*)%%*",
}
Epip.RegisterFeature("Features.TooltipAdjustments.StatAdjustmentMerging", StatAdjustments)

---------------------------------------------
-- METHODS
---------------------------------------------

---Merges stat adjustments into 1 line.
---@param tooltip TooltipLib_FormattedTooltip
function StatAdjustments.MergeStatAdjustments(tooltip)
    local count = 0
    local needsPercentageSign = false
    local leftLabel = nil
    local STAT_ADJUSTMENT_PATTERN = string.format("(.*%s:) %s", Text.GetTranslatedString(StatAdjustments.LABEL_REFERENCE_POTION_STAT, "Stat Adjustment"), StatAdjustments.BOOST_PATTERN) -- Cannot be initialized at root of the script due to TSK jank.

    -- Count all stat adjustment status displays, and remove them
    for i=#tooltip.Elements,1,-1 do
        local v = tooltip.Elements[i]
        if (v.Type == "StatsPercentageBoost" or v.Type == "StatsTalentsBoost" or v.Type == "StatsPercentageMalus" or v.Type == "StatsTalentsMalus") then
            local label, amount = v.Label:match(STAT_ADJUSTMENT_PATTERN)
            if label then
                leftLabel = label
                count = count + amount

                if v.Type == "StatsPercentageBoost" or v.Type == "StatsPercentageMalus" then
                    needsPercentageSign = true
                end

                table.remove(tooltip.Elements, i)
            end
        end
    end

    -- Insert new tooltip element with the total value
    if count ~= 0 then
        local prefix = count < 0 and "" or "+" -- For negative values, the "-" already comes from stringifying the value.

        local baseString = needsPercentageSign and leftLabel .. " {PREFIX}%s%%" or leftLabel .. " {PREFIX}%s"
        baseString = baseString:gsub("{PREFIX}", prefix)

        local type = "StatsPercentageBoost"
        if count < 0 then
            type = "StatsTalentsMalus"
        end

        table.insert(tooltip.Elements, {Type = type, Label = string.format(baseString, Text.RemoveTrailingZeros(count))})
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Tooltip.Hooks.RenderFormattedTooltip:Subscribe(function (ev)
    StatAdjustments.MergeStatAdjustments(ev.Tooltip)
end)
