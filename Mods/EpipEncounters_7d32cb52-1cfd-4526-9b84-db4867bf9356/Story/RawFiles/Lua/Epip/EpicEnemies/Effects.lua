
---@type EpicEnemiesEffectsCategory
local ArtifactsCategory = {
    Name = "Artifacts",
    ID = "Artifacts",
    Effects = {}, -- Filled in automatically
}

local artifactWeights = {
    Artifact_Adamant = 5,
    Artifact_AngelsEgg = 8,
    Artifact_Austerity = 10,
    Artifact_BlackglassBrand = 10,
    Artifact_Cataclysm = 10,
    Artifact_Chthonian = 10,
    Artifact_Consecration = 5,
    Artifact_Convergence = 5,
    Artifact_Crucible = 5, -- TODO special condition
    Artifact_Desperation = 5,
    Artifact_Dread = 3,
    Artifact_DrogsLuck = 8,
    Artifact_Dominion = 8,
    Artifact_EyeOfTheStorm = 5,
    Artifact_Famine = 5,
    Artifact_Fecundity = 5,
    Artifact_Gluttony = 5,
    Artifact_Goldforge = 3,
    Artifact_GramSwordOfGrief = 3,
    Artifact_Hibernaculum = 5,
    Artifact_Impetus = 8,
    Artifact_InfernalContract = 5,
    Artifact_Jaguar = 5,
    Artifact_Judgement = 5,
    Artifact_LambentBlade = 3,
    Artifact_Lightspire = 3,
    Artifact_MalleusMaleficarum = 5,
    Artifact_Mirage = 1,
    Artifact_Misery = 3,
    Artifact_Nightmare = 5,
    Artifact_Pestilence = 3,
    Artifact_Rapture = 5,
    Artifact_Savage = 3,
    Artifact_Seraph = 3,
    Artifact_Silkclimb = 3,
    Artifact_Thirst = 3,
    Artifact_Urgency = 3,
    Artifact_Vertigo = 3,
    Artifact_WintersGrasp = 3,
    Artifact_Wraith = 1,
    Artifact_Zenith = 5,
    Artifact_Zodiac = 3,
}

local TestEffects = {
    Name = "TEST",
    ID = "TestEffects",
    Effects = {
        {
            Name = "HealthThreshold Test",
            ID = "HealthThreshold",
            Description = "...",
            ---@type EpicEnemiesCondition_HealthThreshold
            ActivationCondition = {
                Type = "HealthThreshold",
                Vitality = 0.5,
                -- PhysicalArmor = 0.4,
                MagicArmor = 0.3,
                -- RequireAll = true,
            },
            Status = {
                StatusID = "BLESSED",
                Duration = 2,
            },
        },
        {
            Name = "BatteredHarried Test",
            ID = "BatteredHarriedTest",
            Description = "...",
            ---@type EpicEnemiesCondition_BatteredHarried
            ActivationCondition = {
                Type = "BatteredHarried",
                StackType = "H",
                Amount = 2,
            },
            Status = {
                StatusID = "HASTED",
                Duration = 1,
            },
        },
        {
            Name = "StatusGained Test",
            ID = "StatusGainedTest",
            Description = "...",
            ---@type EpicEnemiesCondition_StatusGained
            ActivationCondition = {
                Type = "StatusGained",
                StatusID = "HASTED",
            },
            Status = {
                StatusID = "BLESSED",
                Duration = 1,
            },
        },
        {
            Name = "RequiredSkill Test",
            ID = "StatusGainedTest",
            Description = "...",
            RequiredSkills = {"Target_Haste"},
            Status = {
                StatusID = "BLESSED",
                Duration = 1,
            },
        },
        {
            Name = "TurnStart Activation Test",
            ID = "TestStatus2",
            Description = "Hasted on turn 2.",
            Status = {
                StatusID = "HASTED",
                Duration = 2,
            },
            ActivationCondition = {
                Type = "TurnStart",
                Round = 2,
                Repeat = false,
            },
        },
        {
            Name = "SUICIDE BOMB",
            ID = "TestStatus",
            Description = "asdasd",
            Status = {
                StatusID = "AMER_FLAMING_CRESCENDO",
                Duration = 1,
            },
        },
        {
            Name = "TurnStart Activation Test (Repeat)",
            ID = "Test_TurnStart_2",
            Description = "Clockwork bomb summon on turn 2+ (repeats)",
            Summon = "6f8db517-f1af-4b47-b095-f239fd2293d0",
            ActivationCondition = {
                Type = "TurnStart",
                Round = 2,
                Repeat = true,
            },
        },
        {
            Name = "Clockwork Bomb",
            ID = "SummonEffect",
            Description = "",
            Summon = "6f8db517-f1af-4b47-b095-f239fd2293d0",
        },
        {
            Name = "Boneshaped Crusher Summon",
            ID = "Summon_BoneshapedCrusher",
            Description = "Grants the character a Boneshaped Crusher summon.",
            Summon = "02a84627-6b66-46ad-85f0-769a0c210539",
        },
        {
            Name = "Extended stat test",
            ID = "ExtendedStatTest",
            Description = "",
            ExtendedStats = {
                {
                    StatID = "Shoot_OnStatus",
                    Amount = 1,
                    Property1 = "HASTED",
                    Property2 = "Projectile_ChainHeal",
                    Property3 = "RemoteImpact",
                }
            },
        }
    },
}

