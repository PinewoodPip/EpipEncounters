
Stats = {
    STATS_OBJECT_TYPES = {
        Boost = true,
        Armor = true,
        Weapon = true,
        SkillData = true,
        Object = true,
        Character = true,
        Shield = true,
        StatusData = true,
        Potion = true,
    },

    ---@type table<GUID, table<string, number>> Default values, per mod.
    EXTRA_DATA_DEFAULT_VALUES = {
        [Mod.GUIDS.EE_CORE] = {
            CleaveRangeOverride = 125.0,
            ArmorAfterHitCooldown = -7.0,
            SavethrowHighChance = 50.0,
            TalentViolentMagicCriticalChancePercent = 100.0,
            DodgingBoostFromAttribute = 0.005,
            CharacterWeightLight = 40000.0,
            TalentCombatAbilityPointsBonus = 3.0,
            TalentHumanCriticalMultiplier = 5.0,
            WandUsesMax = 10.0,
            FirstPriceLeapLevel = 9.0,
            DeflectProjectileRange = 0.0,
            CharacterBaseMemoryCapacity = 3.0,
            LoneWolfMaxAPBonus = 4.0,
            ChanceToSetStatusOnContact = 100.0,
            GMItemResistanceMax = 1000.0,
            PoisonedFoodDamageRange = 10.0,
            ArmorRegenTimer = 0.01,
            ExpectedConGrowthForArmorCalculation = 1.0,
            SkillAbilitySummonsStatsPerPoint = 4.0,
            SurfaceDurationBlessedCursed = 12.0,
            CriticalBonusFromWits = 0.0,
            CharacterWeightHeavy = 120000.0,
            AbilityPerseveranceArmorPerPoint = 0.0,
            ExpectedDamageBoostFromWeaponAbilityPerLevel = 0.025,
            SavethrowBelowLowPenalty = 5.0,
            PickpocketWeightPerPoint = 2000.0,
            PickpocketGoldValuePerPoint = 63.0,
            WeaponWeightHeavy = 6000.0,
            PoisonedFoodDamage = 1.0,
            LifestealFromReflectionModifier = 0.0,
            CombatAbilityCritMultiplierBonus = 1.5,
            TalentPointPerLevels = 5.0,
            AbilityMagicArmorBonusPerPoint = 2.0,
            HighGroundMeleeRange = 1.0,
            CombatAbilityCap = 10.0,
            AbilityVitalityBonusMax = 3.0,
            CivilPointOffset = 2.0,
            SkillAbilityPoisonAndEarthDamageBoostPerPoint = 0.0,
            ArmorRegenPercentageGrowth = 100.0,
            CivilAbilityCap = 5.0,
            ArmorRingPercentage = 0.08,
            MagicArmourBoostFromAttribute = 0.0,
            MagicArmorRegenTimer = 0.01,
            SurfaceDurationFireIgniteOverride = 12.0,
            WeaponAccuracyPenaltyPerLevel = -20.0,
            HighGroundBaseDamageBonus = 0.1,
            RangeBoostedGlobalCap = 30.0,
            CombatAbilityDodgingBonus = 2.0,
            DamageBoostFromAttribute = 0.0,
            CarryWeightBase = 0.0,
            TalentSneakingAPCost = 1.0,
            LeadershipDodgingBonus = 2.0,
            WeaponWeightMedium = 3000.0,
            SoftLevelCap = 30.0,
            TalentHumanCriticalChance = 5.0,
            TorturerDamageStatusTurnIncrease = 0.0,
            HighGroundThreshold = 2.4,
            TeleportUnchainDistance = 50.0,
            LoneWolfArmorBoostPercentage = 0.0,
            StatusDefaultDistancePerDamage = 0.75,
            LivingArmorHealPercentage = 35.0,
            TraderDroppedItemsCap = 5.0,
            PhysicalArmourBoostFromAttribute = 0.0,
            TraderDroppedItemsPercentage = 51.0,
            PoisonedFoodDamageMultiplier = 40.0,
            TalentResurrectExtraHealthPercent = 10.0,
            SkillCombustionRadius = 3.0,
            SkillAbilityHighGroundBonusPerPoint = 0.0,
            UnstableDamagePercentage = 50.0,
            MonsterDamageBoostPerLevel = 0.025,
            SpiritVisionFallbackRadius = 10.0,
            BlindRangePenalty = 3.0,
            SurfaceDurationFromHitFloorReaction = 18.0,
            ArmorFeetPercentage = 0.15,
            TraderDonationsRequiredAttitude = -45.0,
            LoneWolfMagicArmorBoostPercentage = 0.0,
            TalentPerfectionistAccuracyBonus = 10.0,
            LoneWolfAPBonus = 4.0,
            SkillAbilityVitalityRestoredPerPoint = 3.0,
            LevelCap = 35.0,
            AttributeBaseValue = 10.0,
            GhostLifeTime = 3.0,
            PickpocketExperienceLevelsPerPoint = 4.0,
            ArmorHeadPercentage = 0.15,
            PriceBarterCoefficient = 0.3,
            ArmorHandsPercentage = 0.15,
            SecondVitalityLeapLevel = 997.0,
            LeadershipAllResBonus = 2.0,
            SkillAbilityCritMultiplierPerPoint = 0.0,
            GMItemArmorMax = 999999.0,
            PriceModClassicDifficulty = 3.5,
            TalentRagerPercentage = 70.0,
            AbilityPersuasionBonusPerPoint = 4.0,
            GMItemArmorMin = -999999.0,
            MagicArmorAfterHitCooldown = -7.0,
            WitsGrowthDamp = 0.5,
            SavethrowLowChance = 15.0,
            GMItemAttributeCap = 100.0,
            GMItemLevelCap = 50.0,
            GMCharacterSPCap = 3.0,
            GMCharacterAPCap = 100.0,
            ArmorShieldPercentage = 0.5,
            SurfaceDurationAfterDecay = 12.0,
            GMCharacterResistanceMin = -1000.0,
            ExpectedDamageBoostFromSkillAbilityPerLevel = 0.015,
            SkillAbilityDamageToMagicArmorPerPoint = 0.0,
            ArmorToVitalityRatio = 0.55,
            SkillAbilityArmorRestoredPerPoint = 3.0,
            CharacterBaseMemoryCapacityGrowth = 0.5,
            GMCharacterAttributeCap = 100.0,
            SkillMemoryCostReductionFromAbility = 0.0,
            AbilityBaseValue = 0.0,
            AttributeLevelGrowth = 2.0,
            AttributeGrowthDamp = 0.7,
            PriceRoundToTenAfterAmount = 1000.0,
            DualWieldingDamagePenalty = 0.5,
            PriceAttitudeCoefficient = 0.005,
            PriceModHardcoreDifficulty = 4.5,
            CharacterWeightMedium = 70000.0,
            FourthPriceLeapGrowth = 1.15,
            ThirdVitalityLeapGrowth = 1.0,
            SurfaceDurationFromCharacterBleeding = 12.0,
            AbilityVitalityBonusBase = 3.0,
            GlobalGoldValueMultiplier = 0.5,
            ThirdPriceLeapGrowth = 1.5,
            SummoningAbilityBonus = 5.0,
            FourthPriceLeapLevel = 18.0,
            SecondPriceLeapLevel = 13.0,
            VitalityBoostFromAttribute = 0.06,
            FreeMovementDistanceWhenAttacking = 1.0,
            FirstPriceLeapGrowth = 1.75,
            PriceGrowth = 1.12,
            AttributeCharCreationBonus = 1.0,
            AbilityPhysArmorBonusBase = 5.0,
            FleeDistance = 0.0,
            DamageToThrownWeightRatio = 0.5,
            GMCharacterArmorCap = 999999.0,
            ExpectedDamageBoostFromAttributePerLevel = 0.065,
            TalentQuickStepPartialApBonus = 1.5,
            ThirdVitalityLeapLevel = 998.0,
            MagicArmorRegenConstGrowth = 1.0,
            HealToDamageRatio = 1.3,
            NumStartingCombatAbilityPoints = 2.0,
            SneakSpeedBoost = -30.0,
            AbilityPhysArmorBonusPerPoint = 2.0,
            SurfaceAbsorbBoostPerTilesCount = 7.0,
            ThirdPriceLeapLevel = 16.0,
            TalentResistDeathVitalityPercentage = 30.0,
            TalentQuestRootedMemoryBonus = 3.0,
            MoveToCarryWeightRatio = 0.75,
            SecondItemTypeShift = 999.0,
            FirstItemTypeShift = 998.0,
            PersuasionAttitudeBonusPerPoint = 5.0,
            SmokeDurationAfterDecay = 0.0,
            CarryWeightPerStr = 10000.0,
            PickpocketRequirementDecreaseFromFinesse = 1.0,
            CombatAbilityReflectionBonus = 5.0,
            ArmorBeltPercentage = 0.1,
            MaximumSummonsInCombat = 4.0,
            AbilityVitalityBonusPerPoint = 1.0,
            VitalityToDamageRatioGrowth = 0.0,
            SkillHeightRangeMultiplier = 1.0,
            FourthVitalityLeapLevel = 99.0,
            TalentCivilAbilityPointsBonus = 1.0,
            TalentMemoryBonus = 8.0,
            CivilAbilityLevelGrowth = 4.0,
            CombatAbilityAccuracyBonus = 5.0,
            FourthVitalityLeapGrowth = 1.0,
            TalentWhatARushThreshold = 70.0,
            TalentPointOffset = 2.0,
            SkillAbilityAirDamageBoostPerPoint = 0.0,
            ArmorAmuletPercentage = 0.12,
            WeaponWeightLight = 1000.0,
            TalentPerfectionistCriticalChanceBonus = 10.0,
            UnstableRadius = 3.0,
            AiCoverProjectileTurnMemory = 2.0,
            AttributeBoostGrowth = 0.75,
            TalentAttributePointsBonus = 5.0,
            SneakingAbilityMovementSpeedPerPoint = 6.0,
            SkillAbilityMovementSpeedPerPoint = 20.0,
            NumStartingCivilAbilityPoints = 2.0,
            SkillAbilityPhysicalDamageBoostPerPoint = 0.0,
            CombatAbilityLevelGrowth = 1.0,
            SecondVitalityLeapGrowth = 1.0,
            VitalityLinearGrowth = 15.0,
            ShieldAPCost = 0.0,
            TalentExecutionerActionPointBonus = 4.0,
            VitalityToDamageRatio = 5.0,
            SkillAbilityFireDamageBoostPerPoint = 0.0,
            IncarnateSummoningLevel = 999.0,
            ArmorUpperBodyPercentage = 0.3,
            SkillAbilityDamageToPhysicalArmorPerPoint = 0.0,
            SecondPriceLeapGrowth = 1.15,
            SavethrowPenaltyCap = -30.0,
            AbilityPhysArmorBonusMax = 5.0,
            LoneWolfVitalityBoostPercentage = 0.0,
            AbilityMagicArmorBonusMax = 5.0,
            VitalityExponentialGrowth = 1.0,
            PriceRoundToFiveAfterAmount = 100.0,
            SkillAbilityWaterDamageBoostPerPoint = 0.0,
            AbilityMagicArmorBonusBase = 5.0,
            SneakDefaultAPCost = 4.0,
            LowGroundBaseDamagePenalty = -0.1,
            HighGroundRangeMultiplier = 1.5,
            PriceModCasualDifficulty = 3.1,
            LeadershipRange = 13.0,
            WeaponAccuracyPenaltyCap = -80.0,
            InitiativeBonusFromWits = 1.0,
            SkillAbilityLifeStealPerPoint = 1.0,
            GMItemResistanceMin = -1000.0,
            FirstVitalityLeapLevel = 996.0,
            CombatAbilityCritBonus = 1.0,
            ArmorLowerBodyPercentage = 0.2,
            CombatAbilityNpcGrowth = 0.1,
            DualWieldingAPPenalty = 4.0,
            LoremasterBonusToMemory = 2.0,
            CharacterAttributePointsPerMemoryCapacity = 1.0,
            VitalityStartingAmount = 10.0,
            GMCharacterResistanceMax = 1000.0,
            CombatAbilityDamageBonus = 3.0,
            MagicArmorRegenPercentageGrowth = 100.0,
            ArmorRegenConstGrowth = 1.0,
            AttributeSoftCap = 40.0,
            FirstVitalityLeapGrowth = 1.0,
            TalentSneakingDamageBonus = 0.0,
        },
        Shared = {
            FirstItemTypeShift = 9,
            SecondItemTypeShift = 16,
            PickpocketGoldValuePerPoint = 200,
            PickpocketWeightPerPoint = 2000,
            PickpocketExperienceLevelsPerPoint = 4,
            PersuasionAttitudeBonusPerPoint = 5,
            WandUsesMax = 10,
            AttributeBaseValue = 10,
            AttributeCharCreationBonus = 1,
            AttributeLevelGrowth = 2,
            AttributeBoostGrowth = 0.75,
            AttributeGrowthDamp = 0.7,
            AttributeSoftCap = 40,
            WitsGrowthDamp = 0.5,
            VitalityStartingAmount = 21,
            VitalityExponentialGrowth = 1.25,
            VitalityLinearGrowth = 9.091,
            VitalityToDamageRatio = 5,
            VitalityToDamageRatioGrowth = 0.2,
            ExpectedDamageBoostFromAttributePerLevel = 0.065,
            ExpectedDamageBoostFromSkillAbilityPerLevel = 0.015,
            ExpectedDamageBoostFromWeaponAbilityPerLevel = 0.025,
            ExpectedConGrowthForArmorCalculation = 1,
            FirstVitalityLeapLevel = 9,
            FirstVitalityLeapGrowth = 1.25,
            SecondVitalityLeapLevel = 13,
            SecondVitalityLeapGrowth = 1.25,
            ThirdVitalityLeapLevel = 16,
            ThirdVitalityLeapGrowth = 1.25,
            FourthVitalityLeapLevel = 18,
            FourthVitalityLeapGrowth = 1.35,
            DamageBoostFromAttribute = 0.05,
            MonsterDamageBoostPerLevel = 0.02,
            PhysicalArmourBoostFromAttribute = 0,
            MagicArmourBoostFromAttribute = 0,
            VitalityBoostFromAttribute = 0.07,
            DodgingBoostFromAttribute = 0,
            HealToDamageRatio = 1.3,
            ArmorToVitalityRatio = 0.55,
            ArmorRegenTimer = 0.01,
            ArmorRegenConstGrowth = 1,
            ArmorRegenPercentageGrowth = 10,
            ArmorAfterHitCooldown = -7,
            MagicArmorRegenTimer = 0.01,
            MagicArmorRegenConstGrowth = 1,
            MagicArmorRegenPercentageGrowth = 10,
            MagicArmorAfterHitCooldown = -7,
            ArmorHeadPercentage = 0.15,
            ArmorUpperBodyPercentage = 0.3,
            ArmorLowerBodyPercentage = 0.2,
            ArmorShieldPercentage = 0.5,
            ArmorHandsPercentage = 0.15,
            ArmorFeetPercentage = 0.15,
            ArmorBeltPercentage = 0.1,
            ArmorAmuletPercentage = 0.12,
            ArmorRingPercentage = 0.08,
            SkillMemoryCostReductionFromAbility = 0,
            CharacterBaseMemoryCapacity = 3,
            CharacterBaseMemoryCapacityGrowth = 0.5,
            CharacterAttributePointsPerMemoryCapacity = 1,
            LoremasterBonusToMemory = 2,
            AbilityBaseValue = 0,
            NumStartingCombatAbilityPoints = 2,
            CombatAbilityCap = 10,
            CombatAbilityLevelGrowth = 1,
            CombatAbilityNpcGrowth = 0.1,
            CombatAbilityDamageBonus = 5,
            CombatAbilityCritBonus = 1,
            CombatAbilityCritMultiplierBonus = 5,
            CombatAbilityAccuracyBonus = 5,
            CombatAbilityDodgingBonus = 1,
            CombatAbilityReflectionBonus = 5,
            LeadershipRange = 8,
            LeadershipDodgingBonus = 2,
            LeadershipAllResBonus = 3,
            NumStartingCivilAbilityPoints = 2,
            CivilAbilityCap = 5,
            CivilAbilityLevelGrowth = 4,
            CivilPointOffset = 2,
            SavethrowLowChance = 15,
            SavethrowHighChance = 50,
            SavethrowBelowLowPenalty = 5,
            SavethrowPenaltyCap = -30,
            CriticalBonusFromWits = 1,
            InitiativeBonusFromWits = 1,
            WeaponAccuracyPenaltyPerLevel = -20,
            WeaponAccuracyPenaltyCap = -80,
            ShieldAPCost = 0,
            CharacterWeightLight = 40000,
            CharacterWeightMedium = 70000,
            CharacterWeightHeavy = 120000,
            WeaponWeightLight = 1000,
            WeaponWeightMedium = 3000,
            WeaponWeightHeavy = 6000,
            HighGroundThreshold = 2.4,
            HighGroundBaseDamageBonus = 0.2,
            HighGroundMeleeRange = 1,
            HighGroundRangeMultiplier = 2.5,
            LowGroundBaseDamagePenalty = -0.1,
            SneakDefaultAPCost = 4,
            SneakSpeedBoost = -30,
            BlindRangePenalty = 3,
            RangeBoostedGlobalCap = 30,
            SurfaceDurationFromHitFloorReaction = 18,
            SurfaceDurationFireIgniteOverride = 12,
            SurfaceDurationFromCharacterBleeding = -1,
            SurfaceDurationBlessedCursed = -1,
            SurfaceDurationAfterDecay = -1,
            SmokeDurationAfterDecay = 6,
            DualWieldingAPPenalty = 2,
            DualWieldingDamagePenalty = 0.5,
            GhostLifeTime = 3,
            ChanceToSetStatusOnContact = 100,
            AbilityPhysArmorBonusBase = 5,
            AbilityPhysArmorBonusPerPoint = 2,
            AbilityPhysArmorBonusMax = 5,
            AbilityMagicArmorBonusBase = 5,
            AbilityMagicArmorBonusPerPoint = 2,
            AbilityMagicArmorBonusMax = 5,
            AbilityVitalityBonusBase = 3,
            AbilityVitalityBonusPerPoint = 1,
            AbilityVitalityBonusMax = 3,
            SkillAbilityDamageToPhysicalArmorPerPoint = 0,
            SkillAbilityDamageToMagicArmorPerPoint = 0,
            SkillAbilityArmorRestoredPerPoint = 5,
            SkillAbilityVitalityRestoredPerPoint = 5,
            SkillAbilityHighGroundBonusPerPoint = 5,
            SkillAbilityFireDamageBoostPerPoint = 5,
            SkillAbilityPoisonAndEarthDamageBoostPerPoint = 5,
            SkillAbilityAirDamageBoostPerPoint = 5,
            SkillAbilityWaterDamageBoostPerPoint = 5,
            SkillAbilityPhysicalDamageBoostPerPoint = 5,
            SkillAbilityLifeStealPerPoint = 10,
            LifestealFromReflectionModifier = 0,
            SkillAbilityCritMultiplierPerPoint = 5,
            SkillAbilityMovementSpeedPerPoint = 30,
            SkillAbilitySummonsStatsPerPoint = 4,
            SneakingAbilityMovementSpeedPerPoint = 6,
            TalentAttributePointsBonus = 2,
            TalentCombatAbilityPointsBonus = 1,
            TalentCivilAbilityPointsBonus = 1,
            TalentMemoryBonus = 3,
            TalentQuestRootedMemoryBonus = 3,
            TalentRagerPercentage = 70,
            SoftLevelCap = 20,
            PickpocketRequirementDecreaseFromFinesse = 1,
            SkillCombustionRadius = 3,
            TalentPerfectionistAccuracyBonus = 10,
            TalentPerfectionistCriticalChanceBonus = 10,
            TalentExecutionerActionPointBonus = 2,
            TalentPointOffset = 2,
            TalentViolentMagicCriticalChancePercent = 100,
            TalentPointPerLevels = 5,
            TalentQuickStepPartialApBonus = 1,
            SkillHeightRangeMultiplier = 1,
            AbilityPersuasionBonusPerPoint = 4,
            FreeMovementDistanceWhenAttacking = 1,
            TalentSneakingDamageBonus = 40,
            MaximumSummonsInCombat = 4,
            SpiritVisionFallbackRadius = 10,
            AbilityPerseveranceArmorPerPoint = 5,
            AiCoverProjectileTurnMemory = 2,
            CarryWeightBase = 0,
            CarryWeightPerStr = 10000,
            MoveToCarryWeightRatio = 0.75,
            TalentResistDeathVitalityPercentage = 20,
            DeflectProjectileRange = 1,
            SummoningAbilityBonus = 10,
            SurfaceAbsorbBoostPerTilesCount = 10,
            TalentWhatARushThreshold = 50,
            IncarnateSummoningLevel = 10,
            CleaveRangeOverride = 125,
            DamageToThrownWeightRatio = 0.5,
            FleeDistance = 13,
            GlobalGoldValueMultiplier = 1,
            PriceGrowth = 1.12,
            FirstPriceLeapLevel = 9,
            FirstPriceLeapGrowth = 1.75,
            SecondPriceLeapLevel = 13,
            SecondPriceLeapGrowth = 1.15,
            ThirdPriceLeapLevel = 16,
            ThirdPriceLeapGrowth = 1.5,
            FourthPriceLeapLevel = 18,
            FourthPriceLeapGrowth = 1.15,
            PriceModCasualDifficulty = 2.1,
            PriceModClassicDifficulty = 2.5,
            PriceModHardcoreDifficulty = 2.7,
            PriceBarterCoefficient = 0.1,
            PriceAttitudeCoefficient = 0.005,
            PriceRoundToFiveAfterAmount = 100,
            PriceRoundToTenAfterAmount = 1000,
            LevelCap = 35,
            GMCharacterAttributeCap = 100,
            GMCharacterArmorCap = 999999,
            GMCharacterResistanceMin = -1000,
            GMCharacterResistanceMax = 1000,
            GMCharacterAPCap = 100,
            GMCharacterSPCap = 3,
            GMItemLevelCap = 50,
            GMItemAttributeCap = 100,
            GMItemArmorMin = -999999,
            GMItemArmorMax = 999999,
            GMItemResistanceMin = -1000,
            GMItemResistanceMax = 1000,
            LoneWolfMaxAPBonus = 2,
            LoneWolfAPBonus = 2,
            LoneWolfMagicArmorBoostPercentage = 60,
            LoneWolfArmorBoostPercentage = 60,
            LoneWolfVitalityBoostPercentage = 30,
            LivingArmorHealPercentage = 35,
            TorturerDamageStatusTurnIncrease = 1,
            UnstableDamagePercentage = 50,
            UnstableRadius = 3,
            TalentResurrectExtraHealthPercent = 10,
            PoisonedFoodDamage = 1,
            PoisonedFoodDamageRange = 10,
            PoisonedFoodDamageMultiplier = 40,
            TraderDroppedItemsPercentage = 51,
            TraderDroppedItemsCap = 5,
            StatusDefaultDistancePerDamage = 0.75,
            TraderDonationsRequiredAttitude = -45,
            TeleportUnchainDistance = 50,
            TalentHumanCriticalMultiplier = 10,
            TalentHumanCriticalChance = 5,
            TalentSneakingAPCost = 1
        },
    },

    ---@type table<string, ExtraDataEntry>
    ExtraData = {
    },
}
Game.Stats = Stats
Epip.InitializeLibrary("Stats", Stats)

