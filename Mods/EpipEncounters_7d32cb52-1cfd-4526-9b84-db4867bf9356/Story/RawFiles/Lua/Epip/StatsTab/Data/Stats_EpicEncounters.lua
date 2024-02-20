
local CustomStats = Epip.GetFeature("Feature_CustomStats")

---@type table<string, Feature_CustomStats_Stat>
local EpicEncountersStats = {
    -- Vitals
    RegenLifeCalculated = {
        Name = "Missing Life Regen",
        Description = "Restores a percentage of your missing Vitality at the start of your turn.",

        Footnote = "Missing Regeneration is capped at 50%.",
        Suffix = "%",
    },
    RegenPhysicalArmorCalculated = {
        Name = "Missing Phys. Armor Regen",
        Description = "Restores a percentage of your missing Physical Armor at the start of your turn.",
        Footnote = "Missing Regeneration is capped at 50%.",
        Suffix = "%",
    },
    RegenMagicArmorCalculated = {
        Name = "Missing Magic Armor Regen",
        Description = "Restores a percentage of your missing Magic Armor at the start of your turn.",
        Footnote = "Missing Regeneration is capped at 50%.",
        Suffix = "%",
    },

    -- Misc
    PartyFunds_Splinters = {
        Name = "Party Splinters",
        Description = "The Artificer's Splinters currently in the party's possession.",
    },

    -- EMBODIMENTS
    Embodiment_Force = {
        Name = "Force",
        Description = "Force embodied through your Ascensions.",
        IgnoreForHiding = true,
    },
    Embodiment_Entropy = {
        Name = "Entropy",
        Description = "Entropy embodied through your Ascensions.",
        IgnoreForHiding = true,
    },
    Embodiment_Form = {
        Name = "Form",
        Description = "Form embodied through your Ascensions.",
        IgnoreForHiding = true,
    },
    Embodiment_Inertia = {
        Name = "Inertia",
        Description = "Inertia embodied through your Ascensions.",
        IgnoreForHiding = true,
    },
    Embodiment_Life = {
        Name = "Life",
        Description = "Life embodied through your Ascensions.",
        IgnoreForHiding = true,
    },

    -- KEYWORDS
    Keyword_Celestial_Healing = {
        Name = "Vitality Restoration",
        Description = "The vitality restored by your Celestial reactions.",
        Suffix = "%",
        IgnoreForHiding = true,
    },
    Keyword_VitalityVoid_Power = {
        Name = "Power",
        Description = "The damage your Vitality Void deals, as a percentage of your maximum health.",
        Suffix = "%",
        IgnoreForHiding = true,
    },
    Keyword_VitalityVoid_Radius = {
        Name = "Radius",
        Description = "The radius of your Vitality Void activations.",
        Suffix = "m",
        IgnoreForHiding = true,
    },
    Keyword_Prosperity_Threshold = {
        Name = "Threshold",
        Description = "The vitality threshold of your basic Prosperity activator.",
        Suffix = "%",
        IgnoreForHiding = true,
    },

    -- Voracity
    Keyword_Voracity_Life = {
        Name = "Vitality Restoration",
        Description = "Vitality restored upon activating Voracity.",
        Suffix = "%",
    },
    Keyword_Voracity_PhysArmor = {
        Name = "Phys. Armor Restoration",
        Description = "Physical Armor restored upon activating Voracity.",
        Suffix = "%",
    },
    Keyword_Voracity_MagicArmor = {
        Name = "Magic Armor Restoration",
        Description = "Magic Armor restored upon activating Voracity.",
        Suffix = "%",
    },
    Keyword_Voracity_Summon_Life = {
        Name = "Summon Life Restoration",
        Description = "Summon vitality restored upon activating Voracity.",
        Suffix = "%",
    },
    Keyword_Voracity_Summon_PhysArmor = {
        Name = "Summon Phys. Armor Restoration",
        Description = "Summon Physical Armor restored upon activating Voracity.",
        Suffix = "%",
    },
    Keyword_Voracity_Summon_MagicArmor = {
        Name = "Summon Magic Armor Restoration",
        Description = "Summon Magic Armor restored upon activating Voracity.",
        Suffix = "%",
    },

    -- REACTIONS
    FreeReaction_Generic = {
        Name = "Generic Charges",
        Description = "Enables you to perform any reaction for 0 AP.<br><br>Generic Reaction Charges are only used when dedicated ones are depleted.",
        Footnote = "You enter combat with all your Free Reaction Charges replenished, and regain them upon the start of your first turn in subsequent rounds.",
        MaxCharges = "FreeReaction_Generic_Max",
    },
    FreeReaction_Generic_Max = {},
    FreeReaction_Predator = {
        Name = "Predator Charges",
        Description = "Enables you to perform Predator Reactions for 0 AP.",
        Footnote = "You enter combat with all your Free Reaction Charges replenished, and regain them upon the start of your first turn in subsequent rounds.",
        MaxCharges = "FreeReaction_Predator_Max",
    },
    FreeReaction_Predator_Max = {},
    FreeReaction_Celestial = {
        Name = "Celestial Charges",
        Description = "Enables you to perform Celestial Reactions for 0 AP.",
        Footnote = "You enter combat with all your Free Reaction Charges replenished, and regain them upon the start of your first turn in subsequent rounds.",
        MaxCharges = "FreeReaction_Celestial_Max",
    },
    FreeReaction_Celestial_Max = {},
    FreeReaction_Centurion = {
        Name = "Centurion Charges",
        Description = "Enables you to perform Centurion Reactions for 0 AP.",
        Footnote = "You enter combat with all your Free Reaction Charges replenished, and regain them upon the start of your first turn in subsequent rounds.",
        MaxCharges = "FreeReaction_Centurion_Max",
    },
    FreeReaction_Centurion_Max = {},
    FreeReaction_Elementalist = {
        Name = "Elementalist Charges",
        Description = "Enables you to perform Elementalist Reactions for 0 AP.",
        Footnote = "You enter combat with all your Free Reaction Charges replenished, and regain them upon the start of your first turn in subsequent rounds.",
        MaxCharges = "FreeReaction_Elementalist_Max",
    },
    FreeReaction_Elementalist_Max = {},
    FreeReaction_Occultist = {
        Name = "Occultist Charges",
        Description = "Enables you to perform Occultist Reactions for 0 AP.",
        Footnote = "You enter combat with all your Free Reaction Charges replenished, and regain them upon the start of your first turn in subsequent rounds.",
        MaxCharges = "FreeReaction_Occultist_Max",
    },
    FreeReaction_Occultist_Max = {},
}

-- Add EE regen stats to the Vitals category.
local vitalsCategory = CustomStats.GetCategory("Vitals")
local newStats = {
    "RegenLifeCalculated",
    "RegenPhysicalArmorCalculated",
    "RegenMagicArmorCalculated",
}
for i=#newStats,1,-1 do -- Insert stats in order provided.
    local id = newStats[i]
    table.insert(vitalsCategory.Stats, 1, id)
end

for id,stat in pairs(EpicEncountersStats) do
    stat.DefaultValue = 0
    CustomStats.RegisterStat(id, stat)
end

-- Create Ascension stats from old data
Data.Game.ASPECT_NAMES = {}
-- TODO cache
for _,data in pairs(epicStatsKeywords) do
    if not Data.Game.ASPECT_NAMES[data.ClusterId] then
        Data.Game.ASPECT_NAMES[data.ClusterId] = data.SourceAspect
    end
end
for _,data in pairs(epicStatsKeywords) do
    CustomStats.AddNodeStat(data.ClusterId, data.NodeIndex, data.SubNodeIndex, data.Keyword, data.Type, {
        Name = data.Display,
        Description = data.Description,
    })
end
