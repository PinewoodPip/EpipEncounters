
---------------------------------------------
-- Fixes skill tooltips for cone skills saying that their range
-- is affected by Astrologer's Gaze (it is not!)
---------------------------------------------

local TooltipAdjustments = Epip.GetFeature("Feature_TooltipAdjustments")
local Tooltip = Client.Tooltip

local AstrologerFix = {
    ---@type table<string, true> Skill archetypes affected by the bug.
    AFFECTED_ARCHETYPES = {
        Cone = true,
        Zone = true,
    },
    RANGE_BONUS = 200, -- Range bonus from the talent, in centimeters.
}
Epip.RegisterFeature("TooltipAdjustments_AstrologerFix", AstrologerFix)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char EclCharacter
---@param skillData StatsLib_StatsObject_SkillData
---@return boolean
function AstrologerFix.IsAffected(char, skillData)
    local skillType = skillData.SkillType

    return char.Stats.TALENT_FaroutDude and AstrologerFix.AFFECTED_ARCHETYPES[skillType] == true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for skill tooltips to check if they're affected.
Tooltip.Hooks.RenderSkillTooltip:Subscribe(function (ev)
    local skill = Stats.Get("SkillData", ev.SkillID)
    local char = Client.GetCharacter()

    if TooltipAdjustments.IsAdjustmentEnabled(TooltipAdjustments.Settings.AstrologerFix) and skill and AstrologerFix.IsAffected(char, skill) and AstrologerFix:IsEnabled() then
        local element = ev.Tooltip:GetFirstElement("SkillRange")
        local range = element.Value:match("(%d+%.?%d*)m$")

        if range then
            local newRange = tonumber(range) - AstrologerFix.RANGE_BONUS/100

            AstrologerFix:DebugLog("Found bugged tooltip. Old and new range:", range, newRange)

            element.Value = string.format("%sm", Text.RemoveTrailingZeros(newRange))
        end
    end
end)