local Effects = {
    Categories = {
        {
            Name = "Violent Strikes",
            ID = "ViolentStrike",
            Effects = {
                {
                    Name = "Violent Strikes Activator: Conqueror",
                    ID = "Ascension_ViolentStrike_ACT_BasicOnHit",
                    Description = "15% chance per hit",
                    SpecialLogic = "Ascension_ViolentStrike_ACT_BasicOnHit",
                    Keyword = {Keyword = "ViolentStrike", BoonType = "Activator",},
                },
                {
                    Name = "Violent Strikes Activator: Archer",
                    ID = "Ascension_ViolentStrike_ACT_DamageAtOnce",
                    Description = "After dealing damage exceeding 20% of total Vitality",
                    Cost = 5,
                    SpecialLogic = "Ascension_ViolentStrike_ACT_DamageAtOnce",
                    Keyword = {Keyword = "ViolentStrike", BoonType = "Activator",},
                },
                {
                    Name = "Violent Strikes Activator: Hatchet",
                    ID = "Ascension_ViolentStrike_ACT_0AP",
                    Description = "After reaching 0 AP",
                    Cost = 5,
                    SpecialLogic = "Ascension_ViolentStrike_ACT_0AP",
                    Keyword = {Keyword = "ViolentStrike", BoonType = "Activator",},
                },
                {
                    Name = "Violent Strikes Mutator: Conqueror",
                    ID = "Ascension_ViolentStrike_MUTA_VitalityVoidACT",
                    Description = "Vitality Void when performing Violent Strike",
                    Weight = 0,
                    Cost = 20,
                    SpecialLogic = "Ascension_ViolentStrike_MUTA_VitalityVoidACT",
                    Keyword = {Keyword = "ViolentStrike", BoonType = "Mutator",},
                },
                {
                    Name = "Violent Strikes Mutator: Hatchet",
                    ID = "Ascension_ViolentStrike_MUTA_Terrified2",
                    Description = "Apply up to Terrified II",
                    Cost = 7,
                    SpecialLogic = "Ascension_ViolentStrike_MUTA_Terrified2",
                    Keyword = {Keyword = "ViolentStrike", BoonType = "Mutator",},
                },
            },
        },
        {
            Name = "Elementalist",
            ID = "Elementalist",
            Effects = {
                {
                    Name = "Elementalist Activator: Falcon",
                    ID = "Ascension_Elementalist_ACT_FireEarth_AllySkills",
                    Description = "On Geomancer/Pyromancer",
                    Cost = 12,
                    SpecialLogic = "Ascension_Elementalist_ACT_FireEarth_AllySkills",
                    Keyword = {Keyword = "Elementalist", BoonType = "Activator"},
                },
                {
                    Name = "Elementalist Activator: Arcanist",
                    ID = "Ascension_Elementalist_ACT_PredatorOrVuln3",
                    Description = "On Predator/Vulnerable III",
                    Cost = 5,
                    SpecialLogic = "Ascension_Elementalist_ACT_PredatorOrVuln3",
                    Keyword = {Keyword = "Elementalist", BoonType = "Activator"},
                },
                {
                    Name = "Elementalist Activator: Hind",
                    ID = "Ascension_Elementalist_ACT_AirWater_AllySkills",
                    Description = "On Aerotheurge/Hydrosophist Skill",
                    Cost = 12,
                    SpecialLogic = "Ascension_Elementalist_ACT_AirWater_AllySkills",
                    Keyword = {Keyword = "Elementalist", BoonType = "Activator"},
                },
                {
                    Name = "Elementalist Activator: Pegasus",
                    ID = "Ascension_Elementalist_ACT_AirWater_AllySkills_MK2_HuntsWar",
                    Description = "On Huntsman/Warfare Skill",
                    Cost = 12,
                    SpecialLogic = "Ascension_Elementalist_ACT_AirWater_AllySkills_MK2_HuntsWar",
                    Keyword = {Keyword = "Elementalist", BoonType = "Activator"},
                },
                {
                    Name = "Elementalist Mutator: Falcon",
                    ID = "Ascension_Elementalist_MUTA_FireEarth_NonTieredStatuses",
                    Description = "On Calcifying/Scorched",
                    SpecialLogic = "Ascension_Elementalist_MUTA_FireEarth_NonTieredStatuses",
                    Keyword = {Keyword = "Elementalist", BoonType = "Mutator"},
                },
                {
                    Name = "Elementalist Mutator: Arcanist",
                    ID = "Ascension_ViolentStrike_ACT_ElemStacks",
                    Description = "Violent Strike when 2 or more stacks",
                    SpecialLogic = "Ascension_ViolentStrike_ACT_ElemStacks",
                    Keyword = {Keyword = "Elementalist", BoonType = "Mutator"},
                },
                {
                    Name = "Elementalist Mutator: Kraken",
                    ID = "Ascension_Elementalist_MUTA_FeedbackPowerEffect",
                    Description = "+10% Damage from Power per stack",
                    Cost = 15,
                    SpecialLogic = "Ascension_Elementalist_MUTA_FeedbackPowerEffect",
                    Keyword = {Keyword = "Elementalist", BoonType = "Mutator"},
                },
                {
                    Name = "Elementalist Mutator: Scorpion",
                    ID = "Ascension_Elementalist_MUTA_FeedbackCrit",
                    Description = "+5% Crit Chance per stack",
                    Cost = 15,
                    SpecialLogic = "Ascension_Elementalist_MUTA_FeedbackCrit",
                    Keyword = {Keyword = "Elementalist", BoonType = "Mutator"},
                },
                
            },
        },
        {
            Name = "Predator",
            ID = "Predator",
            Effects = {
                {
                    Name = "Predator Activator: Falcon",
                    ID = "Ascension_Predator_ACT_BHStacks",
                    Description = "After reaching 7 stacks of either Battered or Harried",
                    SpecialLogic = "Ascension_Predator_ACT_BHStacks",
                    Keyword = {Keyword = "Predator", BoonType = "Activator"},
                },
                {
                    Name = "Predator Activator: Manticore",
                    ID = "Ascension_Predator_ACT_Terrified",
                    Description = "On Terrified",
                    SpecialLogic = "Ascension_Predator_ACT_Terrified",
                    Keyword = {Keyword = "Predator", BoonType = "Activator"},
    
                },
                {
                    Name = "Predator Activator: Tiger",
                    ID = "Ascension_Predator_ACT_Dazzled",
                    Description = "On Dazzled",
                    SpecialLogic = "Ascension_Predator_ACT_Dazzled",
                    Keyword = {Keyword = "Predator", BoonType = "Activator"},
                },
                {
                    Name = "Predator Mutator: Tiger",
                    ID = "Ascension_Predator_MUTA_Hemorrhage",
                    Description = "Apply Hemorrhage if target is Bleeding",
                    SpecialLogic = "Ascension_Predator_MUTA_Hemorrhage",
                    Keyword = {Keyword = "Predator", BoonType = "Mutator"},
                },
                {
                    Name = "Predator Mutator: Falcon",
                    ID = "Ascension_Predator_MUTA_Slowed2",
                    Description = "Apply up to Slowed II",
                    Cost = 5,
                    SpecialLogic = "Ascension_Predator_MUTA_Slowed2",
                    Keyword = {Keyword = "Predator", BoonType = "Mutator"},
                },
            },
        },
        {
            Name = "Centurion",
            ID = "Centurion",
            Effects = {
                {
                    Name = "Centurion Activator: Key",
                    ID = "Ascension_Centurion_ACT_MissedByAttack",
                    Description = "After dodging an attack",
                    SpecialLogic = "Ascension_Centurion_ACT_MissedByAttack",
                    Keyword = {Keyword = "Centurion", BoonType = "Activator"},
                },
                {
                    Name = "Centurion Activator: Guardsman",
                    ID = "Ascension_Centurion_ACT_HitAlly",
                    Description = "When an ally is hit",
                    SpecialLogic = "Ascension_Centurion_ACT_HitAlly",
                    Keyword = {Keyword = "Centurion", BoonType = "Activator"},
                },
            },
        },
        {
            Name = "Celestial",
            ID = "Celestial",
            Effects = {
                {
                    Name = "Celestial Activator: Champion",
                    ID = "Ascension_Celestial_ACT_Offensive",
                    Description = "On Vulnerable III",
                    SpecialLogic = "Ascension_Celestial_ACT_Offensive",
                    Keyword = {Keyword = "Celestial", BoonType = "Activator"},
                },
                {
                    Name = "Celestial Activator: Hind",
                    ID = "Ascension_Celestial_ACT_AllySource",
                    Description = "When an ally with less than 50% Vitality spends Source",
                    Cost = 12,
                    SpecialLogic = "Ascension_Celestial_ACT_AllySource",
                    Keyword = {Keyword = "Celestial", BoonType = "Activator"},
                },
            },
        },
        {
            Name = "Vitality Void",
            ID = "VitalityVoid",
            Effects = {
                {
                    Name = "Vitality Void Activator: Death",
                    ID = "Ascension_VitalityVoid_ACT_CombatDeath",
                    Description = "When a non-summon character dies",
                    SpecialLogic = "Ascension_VitalityVoid_ACT_CombatDeath",
                    Keyword = {Keyword = "VitalityVoid", BoonType = "Activator"},
                },
                {
                    Name = "Vitality Void Activator: Fly",
                    ID = "Ascension_VitalityVoid_ACT_SourceSpent",
                    Description = "For each Source Point spent",
                    Weight = 8,
                    Cost = 20,
                    SpecialLogic = "Ascension_VitalityVoid_ACT_SourceSpent",
                    Keyword = {Keyword = "VitalityVoid", BoonType = "Activator"},
                },
            },
        },
        {
            Name = "Ward",
            ID = "Ward",
            Effects = {
                {
                    Name = "Ward Activator: Gryphon",
                    ID = "Ascension_Ward_ACT_MK2_CritByEnemy",
                    Description = "When being Critically Hit",
                    SpecialLogic = "Ascension_Ward_ACT_MK2_CritByEnemy",
                    Keyword = {Keyword = "Ward", BoonType = "Activator"},
                },
            },
        },
        {
            Name = "Presence",
            ID = "Presence",
            Effects = {
                {
                    Name = "Presence Mutators",
                    ID = "Ascension_Presence_MUTA_MK2_VitRegen",
                    Description = "Grants missing Vitality regeneration, damage and resistances",
                    SpecialLogic = "Ascension_Presence_MUTA_MK2_VitRegen",
                    FlexStats = {
                        {
                            Type = "Ability",
                            Stat = "Leadership",
                            Amount = 10,
                        },
                    },
                    Keyword = {Keyword = "Presence", BoonType = "Mutator"},
                },
            },
        },
        {
            Name = "Wither",
            ID = "Wither",
            Effects = {
                {
                    Name = "Wither Activator: Basilisk",
                    ID = "Ascension_Wither_ACT_Calcifying",
                    Description = "On Calcifying",
                    SpecialLogic = "Ascension_Wither_ACT_Calcifying",
                    Keyword = {Keyword = "Wither", BoonType = "Activator"},
                },
            },
        },
        ArtifactsCategory,
        {
            Name = "Miscellaneous",
            ID = "Miscellaneous",
            Effects = {
                {
                    Name = "Boneshaped Crusher",
                    ID = "Ascension_Skill_BoneshapedCrusher",
                    Description = "Character gains the Summon Boneshaped Crusher spell.",
                    Weight = 0,
                    Cost = 25,
                    SpecialLogic = "Ascension_Skill_BoneshapedCrusher",
                },
                {
                    Name = "Spellcaster Finesse",
                    ID = "Ascension_MageFin",
                    Description = "Finesse's AP recovery works on magic spells",
                    SpecialLogic = "Ascension_MageFin",
                },
            },
        },
    },
}
Epip.AddFeature("EpicEnemiesEffects", "EpicEnemiesEffects", Effects)