---@class ExtraDataEntry
---@field ID string
---@field Name string
---@field Description string

---@class ExtraDataEntry
local _ExtraDataEntry = {}

---@return number
function _ExtraDataEntry:GetValue()
    return Stats.Get("Data", self.ID)
end

---@return string
function _ExtraDataEntry:GetName()
    return self.Name or self.ID
end

---@return string
function _ExtraDataEntry:GetDescription()
    return self.Description or ""
end

---@param mod GUID
---@return number
function _ExtraDataEntry:GetDefaultValue(mod)
    local modData = Stats.EXTRA_DATA_DEFAULT_VALUES[mod]
    local value
    if not modData then
        Stats:LogWarning("Mod " .. mod .. " has no default ExtraData values defined. Using Shared's as a fallback.")

        modData = Stats.EXTRA_DATA_DEFAULT_VALUES.Shared
    end

    value = modData[self.ID]
    if not value then value = Stats.EXTRA_DATA_DEFAULT_VALUES.Shared[self.ID] end

    return value
end

-- Setup ExtraData entries
for key,_ in pairs(Stats.EXTRA_DATA_DEFAULT_VALUES.Shared) do
    local data = Stats.ExtraData[key]

    -- Generate table for ones that do not have any metadata explicitly defined
    if not data then
        data = {Name = Text.SeparatePascalCase(key)}
        Stats.ExtraData[key] = data
    end

    data.ID = key

    Inherit(data, _ExtraDataEntry)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether char meets the requirements for a stat object to be used.
