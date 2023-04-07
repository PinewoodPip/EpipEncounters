
local CustomStats = Epip.GetFeature("Feature_CustomStats")

-- Add artifact entries
for id,artifact in pairs(Artifact.ARTIFACTS) do
    ---@type Feature_CustomStats_Stat
    local stat = {
        ID = id,
        Name = artifact:GetName(),
        Description = artifact:GetDescription(),
        Boolean = true,
        Tooltip = artifact:GetPowerTooltip(),
        DefaultValue = false,
    }

    CustomStats.RegisterStat(id, stat)
    CustomStats.AddStatToCategory(id, "Artifacts")
end
table.simpleSort(CustomStats.CATEGORIES.Artifacts.Stats)