
---@class Features.EpicEncountersStatsTabKeywords : Feature
local Stats = {
    TOOLTIPS = {
        ["Stats"] = {
            ["Regen_Life_Calculated"] = "Restores a percentage of your missing Vitality at the start of your turn.",
            ["Regen_PhysicalArmor_Calculated"] = "Restores a percentage of your missing Physical Armor at the start of your turn.",
            ["Regen_MagicArmor_Calculated"] = "Restores a percentage of your missing Magic Armor at the start of your turn.",
        },
        ["Reactions"] = {
            ["FreeGenericReaction"] = "Enables you to perform any reaction for 0 AP.<br><br>Generic Reaction Charges are only used when dedicated ones are depleted.",
            ["FreeReactionExplanation"] = "Each charge enables you to perform %s reactions for 0 AP.",
            ["FreeGenericReactionExplanation"] = "If your dedicated %s reaction charges are expended, Generic Reaction Charges are used instead, if available.",
            ["FreeReactionsRecharge"] = "You enter combat with all your Free Reaction Charges replenished, and regain them upon the start of your first turn in subsequent rounds.",
        },
        ["Regeneration"] = {
            ["CapWarning"] = "Missing Regeneration is capped at 50%.",
        },

        ["KeywordSource"] = "Source: %s",
        ["AspectNode"] = "%s (Node %s.%s)",

        ["KeywordActivatorHeader"] = '<p align="center"><font color="ebc808" size="22" face="Averia Serif">— %s Activator —</font></p>',
        ["KeywordMutatorHeader"] = '<p align="center"><font color="ebc808" size="22" face="Averia Serif">— %s Mutator —</font></p>',
    },

    KEYWORD_ID_TO_NAME = {
        ["ViolentStrike"] = "Violent Strikes",
        ["VitalityVoid"] = "Vitality Void",
    },

    COLORS = {
        GREYED_OUT = "32302d",
    },
    NODE_INDICES_PATTERN = "(%d+)%.(%d+)$", -- Extracts indices from a "Node_X.Y" string. Though in base EE these indices never go beyond ~5, there is no technical limit to the amount of nodes and subnodes in aspects.
}
Epip.RegisterFeature("Features.EpicEncountersStatsTabKeywords", Stats)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether a stat entry is a category.
---@param stat any
---@return boolean
function Stats.StatIsCategory(stat)
    return Stats.KEYWORD_CATEGORIES[stat] ~= nil
end

---Returns the default value of a stat.
---@param statData any
---@return integer
function Stats.GetDefaultStatValue(statData)
    return statData.DefaultValue and statData.DefaultValue or 0
end

---Returns a string with the source of a stat's keyword power.
---@param statData any
---@return string
function Stats.GetKeywordSourceString(statData)
    local aspectText = string.format(Stats.TOOLTIPS.AspectNode, statData.SourceAspect, statData.NodeIndex + 1, statData.SubNodeIndex + 1)
    return string.format(Stats.TOOLTIPS.KeywordSource, aspectText)
end

---Returns all EE stats.
---@return table
function Stats.GetAllEpicStats()
    local t = {}
    for _,statTable in pairs(Stats.STATS) do
        for stat,data in pairs(statTable) do
            t[stat] = data
        end
    end
    return t
end


