
local CustomStats = Epip.GetFeature("Feature_CustomStats")

---@type table<string, Feature_CustomStats_Stat>
local Stats = {
    -- CURRENT COMBAT
    CurrentCombat_DamageDealt = {
        Name = "Damage Dealt",
        Description = "Damage dealt in the current combat, or the latest combat this character participated in.",
    },
    CurrentCombat_DamageReceived = {
        Name = "Damage Received",
        Description = "Damage received in the current combat, or the latest combat this character participated in.",
    },
    CurrentCombat_HealingDone = {
        Name = "Healing Done",
        Description = "Healing and armor restoration done in the current combat, or the latest combat this character participated in.",
    },

    -- Vitals
    LifeSteal = {
        Name = "Lifesteal",
        Description = "Causes a percentage of the damage that you deal to Vitality to be restored to your own.",
        Suffix = "%",
    },

    -- MISC
    PartyFunds_Gold = {
        Name = "Party Gold",
        Description = "The gold currently in the party's possession.",
    },
}

for id,stat in pairs(Stats) do
    stat.DefaultValue = 0
    CustomStats.RegisterStat(id, stat)
end