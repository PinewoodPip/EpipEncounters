
local EpicEnemies = Epip.GetFeature("Feature_EpicEnemies")

---@type Features.EpicEnemies.EffectCategory
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

---@type Feature
local Effects = {
    TranslatedStrings = {
        Keyword_ViolentStrike_Activator = {
            Handle = "haf6a360fg632eg4da1g9b55g2ab6ca582059",
            Text = "Violent Strikes Activator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_ViolentStrike_Mutator = {
            Handle = "h7eef9e20g4f25g463egbaa7gbbd250b554c8",
            Text = "Violent Strikes Mutator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Elementalist_Activator = {
            Handle = "h951a2633ge5d9g4452g8b7bg87c66176f938",
            Text = "Elementalist Activator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Elementalist_Mutator = {
            Handle = "hba96f941g3f15g4b61g8ff0gcfd688243b5d",
            Text = "Elementalist Mutator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Prosperity_Activator = {
            Handle = "h44b68871gd69eg4326gb38ag7f21c34ef0a4",
            Text = "Prosperity Activator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Prosperity_Mutator = {
            Handle = "h75a36550gb2b4g454eg8e2cg946b4a037fa3",
            Text = "Prosperity Mutator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Predator_Activator = {
            Handle = "hf4fe45e4g3e55g48a3gb2acgd025803a0dfa",
            Text = "Predator Activator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Predator_Mutator = {
            Handle = "h210cf852gf864g4c7dgb1f8gcec415573b8b",
            Text = "Predator Mutator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Centurion_Activator = {
            Handle = "h37831f03g8ba1g473agb7f7g8118315cb64a",
            Text = "Centurion Activator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Centurion_Mutator = {
            Handle = "ha16ffc0agfb05g4dbeg8bbbg0a1696de3c31",
            Text = "Centurion Mutator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Celestial_Activator = {
            Handle = "h4560bb6bg439eg43f8g9db8gebfcaa3c008c",
            Text = "Celestial Activator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_VitalityVoid_Activator = {
            Handle = "h28960efcg10f7g4482g8563gd91ee9bffe89",
            Text = "Vitality Void Activator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Ward_Activator = {
            Handle = "hc1ee75b0gff4dg4dc5ga322g725a35121842",
            Text = "Ward Activator",
            ContextDescription = [[Prefix for effect names]],
        },
        Keyword_Wither_Activator = {
            Handle = "hf50fcf99gd7dag42b7g96d3gf212e81c8be5",
            Text = "Wither Activator",
            ContextDescription = [[Prefix for effect names]],
        },
    },
}
Epip.RegisterFeature("Features.EpicEnemies.EpicEncountersEffects", Effects)
local TSK = Effects.TranslatedStrings

---Creates a TSK for an effect name.
---@param data TextLib_TranslatedString
---@return Library_TranslatedString
local function EffectTSK(data)
    -- Hilarious fuckup while refactoring the whole thing to be translatable. Unfortunate. TODO?
    data.FormatOptions = {
        ---@diagnostic disable-next-line: undefined-field
        FormatArgs = data.FormatArgs
    }
    return Effects:RegisterTranslatedString(data)
end

