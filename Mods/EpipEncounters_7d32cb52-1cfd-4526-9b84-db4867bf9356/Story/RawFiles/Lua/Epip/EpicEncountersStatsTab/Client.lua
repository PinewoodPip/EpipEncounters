
---@class Features.EpicEncountersStatsTabKeywords
local Stats = Epip.GetFeature("Features.EpicEncountersStatsTabKeywords")

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the tooltip for a keyword.
---@param statData any
---@return string
function Stats.GetKeywordTooltip(statData)
    local header = ""
    if statData.Type == "Activator" then
        header = Stats.TOOLTIPS.KeywordActivatorHeader
    else
        header = Stats.TOOLTIPS.KeywordMutatorHeader
    end

    -- Replace keyword ID with user-friendly name
    local keywordName = statData.Keyword
    if Stats.KEYWORD_ID_TO_NAME[keywordName] ~= nil then
        keywordName = Stats.KEYWORD_ID_TO_NAME[keywordName]
    end

    header = string.format(header, keywordName)
    return header .. "" .. statData.Description
end