---@param char Character
---@param statID string
---@param isItem boolean
---@param itemSource Item?
---@return boolean
function Stats.MeetsRequirements(char, statID, isItem, itemSource)
    local data = Ext.Stats.Get(statID)
    local stats = char.Stats
    local isEquipment = false
    -- local dynamicStats = char.Stats.DynamicStats

    if isItem and itemSource then
        isEquipment = itemSource.Stats.ItemType ~= ""
    end

    -- Dead chars cannot use skills or items.
    if Game.Character.IsDead(char) then
        return false
    end

    if not data then
        return false
    end

    --- AP cost
    local apCost

    if isEquipment then
        apCost = 1 -- TODO is this affected by extra AP costs?
    elseif itemSource and itemSource.StatsId then
        apCost = Stats.Get("Object", itemSource.StatsId).UseAPCost
    else
        apCost, _ = Game.Math.GetSkillAPCost(data, char.Stats, Ext.Entity.GetAiGrid(), char.Translate, 1)
    end

    apCost = apCost or 0

    -- Consider APCostBoost
    local extraApCost = Stats.CountStat(char.Stats, "APCostBoost")
    if stats.CurrentAP < apCost + extraApCost then
        return false
    end

    -- Muted
    if not isItem and data.IgnoreSilence ~= "Yes" and (data.UseWeaponDamage ~= "Yes" and (data.Requirement == "None" or data.Requirement == "ShieldWeapon")) then
        if Game.Character.IsMuted(char) then
            return false
        end
    end

    -- Disarmed
    if not isItem and (data.Requirement ~= "None" or data.UseWeaponDamage == "Yes") then
        if Game.Character.IsDisarmed(char) then
            return false
        end
    end

    -- Source cost
    if not isItem and data["Magic Cost"] > 0 then
        local mpCost = data["Magic Cost"]

        if char.Stats.MPStart < mpCost or char:GetStatus("SOURCE_MUTED") ~= nil then
            return false
        end
    end

    ---@type EclSkill
    local charSkillData = char.SkillManager.Skills[statID]

    -- Cooldown
    if charSkillData and charSkillData.ActiveCooldown > 0 and not itemSource then
        return false
    end

    local grantedByExternalSource = false or itemSource
    if charSkillData and not itemSource then
        grantedByExternalSource = charSkillData.CauseListSize > 0
    end

    -- Memorization
    if charSkillData and (not charSkillData.IsLearned and not grantedByExternalSource) then
        return false
    end
    
    -- Weapon requirements
    if not isItem and data.Requirement ~= "None" then
        if data.Requirement == "MeleeWeapon" and not Game.Character.HasMeleeWeapon(char) then
            return false
        elseif data.Requirement == "RangedWeapon" and not Character.HasRangedWeapon(char) then
            return false
        elseif data.Requirement == "ShieldWeapon" and not Game.Character.HasShield(char) then
            return false
        elseif data.Requirement == "DaggerWeapon" and not Game.Character.HasDagger(char) then
            return false
        end
    end

    -- Only check other requirements if this spell is natural to the character
    if not grantedByExternalSource then
        -- Requirements
        for _,req in ipairs(data.Requirements) do
            local reqMet = false

            if req.Requirement == "Combat" then
                reqMet = Character.IsInCombat(char)
            elseif req.Requirement == "Tag" then
                reqMet = char:HasTag(req.Param)
            elseif req.Requirement == "Immobile" then
                reqMet = Character.GetMovement(char) <= 0
            else
                if not Stats.MeetsRequirementsINT(char, req) then
                    return false
                else
                    reqMet = true
                end
            end

            if req.Not then
                reqMet = not reqMet
            end

            if not reqMet then
                return false
            end
        end

        -- Memorization requirements
        if not isItem then
            for _,req in ipairs(data.MemorizationRequirements) do
                if not Stats.MeetsRequirementsINT(char, req) then
                    return false
                end
            end
        end
    end

    return true
