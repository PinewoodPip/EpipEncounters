
---@type EpicEnemiesEffectsCategory[]
local Data = {
    {
        Name = "Violent Strikes",
        ID = "ViolentStrike",
        Effects = {
            {
                Name = "Violent Strikes Activator: Conqueror",
                ID = "Ascension_ViolentStrike_ACT_BasicOnHit",
                Description = "15% chance per hit",
                Cost = 10,
                Weight = 10,
                SpecialLogic = "Ascension_ViolentStrike_ACT_BasicOnHit",
                Keyword = {Keyword = "ViolentStrike", BoonType = "Activator",},
            },
            {
                Name = "Violent Strikes Activator: Archer",
                ID = "Ascension_ViolentStrike_ACT_DamageAtOnce",
                Description = "After dealing damage exceeding 20% of total Vitality",
                SpecialLogic = "Ascension_ViolentStrike_ACT_DamageAtOnce",
                Keyword = {Keyword = "ViolentStrike", BoonType = "Activator",},
            },
            {
                Name = "Violent Strikes Activator: Hatchet",
                ID = "Ascension_ViolentStrike_ACT_0AP",
                Description = "After reaching 0 AP",
                SpecialLogic = "Ascension_ViolentStrike_ACT_0AP",
                Keyword = {Keyword = "ViolentStrike", BoonType = "Activator",},
            },
            {
                Name = "Violent Strikes Mutator: Conqueror",
                ID = "Ascension_ViolentStrike_MUTA_VitalityVoidACT",
                Description = "Vitality Void when performing Violent Strike",
                SpecialLogic = "Ascension_ViolentStrike_MUTA_VitalityVoidACT",
                Keyword = {Keyword = "ViolentStrike", BoonType = "Mutator",},
            },
            {
                Name = "Violent Strikes Mutator: Hatchet",
                ID = "Ascension_ViolentStrike_MUTA_Terrified2",
                Description = "Apply up to Terrified II",
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
                SpecialLogic = "Ascension_Elementalist_ACT_FireEarth_AllySkills",
                Keyword = {Keyword = "Elementalist", BoonType = "Activator"},
            },
            {
                Name = "Elementalist Activator: Arcanist",
                ID = "Ascension_Elementalist_ACT_PredatorOrVuln3",
                Description = "On Predator/Vulnerable III",
                SpecialLogic = "Ascension_Elementalist_ACT_PredatorOrVuln3",
                Keyword = {Keyword = "Elementalist", BoonType = "Activator"},
            },
        },
    },
    {
        Name = "Artifacts",
        ID = "Artifacts",
        Effects = {
            {
                Name = "Artifact: Impetus",
                ID = "Artifact_Impetus",
                Description = "When you Haste an enemy, apply Impetus to them for X turns, where X is the duration of Hasted; when an enemy you can see becomes Hasted, do the same as a 1 AP reaction. Impetus deals Air damage, similar to Ruptured Tendons, when the afflicted character moves",
                Artifact = "Artifact_Impetus",
            },
        },
    },
    {
        Name = "TEST",
        ID = "TestEffects",
        Effects = {
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
                ---@type EpicEnemiesExtendedStat[]
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
}

---@class EpicEnemiesExtendedStat
---@field StatID string The ID of the ExtendedStat.
---@field Amount number
---@field Property1 string
---@field Property2 string
---@field Property3 string

local EpicEnemies = {
    ---@type table<string, EpicEnemiesEffect>
    EFFECTS = {},
    ---@type EpicEnemiesEffectsCategory[]
    CATEGORIES = {},
    INITIALIZED_TAG = "PIP_EpicEnemy",
    Events = {
        
    },
    Hooks = {},
}

if Ext.IsServer() then
    ---@type EpicEnemies_Event_EffectApplied
    EpicEnemies.Events.EffectApplied = {}
    ---@type EpicEnemies_Hook_IsEligible
    EpicEnemies.Hooks.IsEligible = {}
    ---@type EpicEnemies_Event_EffectRemoved
    EpicEnemies.Events.EffectRemoved = {}
    ---@type EpicEnemies_Hook_IsEffectApplicable
    EpicEnemies.Hooks.IsEffectApplicable = {}
    ---@type EpicEnemies_Event_EffectActivated
    EpicEnemies.Events.EffectActivated = {}
    ---@type EpicEnemies_Event_EffectDeactivated
    EpicEnemies.Events.EffectDeactivated = {}
    ---@type EpicEnemies_Hook_CanActivateEffect
    EpicEnemies.Hooks.CanActivateEffect = {}
end

Epip.AddFeature("EpicEnemies", "EpicEnemies", EpicEnemies)
Epip.Features.EpicEnemies = EpicEnemies

---@class EpicEnemiesActivationCondition
---@field Type string
---@field MaxActivations integer

local _EpicEnemiesActivationCondition = {
    Type = "EffectApplied",
    MaxActivations = 1,
}

---@class EpicEnemiesEffect
---@field ID string
---@field Name string
---@field Description string
---@field Cost integer
---@field Weight integer
---@field DefaultWeight integer
---@field DefaultCost integer
---@field SpecialLogic? string Special logic to grant when the effect is rolled.
---@field Artifact? string Artifact power to grant when the effect is rolled.
---@field Keyword? EpicEnemiesKeywordData
---@field Summon? GUID
---@field ActivationCondition EpicEnemiesActivationCondition

---@class EpicEnemiesKeywordData
---@field Keyword Keyword
---@field BoonType KeywordBoonType

---@class EpicEnemiesEffectsCategory
---@field Name string
---@field ID string
---@field Effects string[]|EpicEnemiesEffect[] Can be an array of EpicEnemiesEffect while calling the register method. Will be turned into an ID array afterwards.

---@type EpicEnemiesEffect
_EpicEnemiesEffect = {}

---Get the cost of an effect.
function _EpicEnemiesEffect:GetCost()
    local cost = self.DefaultCost or self.Cost

    -- if Ext.IsClient() then
    --     cost = Client.UI.OptionsSettings.GetOptionValue("EpicEnemies", self.ID)
    --     print("client: " .. cost)
    -- else
    --     cost = Epip.Features.ServerSettings.GetValue("EpicEnemies", self.ID)
    --     print("server: " .. cost)
    -- end

    return cost
end

function _EpicEnemiesEffect:GetWeight()
    local weight = self.DefaultWeight or self.Weight

    if Ext.IsClient() then
        weight = Client.UI.OptionsSettings.GetOptionValue("EpicEnemies", self.ID)
    else
        weight = Epip.Features.ServerSettings.GetValue("EpicEnemies", self.ID)
    end

    return weight
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char Character
function EpicEnemies.IsInitialized(char)
    return char:HasTag(EpicEnemies.INITIALIZED_TAG)
end

---@param id string
---@return EpicEnemiesEffect
function EpicEnemies.GetEffectData(id)
    return EpicEnemies.EFFECTS[id]
end

---@param category EpicEnemiesEffectsCategory
function EpicEnemies.RegisterEffectCategory(category)
    table.insert(EpicEnemies.CATEGORIES, category)

    for i,effect in ipairs(category.Effects) do
        if type(effect) == "table" then
            EpicEnemies.RegisterEffect(effect.ID, effect)
            category.Effects[i] = effect.ID
        end
    end
end

---@param id string
---@param effect EpicEnemiesEffect
function EpicEnemies.RegisterEffect(id, effect)
    -- Shorthand initializers for default values
    if effect.Cost then effect.DefaultCost = effect.Cost end
    if effect.Weight then effect.DefaultWeight = effect.Weight end

    effect.Cost = nil -- TODO remove - wtf?
    effect.Weight = nil
    effect.ID = id
    
    if not effect.ActivationCondition then effect.ActivationCondition = {} end
    Inherit(effect.ActivationCondition, _EpicEnemiesActivationCondition)

    if not effect.DefaultCost then effect.DefaultCost = 10 end
    if not effect.DefaultWeight then effect.DefaultWeight = 10 end

    setmetatable(effect, {__index = _EpicEnemiesEffect})

    EpicEnemies.EFFECTS[id] = effect
end

---@param effect EpicEnemiesEffect
function EpicEnemies.GenerateOptionData(effect)
    ---@type OptionsSettingsOption
    local option = {
        ID = effect.ID,
        Type = "Slider",
        ServerOnly = true,
        SaveOnServer = true,
        Interval = 1,
        MinAmount = 0,
        MaxAmount = 100,
        VisibleAtTopLevel = false,
        HideNumbers = false,
        DefaultValue = effect.DefaultWeight,
        Label = effect.Name,
        Tooltip = effect.Description,
    }

    return option
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Initialize effects
for i,category in pairs(Data) do
    EpicEnemies.RegisterEffectCategory(category)
end