local EpicEnemies = Epip.Features.EpicEnemies

---------------------------------------------
-- SETUP
---------------------------------------------

-- Generate Artifact options
for id,artifact in pairs(Item.ARTIFACTS) do
    -- local displayStatus = Ext.Stats.Get("AMER_ARTIFACTPOWER_" .. id:gsub("Artifact_", ""):upper())

    -- if not displayStatus then
    --     displayStatus = Ext.Stats.Get("AMER_ARTIFACTPOWER_THE" .. id:gsub("Artifact_", ""):upper(), nil, false)

    --     if displayStatus then
    --         Ext.Stats.SetPersistence("AMER_ARTIFACTPOWER_THE" .. id:gsub("Artifact_", ""):upper(), false)
    --     end
    -- else
    --     Ext.Stats.SetPersistence("AMER_ARTIFACTPOWER_" .. id:gsub("Artifact_", ""):upper(), false)
    -- end

    -- if id == "Artifact_CorruscatingSilks" then
    --     displayStatus = Ext.Stats.Get("AMER_ARTIFACTPOWER_CORUSCATINGSILKS", nil, false)

    --     if displayStatus then
    --         Ext.Stats.SetPersistence("AMER_ARTIFACTPOWER_CORUSCATINGSILKS", false)
    --     end
    -- end

    if id ~= "Artifact_Deck" then
    -- if displayStatus and id ~= "Artifact_Deck" then
        -- TODO figure out why this fails
        -- local description = Ext.L10N.GetTranslatedStringFromKey(displayStatus.DisplayName)

        -- if not description or description == "" then
        --     description = displayStatus.DisplayNameRef
        -- end

        local description = artifact:GetDescription()
        ---@type EpicEnemiesKeywordData
        local keyword = nil
        if #artifact.KeywordActivators > 0 then
            keyword = {
                Keyword = artifact.KeywordActivators[1],
                BoonType = "Activator",
            }
        elseif #artifact.KeywordMutators > 0 then
            keyword = {
                Keyword = artifact.KeywordMutators[1],
                BoonType = "Mutator",
            }
        end

        ---@type EpicEnemiesEffect
        local effect = {
            ID = id,
            Name = Text.Format("Artifact: %s", {FormatArgs = {
                artifact:GetName()
            }}),
            DefaultCost = 15,
            DefaultWeight = artifactWeights[id] or 0,
            Description = description,
            Artifact = artifact.ID,
            Keyword = keyword,
        }
        table.insert(ArtifactsCategory.Effects, effect)
    else
        Ext.PrintError("Cannot find DisplayStatus for artifact: " .. id)
    end
end
table.sort(ArtifactsCategory.Effects, function(a, b) return a.Name < b.Name end)

-- Initialize effects
for _,category in pairs(Effects.Categories) do
    EpicEnemies.RegisterEffectCategory(category)
end

if Epip.IsDeveloperMode(true) then
    EpicEnemies.RegisterEffectCategory(TestEffects)
end

---@type EpicEnemiesExtendedEffect
local forcedEffect = {
    Name = "ForcedEffect",
    ID = "PIP_ForcedEffect",
    Description = "Character has increased Predator range and gains 2 free Generic reaction charges.",
    SpecialLogic = "Ascension_Predator_MUTA_EpicBossRange",
    Keyword = {Keyword = "Predator", BoonType = "Mutator"},
    Cost = 0,
    Weight = 0,
    Visible = false,
    ExtendedStats = {
        {
            StatID = "FreeReactionCharge",
            Property1 = "AnyReaction",
            Amount = 2,
        }
    },
}
EpicEnemies.RegisterEffect(forcedEffect.ID, forcedEffect)

if Ext.IsServer() then
    EpicEnemies.Events.CharacterInitialized:RegisterListener(function(char, effects)
        EpicEnemies.ApplyEffect(char, forcedEffect)
    end)
end