end

---@alias StatsObjectType "ItemColor"|"Boost"|"Armor"|"Weapon"|"SkillData"|"Object"|"Character"|"Data"|"ItemProgressionNames"|"ItemProgressionVisuals"|"Potion"|"Requirements"|"Shield"|"StatusData"|"CraftingStationsItemComboPreviewData"|"DeltaModifier"|"Equipment"|"ItemCombos"|"ItemTypes"|"ObjectCategoriesItemComboPreviewData"|"SkillSet"|"TreasureGroups"|"TreasureTable"|"DeltaMod"

---@param statType StatsObjectType
---@param id string
---@return unknown
function Stats.Get(statType, id)
    local object

    if Stats.STATS_OBJECT_TYPES[statType] then
        object = Ext.Stats.Get(id, nil, false, false)  
    elseif statType == "ItemColor" then
        object = Ext.Stats.ItemColor.Get(id)
    elseif statType == "DeltaModifier" or statType == "DeltaMod" then
        object = Ext.Stats.DeltaMod.GetLegacy(id, "Armor") or Ext.Stats.DeltaMod.GetLegacy(id, "Weapon") or Ext.Stats.DeltaMod.GetLegacy(id, "Shield")
    elseif statType == "TreasureTable" then
        object = Ext.Stats.TreasureTable.GetLegacy(id)
    elseif statType == "TreasureGroups" then
        object = Ext.Stats.TreasureCategory.GetLegacy(id)
    elseif statType == "Data" then
        object = Ext.ExtraData[id]
    else
        Stats:LogError("Attempted to fetch unsupported stat type: " .. statType)
    end

    return object
