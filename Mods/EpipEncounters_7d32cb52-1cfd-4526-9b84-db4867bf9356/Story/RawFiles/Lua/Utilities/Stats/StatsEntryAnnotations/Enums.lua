
---@meta

---@alias StatsLib_StatsEntryType "StatsLib_StatsEntry_Weapon"|"StatsLib_StatsEntry_Armor"|"StatsLib_StatsEntry_Shield"|"StatsLib_StatsEntry_Character"|"StatsLib_StatsEntry_Object"|"StatsLib_StatsEntry_Crime"|"StatsLib_StatsEntry_Potion"|"StatsLib_StatsEntry_SkillData"|"StatsLib_StatsEntry_StatusData"

---@alias StatsLib_Enum_DamageType "None"|"Physical"|"Piercing"|"Corrosive"|"Magic"|"Chaos"|"Fire"|"Air"|"Water"|"Earth"|"Poison"|"Shadow"

---@alias StatsLib_Enum_Handedness "Any"|1|2

---@alias StatsLib_Enum_WeaponType "None"|"Sword"|"Club"|"Axe"|"Staff"|"Bow"|"Crossbow"|"Spear"|"Knife"|"Wand"|"Arrow"

---@alias StatsLib_Enum_DeathType "None"|"Physical"|"Piercing"|"Arrow"|"DoT"|"Incinerate"|"Acid"|"Electrocution"|"FrozenShatter"|"PetrifiedShatter"|"Explode"

---@alias StatsLib_Enum_ArmorType "None"|"Cloth"|"Leather"|"Mail"|"Plate"|"Robe"

---@alias StatsLib_Enum_AttributeFlags string TODO

---@alias StatsLib_Enum_SurfaceType "None"|"Fire"|"FireBlessed"|"FireCursed"|"FirePurified"|"Water"|"WaterElectrified"|"WaterFrozen"|"WaterBlessed"|"WaterElectrifiedBlessed"|"WaterFrozenBlessed"|"WaterCursed"|"WaterElectrifiedCursed"|"WaterFrozenCursed"|"WaterPurified"|"WaterElectrifiedPurified"|"WaterFrozenPurified"|"Blood"|"BloodElectrified"|"BloodFrozen"|"BloodBlessed"|"BloodElectrifiedBlessed"|"BloodFrozenBlessed"|"BloodCursed"|"BloodElectrifiedCursed"|"BloodFrozenCursed"|"BloodPurified"|"BloodElectrifiedPurified"|"BloodFrozenPurified"|"Poison"|"PoisonBlessed"|"PoisonCursed"|"PoisonPurified"|"Oil"|"OilBlessed"|"OilCursed"|"OilPurified"|"Lava"|"Source"|"Web"|"WebBlessed"|"WebCursed"|"WebPurified"|"Deepwater"|"FireCloud"|"FireCloudBlessed"|"FireCloudCursed"|"FireCloudPurified"|"WaterCloud"|"WaterCloudElectrified"|"WaterCloudBlessed"|"WaterCloudElectrifiedBlessed"|"WaterCloudCursed"|"WaterCloudElectrifiedCursed"|"WaterCloudPurified"|"WaterCloudElectrifiedPurified"|"BloodCloud"|"BloodCloudElectrified"|"BloodCloudBlessed"|"BloodCloudElectrifiedBlessed"|"BloodCloudCursed"|"BloodCloudElectrifiedCursed"|"BloodCloudPurified"|"BloodCloudElectrifiedPurified"|"PoisonCloud"|"PoisonCloudBlessed"|"PoisonCloudCursed"|"PoisonCloudPurified"|"SmokeCloud"|"SmokeCloudBlessed"|"SmokeCloudCursed"|"SmokeCloudPurified"|"ExplosionCloud"|"FrostCloud"|"Deathfog"|"Sentinel"|"ShockwaveCloud"

---@alias StatsLib_Enum_DamageSourceType "BaseLevelDamage"|"AverageLevelDamge"|"MonsterWeaponDamage"|"SourceMaximumVitality"|"SourceMaximumPhysicalArmor"|"SourceMaximumMagicArmor"|"SourceCurrentVitality"|"SourceCurrentPhysicalArmor"|"SourceCurrentMagicArmor"|"SourceShieldPhysicalArmor"|"TargetMaximumVitality"|"TargetMaximumPhysicalArmor"|"TargetMaximumMagicArmor"|"TargetCurrentVitality"|"TargetCurrentPhysicalArmor"|"TargetCurrentMagicArmor"|"TargetCurrentMagicArmor"

---@alias StatsLib_Enum_Ability "None"|"WarriorLore"|"RangerLore"|"RogueLore"|"SingleHanded"|"TwoHanded"|"Reflection"|"Ranged"|"Shield"|"Reflexes"|"PhysicalArmorMastery"|"Sourcery"|"Telekinesis"|"FireSpecialist"|"WaterSpecialist"|"AirSpecialist"|"EarthSpecialist"|"Necromancy"|"Summoning"|"Polymorph"|"Repair"|"Sneaking"|"Pickpocket"|"Thievery"|"Loremaster"|"Crafting"|"Barter"|"Charm"|"Intimidate"|"Reason"|"Persuasion"|"Leadership"|"Luck"|"DualWielding"|"Wand"|"MagicArmorMastery"|"VitalityMastery"|"Perseverance"|"Runecrafting"|"Brewmaster"

