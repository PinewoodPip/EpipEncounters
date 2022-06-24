function GetCurrentCharges(char, reaction)
    local db = Osi.DB_AMER_Reaction_FreeCount_Remaining:Get(char, reaction, nil)

    if #db == 0 then
        return nil
    end

    return db[1][3]
end

function GetLifesteal(char)
    return Ext.GetCharacter(char).Stats.LifeSteal
end

function GetExtendedStatDBValue(db)
    if #db == 0 then
        return 0
    end
    return db[1][6]
end

function GetRegen(char, regenType)
    local allRegenDb = Osi.DB_AMER_ExtendedStat_AddedStat:Get(char, "Regen_All", nil, nil, nil, nil)
    local requestedRegenDB = Osi.DB_AMER_ExtendedStat_AddedStat:Get(char, "Regen_" .. regenType, nil, nil, nil, nil)
    local amount = 0

    amount = amount + GetExtendedStatDBValue(allRegenDb)
    amount = amount + GetExtendedStatDBValue(requestedRegenDB)

    -- add BothArmor stat when requesting armor regen
    if regenType == "PhysicalArmor" or regenType == "MagicArmor" then
        local bothArmorRegenDb = Osi.DB_AMER_ExtendedStat_AddedStat:Get(char, "Regen_BothArmor", nil, nil, nil, nil)

        amount = amount + GetExtendedStatDBValue(bothArmorRegenDb)
    end

    return math.min(amount, 50)
end

function GetAllEpicStats()
    local t = {}

    for category,statTable in pairs(epicStats) do
        for stat,data in pairs(statTable) do
            t[stat] = data
        end
    end

    return t
end

local function Italic(str)
    return tooltips.ItalicOpen .. str .. tooltips.FontClose
end

local function GetTooltipForReaction(reactionName)
    if reactionName == "Generic" then
        return tooltips.Reactions.FreeGenericReaction .. Addendum(tooltips.Reactions.FreeReactionsRecharge)
    end

    return string.format(tooltips.Reactions.FreeReactionExplanation, reactionName) .. Addendum(tooltips.Reactions.FreeReactionsRecharge)
end

local function GetRegenTooltip(stat)
    return tooltips.Stats[stat] .. Addendum(tooltips.Regeneration.CapWarning)
end

function Addendum(str)
    return tooltips.NewParagraph .. Italic(str)
end

function GreyOut(str)
    return "<font color='32302d'>" .. str .. "</font>"
end

keywordIdToName = {
    ["ViolentStrike"] = "Violent Strikes",
    ["VitalityVoid"] = "Vitality Void",
}

function GetKeywordTooltip(statData)
    local header = ""
    if statData.Type == "Activator" then
        header = tooltips.KeywordActivatorHeader
    else
        header = tooltips.KeywordMutatorHeader
    end

    local keywordName = statData.Keyword
    if keywordIdToName[keywordName] ~= nil then
        keywordName = keywordIdToName[keywordName]
    end

    header = string.format(header, keywordName)

    return header .. "" .. statData.Description
end

-- TODO add a setting for 0/1-based index
function GetKeywordSourceString(statData)
    local aspectText = string.format(tooltips.AspectNode, statData.SourceAspect, statData.NodeIndex + 1, statData.SubNodeIndex + 1)
    return string.format(tooltips.KeywordSource, aspectText)
end

function StatIsCategory(stat)
    return epicStats.Categories[stat] ~= nil
end

function GetDefaultStatValue(statData)
    if statData.DefaultValue ~= nil then
        return statData.DefaultValue
    end
    return 0
end

tooltips = {
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

    ["ItalicOpen"] = "<font color='a8a8a8' face='Averia Serif'>",
    ["FontClose"] = "</font>",
    ["NewParagraph"] = "<br><br>",
}

