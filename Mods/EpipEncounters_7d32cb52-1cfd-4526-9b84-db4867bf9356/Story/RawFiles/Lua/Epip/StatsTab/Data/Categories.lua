
local CustomStats = Epip.GetFeature("Feature_CustomStats")

local Categories = {
    Embodiments = {
        Header = Text.Format("——— Embodiments ———", {Size = 21}),
        Name = "Embodiments",
        Stats = {
            "Embodiment_Force",
            "Embodiment_Entropy",
            "Embodiment_Form",
            "Embodiment_Inertia",
            "Embodiment_Life",
        },
    },
    Vitals = {
        Header = "<font size='21'>————— Vitals —————</font>",
        Name = "Vitals", -- Name in tooltip.
        Behaviour = "GreyOut",
        Stats = {
            "RegenLifeCalculated",
            "RegenPhysicalArmorCalculated",
            "RegenMagicArmorCalculated",
            "LifeSteal",
        },
    },
    Reactions = {
        Header = "<font size='21'>———— Reactions ————</font>",
        Name = "Reactions",
        Behaviour = "GreyOut",
        Stats = {
            "FreeReaction_Generic",
            "FreeReaction_Predator",
            "FreeReaction_Celestial",
            "FreeReaction_Centurion",
            "FreeReaction_Elementalist",
            "FreeReaction_Occultist",
        },
    },
    -- Entries are dynamically generated.
    Artifacts = {
        Header = Text.Format("———— Artifacts ————", {Size = 21}),
        Name = "Artifacts",
        Behaviour = "Hidden",
        Stats = {},
    },
    Misc = {
        Header = "<font size='21'>———— Misc ————</font>",
        Name = "Miscellaneous",
        Behaviour = "GreyOut",
        Stats = {
            "PartyFunds_Gold",
            "PartyFunds_Splinters",
        },
    },
    CurrentCombat = {
        Header = "<font size='21'>———— Combat ————</font>",
        Name = "Combat",
        Behaviour = "GreyOut",
        Stats = {
            "CurrentCombat_DamageDealt",
            "CurrentCombat_DamageReceived",
            "CurrentCombat_HealingDone",
        },
    },

    -- KEYWORDS
    Keyword_Abeyance = {
        Header = "<font size='21'>———— Abeyance ————</font>",
        Name = "Abeyance",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Adaptation = {
        Header = "<font size='21'>———— Adaptation ————</font>",
        Name = "Adaptation",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Benevolence = {
        Header = "<font size='21'>——— Benevolence ———</font>",
        Name = "Benevolence",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Celestial = {
        Header = "<font size='21'>———— Celestial ————</font>",
        Name = "Celestial",
        Behaviour = "Hidden",
        Stats = {
            "Keyword_Celestial_Healing"
        },
    },
    Keyword_Centurion = {
        Header = "<font size='21'>———— Centurion ————</font>",
        Name = "Centurion",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Defiance = {
        Header = "<font size='21'>———— Defiance ————</font>",
        Name = "Defiance",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Elementalist = {
        Header = "<font size='21'>———— Elementalist ————</font>",
        Name = "Elementalist",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Occultist = {
        Header = "<font size='21'>———— Occultist ————</font>",
        Name = "Occultist",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Paucity = {
        Header = "<font size='21'>———— Paucity ————</font>",
        Name = "Paucity",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Predator = {
        Header = "<font size='21'>———— Predator ————</font>",
        Name = "Predator",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Presence = {
        Header = "<font size='21'>———— Presence ————</font>",
        Name = "Presence",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Prosperity = {
        Header = "<font size='21'>———— Prosperity ————</font>",
        Name = "Prosperity",
        Behaviour = "Hidden",
        Stats = {
            "Keyword_Prosperity_Threshold",
        },
    },
    Keyword_Purity = {
        Header = "<font size='21'>————— Purity —————</font>",
        Name = "Purity",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_ViolentStrike = {
        Header = "<font size='21'>——— Violent Strikes ———</font>",
        Name = "Violent Strikes",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_VitalityVoid = {
        Header = "<font size='21'>———— Vitality Void ————</font>",
        Name = "Vitality Void",
        Behaviour = "Hidden",
        Stats = {
            "Keyword_VitalityVoid_Power",
            "Keyword_VitalityVoid_Radius",
        },
    },
    Keyword_Voracity = {
        Header = Text.Format("———— Voracity ————", {Size = 21}),
        Name = "Voracity",
        Behaviour = "Hidden",
        Stats = {
            "Keyword_Voracity_Life",
            "Keyword_Voracity_PhysArmor",
            "Keyword_Voracity_MagicArmor",
            "Keyword_Voracity_Summon_Life",
            "Keyword_Voracity_Summon_PhysArmor",
            "Keyword_Voracity_Summon_MagicArmor",
        },
    },
    Keyword_Ward = {
        Header = "<font size='21'>————— Ward —————</font>",
        Name = "Ward",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Wither = {
        Header = "<font size='21'>————— Wither —————</font>",
        Name = "Wither",
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_IncarnateChampion = {
        Header = "<font size='21'>—Incarnate Champion—</font>",
        Name = "Incarnate Champion",
        Behaviour = "Hidden",
        Stats = {},
    },
}

local CategoriesOrder = {
    "Embodiments",
    "Vitals",
    "Reactions",
    "Artifacts",

    -- Keywords
    "Keyword_Abeyance",
    "Keyword_Adaptation",
    "Keyword_Benevolence",
    "Keyword_Celestial",
    "Keyword_Centurion",
    "Keyword_Defiance",
    "Keyword_Elementalist",
    "Keyword_Occultist",
    "Keyword_Paucity",
    "Keyword_Predator",
    "Keyword_Presence",
    "Keyword_Prosperity",
    "Keyword_Purity",
    "Keyword_ViolentStrike",
    "Keyword_VitalityVoid",
    "Keyword_Voracity",
    "Keyword_Ward",
    "Keyword_Wither",

    "CurrentCombat",
    "Misc",
}

-- Register categories in order.
-- TODO this leaves out a few ones like Keyword_IncarnateChampion - does that matter?
for _,id in ipairs(CategoriesOrder) do
    local category = Categories[id]

    CustomStats.RegisterCategory(id, category)
end