---@alias StatsLib_Enum_SkillAbility "None"|"Warrior"|"Ranger"|"Rogue"|"Source"|"Fire"|"Water"|"Air"|"Earth"|"Death"|"Summoning"|"Polymorph"

---@alias StatsLib_StatsEntryField_Requirements table[] TODO

---@alias StatsLib_Enum_SkillRequirement "None"|"MeleeWeapon"|"RangedWeapon"|"StaffWeapon"|"DaggerWeapon"|"ShieldWeapon"|"ArrowWeapon"

---@alias StatsLib_Enum_CastCheckType "None"|"Distance"|"DamageType"|"TargetSurfaceType"

---@alias StatsLib_Enum_SavingThrow "None"|"Burning"|"Frozen"|"Poison"|"KnockDown"|"Mute"|"Stunned"|"Fear"|"Charm"|"Bleeding"|"Crippled"|"Blind"|"Cursed"|"Weak"|"Slowed"|"Diseased"|"InfectiousDiseased"|"Petrified"|"Drunk"|"ShacklesOfPain"|"AggroMarked"|"Remorse"|"DecayingTouch"|"CrawlingInfestation"|"MarkOfDeath"|"Taunted"|"Oiled"|"Soulsap"|"VampiricTouch"|"NullResist"|"DivineLight"|"Drain"|"Sleeping"|"PhysicalArmor"|"MagicArmor"

---@alias StatsLib_Enum_SkillTier "None"|"Starter"|"Novice"|"Adept"|"Master"

---@alias StatsLib_Enum_ProjectileType "None"|"Arrow"|"Grenade"

---@alias StatsLib_Enum_ProjectileDistribution "Random"|"Normal"|"Edge"|"EdgeCenter"

---@alias StatsLib_Enum_AtmosphereType "None"|"Rain"|"Storm"

---@alias StatsLib_Enum_VampirismType "None"|"Vitality"|"ArmorPhysical"|"ArmorMagical"|"ArmorAll"|"Any"

---@alias StatsLib_Enum_HealValueType "FixedValue"|"Percentage"|"Qualifier"|"Shield"|"TargetDependent"|"DamagePercentage"

---@alias StatsLib_Enum_StatusEvent "None"|"OnTurn"|"OnSkillCast"|"OnAttack"|"OnApply"|"OnRemove"|"OnApplyAndTurn"

---@alias StatsLib_Enum_ModifierType "Item"|"Charm"|"Boost"|"Skill"|"Crystal"|"Food"

---@alias StatsLib_Enum_FormatStringColor "White"|"DarkGray"|"Gray"|"LightGray"|"Red"|"Blue"|"DarkBlue"|"LightBlue"|"Green"|"PoisonGreen"|"Yellow"|"Orange"|"Pink"|"Purple"|"Brown"|"Gold"|"Black"|"Normal"|"StoryItem"|"Blackrock"|"Poison"|"Earth"|"Air"|"Water"|"Fire"|"Source"|"Decay"|"Polymorph"|"Ranger"|"Rogue"|"Summoner"|"Void"|"Warrior"|"Special"|"Healing"|"Charm"

---@alias StatsLib_Enum_MaterialType "None"|"Overlay"|"FadingOverlay"|"Replacement"

---@alias StatsLib_Enum_AnimType "None"|"OneHanded"|"TwoHanded"|"Bow"|"DualWield"|"Shield"|"SmallWeapons"|"PoleArms"|"Unarmed"|"CrossBow"|"TwoHanded_Sword"|"Sitting"|"Lying"|"DualWieldSmall"|"Staves"|"Wands"|"DualWieldWands"|"ShieldWands"

---@alias StatsLib_Enum_StepsType "Bare"|"Bone"|"Lizard"|"Leather"|"Metal"|"Zombie"|"Clawed"

---@alias StatsLib_Enum_InventoryTabs "Auto"|"Equipment"|"Consumable"|"Magical"|"Ingredient"|"Keys"|"Misc"|"Hidden"

---@alias StatsLib_Enum_ActPart integer From `0` to `30`

---@alias StatsLib_Enum_Qualifier "None"|integer From `0` to `10`
---@alias StatsLib_Enum_BigQualifier "None"|integer From `0` to `100`
---@alias StatsLib_Enum_PreciseQualifier "None"|integer From `0` to `10` with a step of `0.1`
---@alias StatsLib_Enum_PenaltyQualifier "None"|integer From `-10` to `10`
---@alias StatsLib_Enum_PenaltyPreciseQualifer "None"|number From `-10` to `10` with a step of `0.1`