epicStats = {
    ["ExtendedStats"] = {
        ["FreeReactionCharge_AnyReaction"] = {
            ["Display"] = "Generic Charges",
            ["Description"] = GetTooltipForReaction("Generic"),
            ["mainStat"] = "FreeReactionCharge",
            ["prop1"] = "AnyReaction",
            ["prop2"] = "",
            ["prop3"] = ""
        },
        ["FreeReactionCharge_Predator"] = {
            ["Display"] = "Predator Charges",
            ["Description"] = GetTooltipForReaction("Predator"),
            ["mainStat"] = "FreeReactionCharge",
            ["prop1"] = "AMER_Predator",
            ["prop2"] = "",
            ["prop3"] = ""
        },
        ["FreeReactionCharge_Celestial"] = {
            ["Display"] = "Celestial Charges",
            ["Description"] = GetTooltipForReaction("Celestial"),
            ["mainStat"] = "FreeReactionCharge",
            ["prop1"] = "AMER_Celestial",
            ["prop2"] = "",
            ["prop3"] = ""
        },
        ["FreeReactionCharge_Centurion"] = {
            ["Display"] = "Centurion Charges",
            ["Description"] = GetTooltipForReaction("Centurion"),
            ["mainStat"] = "FreeReactionCharge",
            ["prop1"] = "AMER_Centurion",
            ["prop2"] = "",
            ["prop3"] = ""
        },
        ["FreeReactionCharge_Elementalist"] = {
            ["Display"] = "Elementalist Charges",
            ["Description"] = GetTooltipForReaction("Elementalist"),
            ["mainStat"] = "FreeReactionCharge",
            ["prop1"] = "AMER_Elementalist",
            ["prop2"] = "",
            ["prop3"] = ""
        },
        ["FreeReactionCharge_Occultist"] = {
            ["Display"] = "Occultist Charges",
            ["Description"] = GetTooltipForReaction("Occultist"),
            ["mainStat"] = "FreeReactionCharge",
            ["prop1"] = "AMER_Occultist",
            ["prop2"] = "",
            ["prop3"] = ""
        },
    },
    ["SpecialLogic"] = epicStatsKeywords,
    ["SpecialConsiderations"] = {
        ["FreeReactionCharge_AnyReaction_Current"] = {
            ["Display"] = "",
            ["Description"] = "",
            ["getter"] = GetCurrentCharges,
            ["param1"] = "AnyReaction"
        },
        ["FreeReactionCharge_Predator_Current"] = {
            ["Display"] = "",
            ["Description"] = "",
            ["getter"] = GetCurrentCharges,
            ["param1"] = "AMER_Predator"
        },
        ["FreeReactionCharge_Celestial_Current"] = {
            ["Display"] = "",
            ["Description"] = "",
            ["getter"] = GetCurrentCharges,
            ["param1"] = "AMER_Celestial"
        },
        ["FreeReactionCharge_Centurion_Current"] = {
            ["Display"] = "",
            ["Description"] = "",
            ["getter"] = GetCurrentCharges,
            ["param1"] = "AMER_Centurion"
        },
        ["FreeReactionCharge_Elementalist_Current"] = {
            ["Display"] = "",
            ["Description"] = "",
            ["getter"] = GetCurrentCharges,
            ["param1"] = "AMER_Elementalist"
        },
        ["FreeReactionCharge_Occultist_Current"] = {
            ["Display"] = "",
            ["Description"] = "",
            ["getter"] = GetCurrentCharges,
            ["param1"] = "AMER_Occultist"
        },
        ["LifeSteal"] = {
            ["Display"] = "Lifesteal",
            ["Description"] = "Lifesteal causes a percentage of the damage that you deal to Vitality to be restored to your own.",
            ["getter"] = GetLifesteal,
        },
        -- ["BatteredHarriedThreshold_Calculated"] = {
        --     ["Display"] = "B/H Threshold",
        --     ["getter"] = GetCurrentCharges,
        --     ["param1"] = ""
        -- },
        ["Regen_Life_Calculated"] = {
            ["Display"] = "Missing Life Regen",
            ["Description"] = GetRegenTooltip("Regen_Life_Calculated"),
            ["getter"] = GetRegen,
            ["param1"] = "Life"
        },
        ["Regen_PhysicalArmor_Calculated"] = {
            ["Display"] = "Missing Phys. Armor Regen",
            ["Description"] = GetRegenTooltip("Regen_PhysicalArmor_Calculated"),
            ["getter"] = GetRegen,
            ["param1"] = "PhysicalArmor"
        },
        ["Regen_MagicArmor_Calculated"] = {
            ["Display"] = "Missing Magic Armor Regen",
            ["Description"] = GetRegenTooltip("Regen_MagicArmor_Calculated"),
            ["getter"] = GetRegen,
            ["param1"] = "MagicArmor"
        },
    },
    ["Categories"] = {
        ["No_Category"] = {
            ["Display"] = "<font size='21'>————— Other —————</font>",
            ["BehaviourWhenUnused"] = "Hidden",
            ["Stats"] = {
            }
        },
        ["Category_Reactions"] = {
            -- <center> tag from html4 does not work. And doing this from flash requires an import, which JPEXS does not seem to support adding to existing scripts. Neither does <p> with center align - but that might be my fault.
            ["Display"] = "<font size='21'>———— Reactions ————</font>",
            ["BehaviourWhenUnused"] = "GreyOut", -- supported values: GreyOut to make stats grey when at default value, Hidden to hide stats at default value
            ["Stats"] = {
                "FreeReactionCharge_AnyReaction",
                "FreeReactionCharge_Predator",
                "FreeReactionCharge_Celestial",
                "FreeReactionCharge_Centurion",
                "FreeReactionCharge_Elementalist",
                "FreeReactionCharge_Occultist",
            }
        },
        ["Category_Vitals"] = {
            ["Display"] = "<font size='21'>————— Vitals —————</font>",
            ["BehaviourWhenUnused"] = "GreyOut",
            ["Stats"] = {
                -- "BatteredHarriedThreshold_Calculated",
                "Regen_Life_Calculated",
                "Regen_PhysicalArmor_Calculated",
                "Regen_MagicArmor_Calculated",
                "LifeSteal",
            }
        },
        ["Keyword_Abeyance"] = keywordCategories.Keyword_Abeyance,
        ["Keyword_Adaptation"] = keywordCategories.Keyword_Adaptation,
        ["Keyword_Benevolence"] = keywordCategories.Keyword_Benevolence,
        ["Keyword_Celestial"] = keywordCategories.Keyword_Celestial,
        ["Keyword_Centurion"] = keywordCategories.Keyword_Centurion,
        ["Keyword_Defiance"] = keywordCategories.Keyword_Defiance,
        ["Keyword_Elementalist"] = keywordCategories.Keyword_Elementalist,
        ["Keyword_Occultist"] = keywordCategories.Keyword_Occultist,
        ["Keyword_Paucity"] = keywordCategories.Keyword_Paucity,
        ["Keyword_Predator"] = keywordCategories.Keyword_Predator,
        ["Keyword_Presence"] = keywordCategories.Keyword_Presence,
        ["Keyword_Prosperity"] = keywordCategories.Keyword_Prosperity,
        ["Keyword_Purity"] = keywordCategories.Keyword_Purity,
        ["Keyword_ViolentStrike"] = keywordCategories.Keyword_ViolentStrike,
        ["Keyword_VitalityVoid"] = keywordCategories.Keyword_VitalityVoid,
        ["Keyword_Ward"] = keywordCategories.Keyword_Ward,
        ["Keyword_Wither"] = keywordCategories.Keyword_Wither,
        ["Keyword_IncarnateChampion"] = keywordCategories.Keyword_IncarnateChampion, -- NO LONGER USED, TODO REMOVE
    }
}