local Data = {
    Categories = {
        {
            Name = "Violent Strikes",
            ID = "ViolentStrike",
            Effects = {
                {
                    ID = "Ascension_ViolentStrike_ACT_BasicOnHit",
                    Name = EffectTSK({
                        Handle = "hb7ca1bb4g9911g4d08gafabgdbc9f8762c5e",
                        Text = "%s: Conqueror",
                        FormatArgs = {{Text = TSK.Keyword_ViolentStrike_Activator}},
                    }),
                    Description = EffectTSK({
                        Handle = "h3158d4d2ga92ag4d54gab02g7b3c80050494",
                        Text = "15% chance per hit",
                    }),
                    SpecialLogic = "Ascension_ViolentStrike_ACT_BasicOnHit",
                    Keyword = {Keyword = "ViolentStrike", BoonType = "Activator",},
                },
                {
                    ID = "Ascension_ViolentStrike_ACT_DamageAtOnce",
                    Name = EffectTSK({
                        Handle = "h2f769914gfc48g478bg8334g1658c61893a2",
                        Text = "%s: Archer",
                        FormatArgs = {{Text = TSK.Keyword_ViolentStrike_Activator}},
                    }),
                    Description = EffectTSK({
                        Handle = "h280fc43cgcdfag4a57g83a5gfecd9e6d376c",
                        Text = "After dealing damage exceeding 20% of total Vitality",
                    }),
                    Cost = 5,
                    SpecialLogic = "Ascension_ViolentStrike_ACT_DamageAtOnce",
                    Keyword = {Keyword = "ViolentStrike", BoonType = "Activator",},
                },
                {
                    ID = "Ascension_ViolentStrike_ACT_0AP",
                    Name = EffectTSK({
                        Handle = "hd606a082g2984g4b6bg976eg155d5613b92a",
                        Text = "%s: Hatchet",
                        FormatArgs = {{Text = TSK.Keyword_ViolentStrike_Activator}},
                    }),
                    Description = EffectTSK({
                        Handle = "h590e55ddgad50g43bfga1f2g1049cb7ac792",
                        Text = "After reaching 0 AP",
                    }),
                    Cost = 5,
                    SpecialLogic = "Ascension_ViolentStrike_ACT_0AP",
                    Keyword = {Keyword = "ViolentStrike", BoonType = "Activator",},
                },
                {
                    ID = "Ascension_ViolentStrike_MUTA_VitalityVoidACT",
                    Name = EffectTSK({
                        Handle = "h96b347e8g8044g4f64ga0f5gad88b6e6f204",
                        Text = "%s: Conqueror",
                        FormatArgs = {{Text = TSK.Keyword_ViolentStrike_Mutator}},
                    }),
                    Description = EffectTSK({
                        Handle = "h4ffcae73g362bg484bgadfege805c6835061",
                        Text = "Vitality Void when performing Violent Strike",
                    }),
                    Weight = 0,
                    Cost = 20,
                    SpecialLogic = "Ascension_ViolentStrike_MUTA_VitalityVoidACT",
                    Keyword = {Keyword = "ViolentStrike", BoonType = "Mutator",},
                },
                {
                    ID = "Ascension_ViolentStrike_MUTA_Terrified2",
                    Name = EffectTSK({
                        Handle = "hf6eb07b9ga55cg4954g97c3gad49be926b0a",
                        Text = "%s: Hatchet",
                        FormatArgs = {{Text = TSK.Keyword_ViolentStrike_Mutator}},
                    }),
                    Description = EffectTSK({
                        Handle = "heeee531cgacb1g4226g9d49g4f2d87eed723",
                        Text = "Apply up to Terrified II",
                    }),
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
                    ID = "Ascension_Elementalist_ACT_FireEarth_AllySkills",
                    Name = EffectTSK({
                        Handle = "h14e4e4e2gbfe2g49ecg8854g6271530bf5be",
                        Text = "%s: Falcon",
                        FormatArgs = {{Text = TSK.Keyword_Elementalist_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h36275f5ag2a80g4f6dgb19dg79184fc09839",
                        Text = "On Geomancer/Pyromancer",
                    }),
                    Cost = 12,
                    SpecialLogic = "Ascension_Elementalist_ACT_FireEarth_AllySkills",
                    Keyword = {Keyword = "Elementalist", BoonType = "Activator"},
                },
                {
                    ID = "Ascension_Elementalist_ACT_PredatorOrVuln3",
                    Name = EffectTSK({
                        Handle = "h96ccf541g6010g4649g8365gc4c6ec771ba8",
                        Text = "%s: Arcanist",
                        FormatArgs = {{Text = TSK.Keyword_Elementalist_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h97e3c6feg4307g498cgb694gbfaa21a51800",
                        Text = "On Predator/Vulnerable III",
                    }),
                    Cost = 5,
                    SpecialLogic = "Ascension_Elementalist_ACT_PredatorOrVuln3",
                    Keyword = {Keyword = "Elementalist", BoonType = "Activator"},
                },
                {
                    ID = "Ascension_Elementalist_ACT_AirWater_AllySkills",
                    Name = EffectTSK({
                        Handle = "h081c501bg1799g4484g805cg32d128aa0f90",
                        Text = "%s: Hind",
                        FormatArgs = {{Text = TSK.Keyword_Elementalist_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "hf5330d15gde4bg4ae2g93f6g2bd57bc4cede",
                        Text = "On Aerotheurge/Hydrosophist Skill",
                    }),
                    Cost = 12,
                    SpecialLogic = "Ascension_Elementalist_ACT_AirWater_AllySkills",
                    Keyword = {Keyword = "Elementalist", BoonType = "Activator"},
                },
                {
                    ID = "Ascension_Elementalist_ACT_AirWater_AllySkills_MK2_HuntsWar",
                    Name = EffectTSK({
                        Handle = "hd356a0ecg68aeg41e6g85deg6a4684a644da",
                        Text = "%s: Pegasus",
                        FormatArgs = {{Text = TSK.Keyword_Elementalist_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "hfd888170g85c7g4345g9530g5b40bfad71f1",
                        Text = "On Huntsman/Warfare Skill",
                    }),
                    Cost = 12,
                    SpecialLogic = "Ascension_Elementalist_ACT_AirWater_AllySkills_MK2_HuntsWar",
                    Keyword = {Keyword = "Elementalist", BoonType = "Activator"},
                },
                {
                    ID = "Ascension_Elementalist_MUTA_FireEarth_NonTieredStatuses",
                    Name = EffectTSK({
                        Handle = "h63ae98ebg0fcbg49fbg877dg957622cdf46c",
                        Text = "%s: Falcon",
                        FormatArgs = {{Text = TSK.Keyword_Elementalist_Mutator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h6b97d443g4ae2g45f1gac2dgaecddd543ca1",
                        Text = "On Calcifying/Scorched",
                    }),
                    SpecialLogic = "Ascension_Elementalist_MUTA_FireEarth_NonTieredStatuses",
                    Keyword = {Keyword = "Elementalist", BoonType = "Mutator"},
                },
                {
                    ID = "Ascension_ViolentStrike_ACT_ElemStacks",
                    Name = EffectTSK({
                        Handle = "hc494217ag176ag48d8g9e98g3032373a316d",
                        Text = "%s: Arcanist",
                        FormatArgs = {{Text = TSK.Keyword_Elementalist_Mutator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h61bd66f1g96dag4036gb7deg2a0944c69d5b",
                        Text = "Violent Strike when 2 or more stacks",
                    }),
                    SpecialLogic = "Ascension_ViolentStrike_ACT_ElemStacks",
                    Keyword = {Keyword = "Elementalist", BoonType = "Mutator"},
                },
                {
                    ID = "Ascension_Elementalist_MUTA_FeedbackPowerEffect",
                    Name = EffectTSK({
                        Handle = "h98db5bdfgc091g4214gbea8g9c637abe8464",
                        Text = "%s: Kraken",
                        FormatArgs = {{Text = TSK.Keyword_Elementalist_Mutator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h2f961697gc8bcg40a0ga032g2bba5e498778",
                        Text = "+10% Damage from Power per stack",
                    }),
                    Cost = 15,
                    SpecialLogic = "Ascension_Elementalist_MUTA_FeedbackPowerEffect",
                    Keyword = {Keyword = "Elementalist", BoonType = "Mutator"},
                },
                {
                    ID = "Ascension_Elementalist_MUTA_FeedbackCrit",
                    Name = EffectTSK({
                        Handle = "hd1aec727g0761g4a05g85c4gdbdb777fb7e6",
                        Text = "%s: Scorpion",
                        FormatArgs = {{Text = TSK.Keyword_Elementalist_Mutator}}
                    }),
                    Description = EffectTSK({
                        Handle = "hcd5b9f12gedb3g403bg8e7bge411ec7d5c70",
                        Text = "+5% Crit Chance per stack",
                    }),
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
                    ID = "Ascension_Predator_ACT_BHStacks",
                    Name = EffectTSK({
                        Handle = "hcef1a00bg41a1g4afagade1gca98b9906f14",
                        Text = "%s: Falcon",
                        FormatArgs = {{Text = TSK.Keyword_Predator_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h8c210f40gc030g4895g8015gc60256ccc7d8",
                        Text = "After reaching 7 stacks of either Battered or Harried",
                    }),
                    SpecialLogic = "Ascension_Predator_ACT_BHStacks",
                    Keyword = {Keyword = "Predator", BoonType = "Activator"},
                },
                {
                    ID = "Ascension_Predator_ACT_Terrified",
                    Name = EffectTSK({
                        Handle = "h3cc80872g92d7g4428gb272gdb1c7f86c255",
                        Text = "%s: Manticore",
                        FormatArgs = {{Text = TSK.Keyword_Predator_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h11cf3af7gc893g4c8cga65cg2413ab490b6e",
                        Text = "On Terrified",
                    }),
                    SpecialLogic = "Ascension_Predator_ACT_Terrified",
                    Keyword = {Keyword = "Predator", BoonType = "Activator"},
                },
                {
                    ID = "Ascension_Predator_ACT_Dazzled",
                    Name = EffectTSK({
                        Handle = "hc608e22eg5881g4020ga070g8e820c8ea451",
                        Text = "%s: Tiger",
                        FormatArgs = {{Text = TSK.Keyword_Predator_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h625ba67fg0f0eg42e2g8250gd9578153f662",
                        Text = "On Dazzled",
                    }),
                    SpecialLogic = "Ascension_Predator_ACT_Dazzled",
                    Keyword = {Keyword = "Predator", BoonType = "Activator"},
                },
                {
                    ID = "Ascension_Predator_MUTA_Hemorrhage",
                    Name = EffectTSK({
                        Handle = "h0f95f877gfddfg459eg8113geb4dd8f316a8",
                        Text = "%s: Tiger",
                        FormatArgs = {{Text = TSK.Keyword_Predator_Mutator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h9803bbbcg2bfbg4a05gb06bgc995e48590f6",
                        Text = "Apply Hemorrhage if target is Bleeding",
                    }),
                    SpecialLogic = "Ascension_Predator_MUTA_Hemorrhage",
                    Keyword = {Keyword = "Predator", BoonType = "Mutator"},
                },
                {
                    ID = "Ascension_Predator_MUTA_Slowed2",
                    Name = EffectTSK({
                        Handle = "h4febc429g2bf4g4307g9a87g358cdeb603ea",
                        Text = "%s: Falcon",
                        FormatArgs = {{Text = TSK.Keyword_Predator_Mutator}}
                    }),
                    Description = EffectTSK({
                        Handle = "he69bf5c8g91b4g4210gb48cg34e1824c00d1",
                        Text = "Apply up to Slowed II",
                    }),
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
                    ID = "Ascension_Centurion_ACT_MissedByAttack",
                    Name = EffectTSK({
                        Handle = "h61c8dac4ge489g4a0dga7e6gd42e7c0f8ddb",
                        Text = "%s: Key",
                        FormatArgs = {{Text = TSK.Keyword_Centurion_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "he7fe3b89g3a58g4478ga9b1g28be15da9498",
                        Text = "After dodging an attack",
                    }),
                    SpecialLogic = "Ascension_Centurion_ACT_MissedByAttack",
                    Keyword = {Keyword = "Centurion", BoonType = "Activator"},
                },
                {
                    ID = "Ascension_Centurion_ACT_HitAlly",
                    Name = EffectTSK({
                        Handle = "h1b930e38g1f4bg430bgb9f9g368f666c6db5",
                        Text = "%s: Guardsmen",
                        FormatArgs = {{Text = TSK.Keyword_Centurion_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h06dc2c7eg034ag44a2gb98cga40573eec901",
                        Text = "When an ally is hit",
                    }),
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
                    ID = "Ascension_Celestial_ACT_Offensive",
                    Name = EffectTSK({
                        Handle = "h1f1e612cg81e7g42f9g9f0dge68da29d7901",
                        Text = "%s: Champion",
                        FormatArgs = {{Text = TSK.Keyword_Celestial_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h2b630d44gbb94g4336g8124gf510cedcb449",
                        Text = "On Vulnerable III",
                    }),
                    SpecialLogic = "Ascension_Celestial_ACT_Offensive",
                    Keyword = {Keyword = "Celestial", BoonType = "Activator"},
                },
                {
                    ID = "Ascension_Celestial_ACT_AllySource",
                    Name = EffectTSK({
                        Handle = "h71b98ee8ga15cg4cabgab1eg78d809fb0bda",
                        Text = "%s: Hind",
                        FormatArgs = {{Text = TSK.Keyword_Celestial_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "hb4265152g8d4ag40cbg8fadg6f7b6abd0c77",
                        Text = "When an ally with less than 50% Vitality spends Source",
                    }),
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
                    ID = "Ascension_VitalityVoid_ACT_CombatDeath",
                    Name = EffectTSK({
                        Handle = "h6dadd464g7e6eg4f1fg9ddagd165c29bc648",
                        Text = "%s: Death",
                        FormatArgs = {{Text = TSK.Keyword_VitalityVoid_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "hc685e036gefe7g464fg97fdg56420f6a2949",
                        Text = "When a non-summon character dies",
                    }),
                    SpecialLogic = "Ascension_VitalityVoid_ACT_CombatDeath",
                    Keyword = {Keyword = "VitalityVoid", BoonType = "Activator"},
                },
                {
                    ID = "Ascension_VitalityVoid_ACT_SourceSpent",
                    Name = EffectTSK({
                        Handle = "h136f12f3g44abg4ff1gb98dg881a8ba70ba1",
                        Text = "%s: Fly",
                        FormatArgs = {{Text = TSK.Keyword_VitalityVoid_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h415eaa70gb07fg4759g9ee8gdf426115da3f",
                        Text = "For each Source Point spent",
                    }),
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
                    ID = "Ascension_Ward_ACT_MK2_CritByEnemy",
                    Name = EffectTSK({
                        Handle = "h158030fbg06bbg41a2gb3c2g12aa909a883d",
                        Text = "%s: Gryphon",
                        FormatArgs = {{Text = TSK.Keyword_Ward_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "hddf2dce9g6cf0g4300g88b5gbaf0555d61b2",
                        Text = "When being Critically Hit",
                    }),
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
                    ID = "Ascension_Presence_MUTA_MK2_VitRegen",
                    Name = EffectTSK({
                        Handle = "hd73c51b6g059cg41c3g8c07g891c74834f8c",
                        Text = "Presence Mutators",
                    }),
                    Description = EffectTSK({
                        Handle = "hb33f449eg7c79g403aga592gab78dc3cd532",
                        Text = "Grants missing Vitality regeneration, damage and resistances",
                    }),
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
                    ID = "Ascension_Wither_ACT_Calcifying",
                    Name = EffectTSK({
                        Handle = "ha948c2f6gc504g4317ga7f0g0afacddef535",
                        Text = "%s: Basilisk",
                        FormatArgs = {{Text = TSK.Keyword_Wither_Activator}}
                    }),
                    Description = EffectTSK({
                        Handle = "h3de98ca0gc819g459ag8d96g60f9c0950790",
                        Text = "On Calcifying",
                    }),
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
                    ID = "Ascension_Skill_BoneshapedCrusher",
                    Name = EffectTSK({
                        Handle = "h48374cacg3393g41d0g8a75gfc04db881e13",
                        Text = "Boneshaped Crusher",
                    }),
                    Description = EffectTSK({
                        Handle = "hfd0211e7g675cg4c8ag91ebge0b25d23e97f",
                        Text = "Character gains the Summon Boneshaped Crusher spell",
                    }),
                    Weight = 0,
                    Cost = 25,
                    SpecialLogic = "Ascension_Skill_BoneshapedCrusher",
                },
                {
                    ID = "Ascension_MageFin",
                    Name = EffectTSK({
                        Handle = "h33316445g8084g4ddbga2c7g81d73403f66d",
                        Text = "Spellcaster Finesse",
                    }),
                    Description = EffectTSK({
                        Handle = "h7bd0bfa2g0555g41e1gbb63gc57e456c3513",
                        Text = "Finesse's AP recovery works on magic spells",
                    }),
                    SpecialLogic = "Ascension_MageFin",
                },
            },
        },
    },
}
Effects.Categories = Data.Categories

-- Set context descriptions for all TSKs
for _,category in ipairs(Effects.Categories) do
    for _,effect in pairs(category.Effects) do
        if type(effect.Name) == "table" and effect.Name.Text:find("%s", nil, true) then
            effect.Name.ContextDescription = Text.Resolve(effect.Name)
        end
        if type(effect.Description) == "table" then
            effect.Description.ContextDescription = Text.Resolve(effect.Name) .. " description"
        end
    end
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Generate Artifact options and register categories
Ext.Events.SessionLoading:Subscribe(function (_)
    local artifactLabel = Text.CommonStrings.Artifact:GetString()
    for id,artifact in pairs(Artifact.ARTIFACTS) do
        if id ~= "Artifact_Deck" then
            local description = artifact:GetDescription()
            local keyword = nil ---@type EpicEnemiesKeywordData

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

            ---@type EpicEnemiesExtendedEffect
            local effect = {
                ID = id,
                Name = Text.Format("%s: %s", {FormatArgs = {
                    artifactLabel,
                    artifact:GetName()
                }}),
                DefaultCost = 15,
                DefaultWeight = artifactWeights[id] or 0,
                Description = description,
                Artifact = artifact.ID,
                Keyword = keyword,
            }
            table.insert(ArtifactsCategory.Effects, effect)
        end
    end
    table.sort(ArtifactsCategory.Effects, function(a, b) return a.Name < b.Name end)

    -- Initialize effects
    for _,category in pairs(Effects.Categories) do
        EpicEnemies.RegisterEffectCategory(category)
    end
end)

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
    -- Apply the forced effects to all initialized characters.
    EpicEnemies.Events.CharacterInitialized:Subscribe(function(ev)
        EpicEnemies.ApplyEffect(ev.Character, forcedEffect)
    end)
end
