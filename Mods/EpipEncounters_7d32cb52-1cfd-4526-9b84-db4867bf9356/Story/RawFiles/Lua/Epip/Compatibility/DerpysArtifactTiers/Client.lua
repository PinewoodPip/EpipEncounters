
---------------------------------------------
-- Adds an artifact tier filter to the Artifacts Codex. 
---------------------------------------------

local Codex = Epip.GetFeature("Feature_Codex")
local ArtifactsCodex = Epip.GetFeature("Features.Codex.Artifacts")
local ArtifactsSection = Codex.GetSection("Artifacts")
local CommonStrings = Text.CommonStrings

---@type Feature
local ArtifactTiers = {
    TIER_1_MAX_LEVEL = 15,
    TIER_2_MIN_LEVEL = 10,
    TIER_3_MIN_LEVEL = 16,

    Settings = {},
    TranslatedStrings = {
        Setting_CodexArtifactTierFilter_Name = {
           Handle = "h97f62f62gcd0fg4addg9db9g5504788bcb50",
           Text = "Tier",
           ContextDescription = "Setting name for Derpy' Artifact Tiers support within the Codex",
        },
    },

    REQUIRED_MODS = {
        [Mod.GUIDS.EE_DERPY_ARTIFACT_TIERS] = "Derpy's Artifact Tiers",
    },
}
Epip.RegisterFeature("Compatibility_DerpysArtifactTiers", ArtifactTiers)

---------------------------------------------
-- SETTINGS
---------------------------------------------

ArtifactTiers.Settings.CodexArtifactTierFilter = ArtifactTiers:RegisterSetting("CodexArtifactTierFilter", {
    Type = "Choice",
    NameHandle = ArtifactTiers.TranslatedStrings.Setting_CodexArtifactTierFilter_Name,
    DefaultValue = "Any",
    ---@type SettingsLib_Setting_Choice_Entry[]
    Choices = {
        {ID = "Any", NameHandle = CommonStrings.Any.Handle},
        {ID = "Tier1", Name = string.format(CommonStrings.LevelRange:GetString(), 1, ArtifactTiers.TIER_1_MAX_LEVEL)},
        {ID = "Tier2", Name = string.format(CommonStrings.LevelFloor:GetString(), ArtifactTiers.TIER_2_MIN_LEVEL)},
        {ID = "Tier3", Name = string.format(CommonStrings.LevelFloor:GetString(), ArtifactTiers.TIER_3_MIN_LEVEL)},
    },
})

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Filter artifacts based on tier.
ArtifactsCodex.Hooks.IsArtifactValid:Subscribe(function (ev)
    if ev.Valid then
        local filter = ArtifactTiers:GetSettingValue(ArtifactTiers.Settings.CodexArtifactTierFilter)
        if filter ~= "Any" then
            local template = Ext.Template.GetRootTemplate(Text.RemoveGUIDPrefix(ev.Artifact.ItemTemplate)) ---@cast template ItemTemplate
            local stat = Stats.Get("StatsLib_StatsEntry_Weapon", template.Stats) or Stats.Get("StatsLib_StatsEntry_Shield", template.Stats) or Stats.Get("StatsLib_StatsEntry_Armor", template.Stats)
            local tier = "Tier1"

            if stat.MinLevel == ArtifactTiers.TIER_2_MIN_LEVEL then
                tier = "Tier2"
            elseif stat.MinLevel == ArtifactTiers.TIER_3_MIN_LEVEL then
                tier = "Tier3"
            end

            ev.Valid = filter == tier
        end
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Add tier filter setting to the section
if ArtifactTiers:IsEnabled() then
    table.insert(ArtifactsSection.Settings, ArtifactTiers.Settings.CodexArtifactTierFilter)
end