-- categories in the order that they display. Necessary because pairs() is unordered (cant tell how its ordered)
epicStatsCategoriesOrder = {
    "Category_Vitals",
    "Category_Reactions",
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
    -- "Keyword_IncarnateChampion",
    "No_Category",
}

-- categories of stats that need special value formatting.
epicStatsSpecialFormatting = {
    ["Reactions"] = {
        "FreeReactionCharge_AnyReaction",
        "FreeReactionCharge_Predator",
        "FreeReactionCharge_Celestial",
        "FreeReactionCharge_Centurion",
        "FreeReactionCharge_Elementalist",
        "FreeReactionCharge_Occultist",
    },
    ["Percentage"] = {
        "Regen_Life_Calculated",
        "Regen_PhysicalArmor_Calculated",
        "Regen_MagicArmor_Calculated",
        "LifeSteal",
    }
}

-- add stats with no category to a special one
local statsWithNoCategory = {}
for i,v in pairs(GetAllEpicStats()) do
    -- isInCategory = false
    -- for category,data in pairs(epicStats.Categories) do
    --     if TableHasValue(data.Stats, i) or StatIsCategory(i) then
    --         isInCategory = true
    --         break
    --     end
    -- end

    -- if not isInCategory then
    --     table.insert(statsWithNoCategory, i)
    -- end

    v.ID = i -- add a "id" prop to all, so we can just pass the table and have all the technical info
end

epicStats.Categories["No_Category"].Stats = statsWithNoCategory

-- Ext.Dump(epicStats.Categories)