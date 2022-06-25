
---------------------------------------------
-- Stat definitions for Epip's custom stats.
-- Shared script, as these must exist on the server as well to update them.
---------------------------------------------

---------------------------------------------
-- To add new stats, define them in .STATS and insert them into a category in .CATEGORIES.
-- See StatGetters.lua for actually setting them - for stats formatted in the same
-- manner as the built-in Ascension ones, this is automatic - 
-- but you need to call PerformFullStatsUpdate() in a patch script when adding them.
-- We only keep track of equipped nodes that have a stat defined.
---------------------------------------------

---@meta Library: EpipStatsTab, ContextShared, Epip.Features.EpipStats

---@class EpipStats
---@field CATEGORIES table<string, EpipStatCategory> Category definitions.
---@field CATEGORIES_ORDER string[]
---@field STATS table<string, EpipStat>
---@field MISSING_REGEN_CAP number TODO move
---@field STAT_VALUE_TAG string Pattern for stat tags.
---@field STAT_VALUE_TAG_PREFIX string
---@field TOOLTIP_TALENT number TODO remove
---@field TOOLTIP_TALENT_NAME string TODO remove

---@class EpipStat
---@field Name string
---@field Description string Fallback description in case a formatted Tooltip isn't set.
---@field Tooltip TooltipData
---@field Footnote string Italic text after description, in new paragraph.
---@field Suffix string Suffix for value display.
---@field Prefix string Prefix for value display.
---@field Boolean boolean Boolean stats show no value label.
---@field MaxCharges string If specified, this stat will display as "{Value}/{Value of MaxCharges stat}"
---@field IgnoreForHiding boolean If true, this stat will not be considered as added when determining if a Hidden category should display.

---@alias EpipStatCategoryBehaviour "GreyOut" | "Hidden"

---@class EpipStatCategory
---@field Header string Name of the collapsable stat.
---@field Name string Name of the category in the tooltip.
---@field Behaviour EpipStatCategoryBehaviour Controls how default-value stats are shown. GreyOut greys out their label and value, hidden hides them - and the whole category - if no stats are owned.
---@field Stats string[] Stats displayed in the category, ordered.

---@type EpipStats
local EpipStats = {
    CATEGORIES = {
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
    },
    
    -- TODO rework as a hook
    CATEGORIES_ORDER = {
        "Vitals",
        "Reactions",

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
        "Keyword_Ward",
        "Keyword_Wither",

        "CurrentCombat",
        "Misc",
    },

    STATS = {
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
        -- VITALS
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
        PartyFunds_Splinters = {
            Name = "Party Splinters",
            Description = "The Artificer's Splinters currently in the party's possession.",
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
    },

    MISSING_REGEN_CAP = 50,

    -- We use tags to store stat values now,
    -- instead of PersistentVars.
    -- Hopefully this makes synching less janky.
    -- Capture groups: Stat ID and amount
    STAT_VALUE_TAG = "PIP_STATS_TAB_(.*)_(-?[0-9]*%.?[0-9]*)$",
    STAT_VALUE_TAG_PREFIX = "PIP_STATS_TAB_",

    TOOLTIP_TALENT = 126,
    TOOLTIP_TALENT_NAME = "MasterThief",

    ---------------------------------------------
    -- INTERNAL VARIABLES - DO NOT SET
    ---------------------------------------------

    cachedStats = {},
    openCategories = {
        Vitals = true, -- Open by default.
        Reactions = true,
    },
    nextTooltipIsStat = false,
}
Epip.AddFeature("StatsTab", "EpipStats", EpipStats)

---@type EpipStatCategory
local BaseCategory = {
    Header = "Missing .Header",
    Name = "Missing .Name",
    Behaviour = "GreyOut",
    Stats = {},
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a stat bound to an Ascension node.
---@meta RequireBothContexts
---@param clusterId string
---@param nodeIndex number
---@param nodeSubIndex number
---@param keyword Keyword
---@param keywordType KeywordBoonType
---@param statData EpipStat Stat metadata.
function EpipStats.AddNodeStat(clusterId, nodeIndex, nodeSubIndex, keyword, keywordType, statData)
    local statID = string.format("%s_Node_%d.%d", clusterId, nodeIndex, nodeSubIndex)

    local stat = {
        Name = statData.Name,
        Description = statData.Description,
        Boolean = true,

        -- Extra metadata
        Keyword = keyword,
        BoonType = keywordType,
        NodeIndex = nodeIndex + 1,
        NodeSubIndex = nodeSubIndex + 1,
        Cluster = clusterId
    }

    -- Add stat to list
    EpipStats.STATS[statID] = stat

    -- Add stat to category
    local category = "Keyword_" .. keyword
    if EpipStats.CATEGORIES[category] then
        table.insert(EpipStats.CATEGORIES[category].Stats, statID)
    else
        EpipStats:LogError("Keyword category missing: " .. category)
    end
end

---Register a stat.
---@meta RequireBothContexts
---@param id string
---@param data EpipStat
function EpipStats.RegisterStat(id, data)
    ---@type EpipStat
    local default = {
        Name = id,
        Description = "I'm a stat that needs a .Description!",
    }
    setmetatable(data, default)

    EpipStats.STATS[id] = data
end

---Register a category.
---@meta RequireBothContexts
---@param id string
---@param data EpipStatCategory
---@param index? integer Order in the stats tab relative to other categories.
function EpipStats.RegisterCategory(id, data, index)
    setmetatable(data, BaseCategory)
    EpipStats.CATEGORIES[id] = data
    
    index = index or #EpipStats.CATEGORIES_ORDER + 1

    table.insert(EpipStats.CATEGORIES_ORDER, index, id)
end

---Add a stat to a category.
---@meta RequireBothContexts
---@param statID string
---@param categoryID string
---@param index? integer
function EpipStats.AddStatToCategory(statID, categoryID, index)
    local category = EpipStats.CATEGORIES[categoryID]

    index = index or #category.Stats + 1

    table.insert(category.Stats, index, statID)
end

---------------------------------------------
-- SETUP (Ascension stats)
---------------------------------------------

Data.Game.ASPECT_NAMES = {}
-- TODO cache
for id,data in pairs(epicStatsKeywords) do
    if not Data.Game.ASPECT_NAMES[data.ClusterId] then
        Data.Game.ASPECT_NAMES[data.ClusterId] = data.SourceAspect
    end
end

-- Create Ascension stats from old data
for id,data in pairs(epicStatsKeywords) do
    EpipStats.AddNodeStat(data.ClusterId, data.NodeIndex, data.SubNodeIndex, data.Keyword, data.Type, {
        Name = data.Display,
        Description = data.Description,
    })
end