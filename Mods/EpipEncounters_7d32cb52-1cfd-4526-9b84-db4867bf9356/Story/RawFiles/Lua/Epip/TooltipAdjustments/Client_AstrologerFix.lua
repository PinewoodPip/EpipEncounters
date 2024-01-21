
---------------------------------------------
-- Fixes skill tooltips for cone skills saying that their range
-- is affected by Astrologer's Gaze (it is not!)
---------------------------------------------

local Tooltip = Client.Tooltip

---@type Feature
local AstrologerFix = {
    ---@type table<string, true> Skill archetypes affected by the bug.
    AFFECTED_ARCHETYPES = {
        Cone = true,
        Zone = true,
    },
    RANGE_BONUS = 200, -- Range bonus from the talent, in centimeters.

    Settings = {},
    TranslatedStrings = {
        Setting_Enabled_Name = {
            Handle = "h6dcae9c5gcbfcg4f06g9329gac12ad711d18",
            Text = "Fix %s range",
            ContextDescription = [[Setting name; param is name of the Far Out Dude talent (Astrologer's Gaze in EE)]],
            FormatOptions = {
                FormatArgs = {Character.Talents.FaroutDude:GetName()},
            },
        },
        Setting_Enabled_Description = {
            Handle = "hba6d14b0gdbb9g4b00g8036ga14b329a1960",
            Text = "If enabled, zone and cone-type skills will display the correct range if the character has %s.",
            ContextDescription = [[Setting tooltip; param is name of the Far Out Dude talent (Astrologer's Gaze in EE)]],
            FormatOptions = {
                FormatArgs = {Character.Talents.FaroutDude:GetName()},
            },
        },
    }
}
Epip.RegisterFeature("TooltipAdjustments.AstrologerFix", AstrologerFix)
local TSK = AstrologerFix.TranslatedStrings

---------------------------------------------
-- SETTINGS
---------------------------------------------

AstrologerFix.Settings.Enabled = AstrologerFix:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = TSK.Setting_Enabled_Name,
    Description = TSK.Setting_Enabled_Description,
    DefaultValue = true,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function AstrologerFix:IsEnabled()
    return self:GetSettingValue(AstrologerFix.Settings.Enabled) == true and _Feature.IsEnabled(self)
end

---Returns whether a character and skill are affected by the bug.
---@param char EclCharacter
---@param skillData StatsLib_StatsEntry_SkillData
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
    local skill = Stats.Get("StatsLib_StatsEntry_SkillData", ev.SkillID)
    local char = Client.GetCharacter()

    if AstrologerFix:IsEnabled() and skill and AstrologerFix.IsAffected(char, skill) and AstrologerFix:IsEnabled() then
        local element = ev.Tooltip:GetFirstElement("SkillRange")
        local range = element.Value:match("(%d+%.?%d*)m$") -- TODO make usable in other languages

        if range then
            local newRange = tonumber(range) - AstrologerFix.RANGE_BONUS/100

            AstrologerFix:DebugLog("Found bugged tooltip. Old and new range:", range, newRange)

            element.Value = string.format("%sm", Text.RemoveTrailingZeros(newRange))
        end
    end
end)