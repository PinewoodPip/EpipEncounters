
local CustomStats = Epip.GetFeature("Feature_CustomStats")
local CommonStrings = Text.CommonStrings
local CATEGORY_HEADER_SIZE = 21

---@param template string
---@param tsk TextLib_TranslatedString
---@return string
local function FormatHeader(template, tsk)
    return Text.Format(template, {
        Size = CATEGORY_HEADER_SIZE, 
        FormatArgs = {
            tsk:GetString(),
        },
    })
end

local Categories = {
    Embodiments = {
        Header = FormatHeader("——— %s ———", CommonStrings.Embodiments),
        Name = CommonStrings.Embodiments,
        Stats = {
            "Embodiment_Force",
            "Embodiment_Entropy",
            "Embodiment_Form",
            "Embodiment_Inertia",
            "Embodiment_Life",
        },
    },
    Reactions = {
        Header = FormatHeader("———— %s ————", CommonStrings.Reactions),
        Name = CommonStrings.Reactions,
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
        Header = FormatHeader("———— %s ————", CommonStrings.Artifacts),
        Name = CommonStrings.Artifacts,
        Behaviour = "Hidden",
        Stats = {},
    },

    -- KEYWORDS
    Keyword_Abeyance = {
        Header = FormatHeader("———— %s ————", CommonStrings.Abeyance),
        Name = CommonStrings.Abeyance,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Adaptation = {
        Header = FormatHeader("———— %s ————", CommonStrings.Adaptation),
        Name = CommonStrings.Adaptation,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Benevolence = {
        Header = FormatHeader("——— %s ———", CommonStrings.Benevolence),
        Name = CommonStrings.Benevolence,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Celestial = {
        Header = FormatHeader("———— %s ————", CommonStrings.Celestial),
        Name = CommonStrings.Celestial,
        Behaviour = "Hidden",
        Stats = {
            "Keyword_Celestial_Healing"
        },
    },
    Keyword_Centurion = {
        Header = FormatHeader("———— %s ————", CommonStrings.Centurion),
        Name = CommonStrings.Centurion,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Defiance = {
        Header = FormatHeader("———— %s ————", CommonStrings.Defiance),
        Name = CommonStrings.Defiance,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Elementalist = {
        Header = FormatHeader("——— %s ———", CommonStrings.Elementalist),
        Name = CommonStrings.Elementalist,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Occultist = {
        Header = FormatHeader("———— %s ————", CommonStrings.Occultist),
        Name = CommonStrings.Occultist,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Paucity = {
        Header = FormatHeader("———— %s ————", CommonStrings.Paucity),
        Name = CommonStrings.Paucity,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Predator = {
        Header = FormatHeader("———— %s ————", CommonStrings.Predator),
        Name = CommonStrings.Predator,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Presence = {
        Header = FormatHeader("———— %s ————", CommonStrings.Presence),
        Name = CommonStrings.Presence,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Prosperity = {
        Header = FormatHeader("———— %s ————", CommonStrings.Prosperity),
        Name = CommonStrings.Prosperity,
        Behaviour = "Hidden",
        Stats = {
            "Keyword_Prosperity_Threshold",
        },
    },
    Keyword_Purity = {
        Header = FormatHeader("————— %s —————", CommonStrings.Purity),
        Name = CommonStrings.Purity,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_ViolentStrike = {
        Header = FormatHeader("——— %s ———", CommonStrings.ViolentStrikes),
        Name = CommonStrings.ViolentStrikes,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_VitalityVoid = {
        Header = FormatHeader("——— %s ———", CommonStrings.VitalityVoid),
        Name = CommonStrings.VitalityVoid,
        Behaviour = "Hidden",
        Stats = {
            "Keyword_VitalityVoid_Power",
            "Keyword_VitalityVoid_Radius",
        },
    },
    Keyword_Voracity = {
        Header = FormatHeader("———— %s ————", CommonStrings.Voracity),
        Name = CommonStrings.Voracity,
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
        Header = FormatHeader("———— %s ————", CommonStrings.Ward),
        Name = CommonStrings.Ward,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_Wither = {
        Header = FormatHeader("———— %s ————", CommonStrings.Wither),
        Name = CommonStrings.Wither,
        Behaviour = "Hidden",
        Stats = {},
    },
    Keyword_IncarnateChampion = {
        Header = FormatHeader("——— %s ———", CommonStrings.IncarnateChampion),
        Name = CommonStrings.IncarnateChampion,
        Behaviour = "Hidden",
        Stats = {},
    },
}

local CategoriesOrder = {
    "Embodiments",
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
    "Keyword_IncarnateChampion",
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
}

-- Register categories in order.
-- TODO this leaves out a few ones like Keyword_IncarnateChampion - does that matter?
for _,id in ipairs(CategoriesOrder) do
    local category = Categories[id]

    CustomStats.RegisterCategory(id, category)
end