end

---@param statType StatsObjectType
---@param data any
function Stats.Update(statType, data, ...)

    if statType == "ItemColor" then
        Ext.Stats.ItemColor.Update(data)
    elseif statType == "DeltaModifier" or statType == "DeltaMod" then
        Ext.Stats.DeltaMod.Update(data)
    elseif statType == "TreasureTable" then
        Ext.Stats.TreasureTable.Update(data)
    -- elseif statType == "TreasureGroups" then
    --     TODO
    elseif statType == "Data" then
        Ext.ExtraData[data] = ...
    else
        Stats:LogError("Attempted to update unsupported stat type: " .. statType)
    end
end

function Stats.CountStat(stats, stat)
    local count = 0
    local dynStats = stats.DynamicStats

    for i=1,#dynStats,1 do
        local dynStat = dynStats[i]
        count = count + dynStat[stat]
    end

    -- Items
    -- for i,slot in ipairs(Data.Game.EQUIP_SLOTS) do
    --     local statItem = stats:GetItemBySlot(slot)

    --     if statItem then
    --         dynStats = statItem.DynamicStats
    --         for i=1,#dynStats,1 do
    --             local dynStat = dynStats[i]
    --             count = count + dynStat[stat]
    --         end
    --     end
    -- end

    return count
end

function Stats.MeetsRequirementsINT(char, req)
    local reqMet = false

    if req.Requirement == "None" then
        reqMet = true
    elseif req.Requirement == "Tag" then
        reqMet = char:HasTag(req.Param)
    elseif type(char.Stats[req.Requirement]) == "boolean" then
        reqMet = char.Stats[req.Requirement]
    else
        local amount = char.Stats[req.Requirement]

        -- Attribute requirements appear bugged at the moment. TODO
        if not Data.Game.ATTRIBUTE_STATS[req.Requirement] then
            reqMet = amount >= req.Param
        else
            reqMet = true
        end
    end

    if req.Not then
        reqMet = not reqMet
    end

    if not reqMet then
        return false
    end

    return true
end