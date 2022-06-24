import json

# generates a json of keywords as custom stat definitions to be used by the UI lua scripts.
# uses ascension.json and tsk_export.json from the build planner ascension parser script

# well the inclusion of statExtensions complicates the matter quite a lot when it comes to updates. Perhaps we should be checking for nodes rather than speciallogic/stats themselves to save on updates

# obvious thing to do is partial updates. I think the best solution would be to listen for node (de)allocation
# also parse all nodes on system init

ascension = json.load(open("ascension.json", "r"))
tskExport = json.load(open("tsk_export.json", "r", encoding="utf8"))

# generic strings
abeyanceACT = "Basic Activator"
adaptationACT = "Basic Activator"
incarnateChampionACT = "Incarnate Champion"
centurionMissACT = "On Dodge"
wardACT = "Basic Activator"
prosperityACT = "Basic Activator"
purityACT = "Basic Activator"
purityCooldownReduction = "Cooldown Reduction"

statDisplayNames = {
    # elementalist
    "ACT_Elementalist_Ascension_Force_TheFalcon_Node_3_0": "On Geomancer/Pyrokinetic",
    "ACT_Predator_Ascension_Force_TheFalcon_Node_3_1": "On 7 B/H",
    "MUTA_Elementalist_Ascension_Force_TheFalcon_Node_4_0": "Calcifying & Scorched",
    "MUTA_Predator_Ascension_Force_TheFalcon_Node_4_1": "Applies Slowed II",
    "ACT_Paucity_Ascension_Force_TheHatchet_Node_3_0": "On 7+ B/H",
    "ACT_ViolentStrike_Ascension_Force_TheHatchet_Node_3_1": "On 0 AP",
    "MUTA_Paucity_Ascension_Force_TheHatchet_Node_4_0": "Dodge Fatigue Reduction",
    "MUTA_ViolentStrike_Ascension_Force_TheHatchet_Node_4_1": "Applies Acid",
    "MUTA_ViolentStrike_Ascension_Force_TheHatchet_Node_4_2": "Applies Bleeding",
    "MUTA_ViolentStrike_Ascension_Force_TheHatchet_Node_4_3": "Applies Suffocating",
    "MUTA_ViolentStrike_Ascension_Force_TheHatchet_Node_4_4": "Applies Terrified II",
    "ACT_Elementalist_Ascension_Force_TheArcanist_Node_3_0": "On Predator/Vulnerable III",
    "ACT_ViolentStrike_Ascension_Force_TheArcanist_Node_3_1": "On 2+ Elementalist Stacks",
    "MUTA_Elementalist_Ascension_Force_TheArcanist_Node_4_0": "SI1: Elemental Skill Emulation",
    "MUTA_Elementalist_Ascension_Force_TheArcanist_Node_4_1": "Finesse & Power per Stack",
    "MUTA_ViolentStrike_Ascension_Force_TheArcanist_Node_4_2": "Embodiment Damage Scaling",
    "ACT_Paucity_Ascension_Force_TheArcher_Node_3_0": "On 7+ B/H",
    "ACT_ViolentStrike_Ascension_Force_TheArcher_Node_3_1": "On 20%+ Vitality Hit",
    "ACT_Paucity_Ascension_Force_TheArcher_Node_3_2": "On Armor depletion",
    "MUTA_Paucity_Ascension_Force_TheArcher_Node_4_0": "Accuracy, Damage & Initiative",
    "MUTA_ViolentStrike_Ascension_Force_TheArcher_Node_4_1": "Elemental Arrowheads",
    "MUTA_ViolentStrike_Ascension_Force_TheArcher_Node_4_2": "B/H Application",
    "ACT_Paucity_Ascension_Force_TheManticore_Node_3_0": "On &lt;25% Vitality",
    "ACT_Predator_Ascension_Force_TheManticore_Node_3_1": "On Terrified",
    "MUTA_Paucity_Ascension_Force_TheManticore_Node_4_0": "Black Shroud Emulation",
    "MUTA_Paucity_Ascension_Force_TheManticore_Node_4_1": "Dagger Invisiblity",
    "MUTA_Predator_Ascension_Force_TheManticore_Node_4_2": "SI1: Fan of Knives",
    "ACT_Elementalist_Ascension_Force_TheScorpion_Node_2_0": "On Pyrokinetic/Geomancer",
    "ACT_VitalityVoid_Ascension_Force_TheScorpion_Node_2_1": "On &gt;30% Vitality dealt",
    "ACT_Elementalist_Ascension_Force_TheScorpion_Node_2_2": "On Necromancer/Scoundrel",
    "MUTA_Elementalist_Ascension_Force_TheScorpion_Node_3_0": "Critical Chance per Stack",
    "MUTA_VitalityVoid_Ascension_Force_TheScorpion_Node_3_1": "DoT Application",
    "ACT_Predator_Ascension_Force_TheTiger_Node_2_0": "On Dazzled",
    "ACT_Purity_Ascension_Force_TheTiger_Node_2_1": "On &lt;30% Vitality",
    "ACT_Purity_Ascension_Force_TheTiger_Node_2_2": "On enemy death",
    "MUTA_Predator_Ascension_Force_TheTiger_Node_3_0": "Dual-wield Range Increase",
    "MUTA_Predator_Ascension_Force_TheTiger_Node_3_1": "Bleeding & Hemorrhage",
    "MUTA_Purity_Ascension_Force_TheTiger_Node_3_2": "Accuracy, Damage & Restoration",
    "ACT_ViolentStrike_Ascension_Force_TheConqueror_Node_2_1": "On hit",
    "MUTA_Purity_Ascension_Force_TheConqueror_Node_3_0": "AP Recovery",
    "MUTA_ViolentStrike_Ascension_Force_TheConqueror_Node_3_1": "Fin/Str Scaling",
    "MUTA_Purity_Ascension_Force_TheConqueror_Node_4_0": "Source Generation",
    "MUTA_ViolentStrike_Ascension_Force_TheConqueror_Node_4_1": "Vitality Void Activation",
    "ACT_Elementalist_Ascension_Force_TheKraken_Node_2_0": "On Elementalist/Occultist",
    "MUTA_Elementalist_Ascension_Force_TheKraken_Node_2_1": "Basic Attacks (off-hand)",
    "MUTA_Elementalist_Ascension_Force_TheKraken_Node_3_0": "Power per Stack",
    "MUTA_VitalityVoid_Ascension_Force_TheKraken_Node_3_1": "Kraken Teleportation",
    "MUTA_Elementalist_Ascension_Force_TheKraken_Node_4_0": "Kraken DoTs",
    "MUTA_VitalityVoid_Ascension_Force_TheKraken_Node_4_1": "Glaciate Emulation",
    "ACT_Defiance_Ascension_Force_Wrath_Node_1_2": "Accuracy & Critical Chance",
    "ACT_Paucity_Ascension_Force_Wrath_Node_2_0": "On Berserk",
    "MUTA_VitalityVoid_Ascension_Force_Wrath_Node_2_1": "Two-hander Scaling",
    "MUTA_Predator_Ascension_Force_Wrath_Node_3_1": "Damage & Lifesteal",
    "ACT_VitalityVoid_Ascension_Entropy_TheFly_Node_3_0": "On Source Spent",
    "ACT_Wither_Ascension_Entropy_TheFly_Node_3_1": "On Slowed/Weakened II+",
    "MUTA_VitalityVoid_Ascension_Entropy_TheFly_Node_4_0": "Applies Terrifed II",
    "MUTA_Wither_Ascension_Entropy_TheFly_Node_4_1": "Sugjugated II Application",
    "ACT_Occultist_Ascension_Entropy_TheVulture_Node_3_0": "On Subjugated/Terrified II+",
    "ACT_Paucity_Ascension_Force_Wrath_Node_2_0": "On Berserk",
    "MUTA_VitalityVoid_Ascension_Force_Wrath_Node_2_1": "Paucity Two-hander Scaling",
    "MUTA_Paucity_Ascension_Force_Wrath_Node_3_0": "Wither on Basic Attack",
    "MUTA_Paucity_Ascension_Force_Wrath_Node_4_0": "Effective Infusions",
    "MUTA_Predator_Ascension_Force_Wrath_Node_4_1": "SI1: Horrid Wilting Emulation",
    "ACT_Predator_Ascension_Entropy_TheVulture_Node_3_1": "On AoO",
    "MUTA_Occultist_Ascension_Entropy_TheVulture_Node_4_0": "Applies Weakened II",
    "MUTA_Predator_Ascension_Entropy_TheVulture_Node_4_1": "Critical Chance",
    "ACT_VitalityVoid_Ascension_Entropy_BloodApe_Node_3_0": "On &lt;35% Vitality",
    "ACT_Wither_Ascension_Entropy_BloodApe_Node_3_1": "On Bleeding",
    "MUTA_VitalityVoid_Ascension_Entropy_BloodApe_Node_4_0": "Source Generation",
    "MUTA_Wither_Ascension_Entropy_BloodApe_Node_4_1": "SI1: Grasp of the Starved",
    "ACT_IncarnateChampion_Ascension_Entropy_BloodApe_Node_4_2": "Incarnate Champion",
    "ACT_Paucity_Ascension_Entropy_Extinction_Node_2_0": "On ally deaths",
    "ACT_Predator_Ascension_Entropy_Extinction_Node_2_1": "On turn end",
    "MUTA_Paucity_Ascension_Entropy_Extinction_Node_3_0": "Summon Paucity",
    "MUTA_Predator_Ascension_Entropy_Extinction_Node_3_1": "Boneshaped Skitterers",
    "MUTA_Predator_Ascension_Entropy_Extinction_Node_3_2": "Corpse Scaling",
    "ACT_Occultist_Ascension_Entropy_TheImp_Node_3_0": "On Wither",
    "ACT_Wither_Ascension_Entropy_TheImp_Node_3_1": "On Subjugated/Terrified",
    "MUTA_Occultist_Ascension_Entropy_TheImp_Node_4_0": "Basic Attack",
    "MUTA_Wither_Ascension_Entropy_TheImp_Node_4_1": "Applies Vulnerable II",
    "MUTA_Wither_Ascension_Entropy_TheImp_Node_4_2": "Vampiric Touch Emulation",
    "ACT_Predator_Ascension_Entropy_TheHyena_Node_3_0": "On Predator",
    "ACT_VitalityVoid_Ascension_Entropy_TheHyena_Node_3_1": "On Source Spent",
    "ACT_VitalityVoid_Ascension_Entropy_TheHyena_Node_3_2": "On T3 Received",
    "MUTA_Predator_Ascension_Entropy_TheHyena_Node_4_0": "Voracity Activation",
    "MUTA_VitalityVoid_Ascension_Entropy_TheHyena_Node_4_1": "Applies Subjugated & Terrified II",
    "MUTA_VitalityVoid_Ascension_Entropy_TheHyena_Node_4_2": "Damage Scaling per Target",
    "ACT_Adaptation_Ascension_Entropy_TheSupplicant_Node_2_0": "On ally killed",
    "ACT_Occultist_Ascension_Entropy_TheSupplicant_Node_2_1": "On summon death",
    "MUTA_Adaptation_Ascension_Entropy_TheSupplicant_Node_3_0": "Invested Power & Lifesteal",
    "MUTA_Occultist_Ascension_Entropy_TheSupplicant_Node_3_1": "Totem Summon",
    "MUTA_Occultist_Ascension_Entropy_TheSupplicant_Node_3_2": "Infect Emulation",
    "ACT_Predator_Ascension_Entropy_Death_Node_2_0": "On ally Violent Strike",
    "ACT_VitalityVoid_Ascension_Entropy_Death_Node_2_1": "On character death",
    "MUTA_Predator_Ascension_Entropy_Death_Node_3_0": "AP Recovery on Kill",
    "MUTA_VitalityVoid_Ascension_Entropy_Death_Node_3_1": "Radius & Wither",
    "MUTA_Predator_Ascension_Entropy_Death_Node_4_0": "Bloated Corpse on kill",
    "MUTA_VitalityVoid_Ascension_Entropy_Death_Node_4_1": "Boneshaped Skitterers",
    "ACT_Wither_Ascension_Entropy_Decay_Node_2_0": "On corpse explosion",
    "MUTA_Paucity_Ascension_Entropy_Decay_Node_3_0": "Power & Wits",
    "MUTA_Wither_Ascension_Entropy_Decay_Node_3_1": "Accuracy Debuff",
    "MUTA_Paucity_Ascension_Entropy_Decay_Node_4_0": "Leadership Debuff Aura",
    "MUTA_Wither_Ascension_Entropy_Decay_Node_4_1": "Corroding & Con Debuff",
    "ACT_Adaptation_Ascension_Entropy_Demilich_Node_2_0": "On Paucity",
    "MUTA_Adaptation_Ascension_Entropy_Demilich_Node_3_0": "Demilich Effective Infusions (1)",
    "MUTA_Occultist_Ascension_Entropy_Demilich_Node_3_1": "Demilich Occultist",
    "MUTA_Adaptation_Ascension_Entropy_Demilich_Node_4_0": "Demilich Effective Infusions (2)",
    "MUTA_Occultist_Ascension_Entropy_Demilich_Node_4_1": "Adaptation Stacks",
    "ACT_Abeyance_Ascension_Form_TheChalice_Node_3_0": abeyanceACT,
    "ACT_Adaptation_Ascension_Form_TheChalice_Node_3_1": adaptationACT,
    "MUTA_Abeyance_Ascension_Form_TheChalice_Node_4_0": "Tier I & II Removal",
    "MUTA_Adaptation_Ascension_Form_TheChalice_Node_4_1": "Elemental Resistances",
    "ACT_Centurion_Ascension_Form_TheKey_Node_3_0": centurionMissACT,
    "ACT_Occultist_Ascension_Form_TheKey_Node_3_1": "On Ataxia/Squelched III",
    "MUTA_Occultist_Ascension_Form_TheKey_Node_4_1": "Applies Calcifying",
    "ACT_Defiance_Ascension_Form_TheNautilus_Node_2_0": "Basic, Physical Resistance",
    "MUTA_Presence_Ascension_Form_TheSilkworm_Node_2_1": "Elemental Resistances",
    "ACT_Occultist_Ascension_Form_TheBasilisk_Node_2_0": "On turn end (off-hand)",
    "ACT_Wither_Ascension_Form_TheBasilisk_Node_2_1": "On your Calcifying",
    "MUTA_Occultist_Ascension_Form_TheBasilisk_Node_3_0": "SI1: Petrifying Visage Emulation",
    "MUTA_Occultist_Ascension_Form_TheBasilisk_Node_3_1": "Applies Slowed II",
    "MUTA_Wither_Ascension_Form_TheBasilisk_Node_3_2": "Movement Debuff",
    "MUTA_Presence_Ascension_Form_Doppelganger_Node_2_4": "Wits",
    "ACT_Adaptation_Ascension_Form_Doppelganger_Node_3_0": "On Incarnate Infusion",
    "ACT_Occultist_Ascension_Form_Doppelganger_Node_3_1": "On summon death",
    "MUTA_Adaptation_Ascension_Form_Doppelganger_Node_4_0": "Vitality & Armor Restoration",
    "MUTA_Occultist_Ascension_Form_Doppelganger_Node_4_1": "Throw Dust Emulation",
    "ACT_IncarnateChampion_Ascension_Form_Doppelganger_Node_4_2": incarnateChampionACT,
    "ACT_Defiance_Ascension_Form_TheDragon_Node_2_3": "At start of turn",
    "ACT_Abeyance_Ascension_Form_TheDragon_Node_3_0": "Basic Activator, threshold reduction",
    "ACT_Centurion_Ascension_Form_TheDragon_Node_3_1": "On Predator",
    "ACT_Defiance_Ascension_Form_TheDragon_Node_3_2": "Initiative & Centurion Charges",
    "MUTA_Abeyance_Ascension_Form_TheDragon_Node_4_0": "Adaptation Fire Damage",
    "MUTA_Abeyance_Ascension_Form_TheDragon_Node_4_1": "Totem Attack",
    "MUTA_Centurion_Ascension_Form_TheDragon_Node_4_2": "Adaptation Dragon's Blaze Emulation",
    "ACT_Centurion_Ascension_Form_TheGryphon_Node_2_0": centurionMissACT,
    "ACT_Ward_Ascension_Form_TheGryphon_Node_2_1": wardACT,
    "ACT_Centurion_Ascension_Form_TheGryphon_Node_2_3": "On AoO",
    "MUTA_Centurion_Ascension_Form_TheGryphon_Node_3_0": "Adaptation Stacks",
    "MUTA_Centurion_Ascension_Form_TheGryphon_Node_3_1": "Adaptation Critical Chance",
    "MUTA_Ward_Ascension_Form_TheGryphon_Node_3_2": "Adaptation Stacks",
    "ACT_Abeyance_Ascension_Form_Wealth_Node_3_0": "Basic Activation & Resistances",
    "ACT_Adaptation_Ascension_Form_Wealth_Node_3_1": "On Flurry",
    "MUTA_Abeyance_Ascension_Form_Wealth_Node_4_0": "Totem Abeyance",
    "MUTA_Adaptation_Ascension_Form_Wealth_Node_4_1": "Source Generation on Buffs",
    "MUTA_Adaptation_Ascension_Form_Wealth_Node_4_2": "Meteor Shower Effective Infusion",
    "ACT_Adaptation_Ascension_Form_Cerberus_Node_2_0": "On Cannibalize",
    "MUTA_Ward_Ascension_Form_Cerberus_Node_2_1": "Dual-wield damage per totem",
    "MUTA_Adaptation_Ascension_Form_Cerberus_Node_3_0": "Constitution & Initiative",
    "MUTA_Ward_Ascension_Form_Cerberus_Node_3_1": "Boneshaped Skitterer",
    "MUTA_Adaptation_Ascension_Form_Cerberus_Node_4_0": "Cerberus Sharing (Players)",
    "MUTA_Adaptation_Ascension_Form_Cerberus_Node_4_1": "Cerberus Sharing (Summons)",
    "MUTA_Ward_Ascension_Form_Cerberus_Node_4_2": "Attributes & Duration",
    "MUTA_Presence_Ascension_Form_TheRitual_Node_1_2": "Critical Chance",
    "ACT_Occultist_Ascension_Form_TheRitual_Node_2_0": "On Ritual Reaction",
    "MUTA_Wither_Ascension_Form_TheRitual_Node_2_1": "Two-hander Dodge Debuff",
    "MUTA_Occultist_Ascension_Form_TheRitual_Node_3_0": "AP Recovery Debuff",
    "MUTA_Wither_Ascension_Form_TheRitual_Node_3_1": "Wits Debuff",
    "MUTA_Occultist_Ascension_Form_TheRitual_Node_4_0": "Totem Attack",
    "ACT_Wither_Ascension_Form_TheRitual_Node_4_1": "Ritual Exodia",
    "ACT_Abeyance_Ascension_Form_Sphinx_Node_2_0": "Basic Activation & AP Recovery",
    "MUTA_Centurion_Ascension_Form_Sphinx_Node_2_1": "Off-hand Silencing Stare Emulation",
    "MUTA_Abeyance_Ascension_Form_Sphinx_Node_3_0": "Adaptation Damage Reduction",
    "MUTA_Centurion_Ascension_Form_Sphinx_Node_3_1": "Adaptation Stacks",
    "MUTA_Abeyance_Ascension_Form_Sphinx_Node_4_0": "Sphinx Abeyance",
    "MUTA_Centurion_Ascension_Form_Sphinx_Node_4_1": "Adaptation Chain Lightning Emulation",
    "ACT_Defiance_Ascension_Inertia_TheArmadillo_Node_2_1": "Increased B/H Threshold",
    "MUTA_Presence_Ascension_Inertia_TheAuroch_Node_2_1": "Elemental & Physical Resistance",
    "ACT_Benevolence_Ascension_Inertia_TheCrab_Node_3_0": "Basic Activation",
    "ACT_Ward_Ascension_Inertia_TheCrab_Node_3_1": wardACT,
    "MUTA_Benevolence_Ascension_Inertia_TheCrab_Node_4_0": "Source Generation",
    "MUTA_Ward_Ascension_Inertia_TheCrab_Node_4_1": "Increased B/H Threshold",
    "ACT_Celestial_Ascension_Inertia_TheGuardsman_Node_3_0": "On B/H Removal",
    "ACT_Centurion_Ascension_Inertia_TheGuardsman_Node_3_1": "On Ally Attacked",
    "MUTA_Celestial_Ascension_Inertia_TheGuardsman_Node_4_0": "Debuffs Cleanse",
    "MUTA_Centurion_Ascension_Inertia_TheGuardsman_Node_4_1": "Applies Taunted",
    "MUTA_Presence_Ascension_Inertia_TheCasque_Node_2_3": "Missing Armor Regen",
    "ACT_Benevolence_Ascension_Inertia_TheCasque_Node_3_0": "Off-hand on Paucity/Purity",
    "ACT_Celestial_Ascension_Inertia_TheCasque_Node_3_1": "On B/H Removal",
    "ACT_Celestial_Ascension_Inertia_TheCasque_Node_3_2": "On 3+ Elementalist Stacks",
    "MUTA_Benevolence_Ascension_Inertia_TheCasque_Node_4_0": "Phys & Magic Armor",
    "MUTA_Celestial_Ascension_Inertia_TheCasque_Node_4_1": "Duplication on Self",
    "MUTA_Centurion_Ascension_Inertia_TheCenturion_Node_2_3": "+B/H with Defiance",
    "ACT_Centurion_Ascension_Inertia_TheCenturion_Node_3_0": "On Ally Attacked",
    "MUTA_Celestial_Ascension_Inertia_TheCenturion_Node_3_1": "Source Generation",
    "ACT_Centurion_Ascension_Inertia_TheCenturion_Node_3_2": "On Ward from enemy",
    "MUTA_Centurion_Ascension_Inertia_TheCenturion_Node_4_0": "SI1: Applies Ruptured Tendons",
    "MUTA_Centurion_Ascension_Inertia_TheCenturion_Node_4_1": "Violent Strikes & Damage",
    "MUTA_Ward_Ascension_Inertia_TheCenturion_Node_4_2": "Volatile Armor",
    "ACT_Benevolence_Ascension_Inertia_TheGladiator_Node_3_0": "On 10+ Adaptation Stacks",
    "MUTA_Adaptation_Ascension_Inertia_TheGladiator_Node_3_0": "Mercy Emulation",
    "ACT_Ward_Ascension_Inertia_TheGladiator_Node_3_1": wardACT,
    "ACT_Ward_Ascension_Inertia_TheGladiator_Node_3_2": "On Dodge (dual-wield)",
    "MUTA_Benevolence_Ascension_Inertia_TheGladiator_Node_4_0": "Adaptation Stacks",
    "MUTA_Ward_Ascension_Inertia_TheGladiator_Node_4_1": "Restoration & B/H Removal",
    "MUTA_Centurion_Ascension_Inertia_TheGladiator_Node_4_2": "Armor & Damage (Ward)",
    "ACT_Celestial_Ascension_Inertia_TheHippopotamus_Node_2_0": "On Critical Strike",
    "ACT_Prosperity_Ascension_Inertia_TheHippopotamus_Node_2_1": prosperityACT,
    "ACT_Prosperity_Ascension_Inertia_TheHippopotamus_Node_2_2": "On Ward",
    "MUTA_Celestial_Ascension_Inertia_TheHippopotamus_Node_3_0": "Missing Armor Restoration",
    "MUTA_Celestial_Ascension_Inertia_TheHippopotamus_Node_3_1": "Applies Violent Strikes",
    "MUTA_Prosperity_Ascension_Inertia_TheHippopotamus_Node_3_2": "Physical Resistances",
    "ACT_Abeyance_Ascension_Inertia_TheRhinoceros_Node_2_0": "Alternative Damage Order",
    "ACT_Centurion_Ascension_Inertia_TheRhinoceros_Node_2_1": "On Tier II+ on ally",
    "ACT_Defiance_Ascension_Inertia_TheRhinoceros_Node_2_2": "Damage & Duration",
    "MUTA_Abeyance_Ascension_Inertia_TheRhinoceros_Node_3_0": "Shields Up Emulation",
    "MUTA_Centurion_Ascension_Inertia_TheRhinoceros_Node_3_1": "Battle Stomp Emulation",
    "ACT_Defiance_Ascension_Inertia_TheArena_Node_1_2": "Dodge & B/H Threshold",
    "ACT_Centurion_Ascension_Inertia_TheArena_Node_2_0": "Centurion on turn end",
    "MUTA_Prosperity_Ascension_Inertia_TheArena_Node_2_1": "Dual-wield Accuracy & Crit",
    "MUTA_Centurion_Ascension_Inertia_TheArena_Node_3_0": "Applies Ataxia & Squelched II",
    "MUTA_Prosperity_Ascension_Inertia_TheArena_Node_3_1": "Arena Effective Infusions",
    "MUTA_Centurion_Ascension_Inertia_TheArena_Node_4_0": "Whirlwind",
    "MUTA_Prosperity_Ascension_Inertia_TheArena_Node_4_1": "Bouncing Shield",
    "ACT_Celestial_Ascension_Inertia_Champion_Node_2_0": "On Vulnerable III",
    "MUTA_Ward_Ascension_Inertia_Champion_Node_2_1": "Champion Encourage",
    "MUTA_Celestial_Ascension_Inertia_Champion_Node_3_0": "Spell Emulation on enemy",
    "MUTA_Ward_Ascension_Inertia_Champion_Node_3_1": "Resistances",
    "MUTA_Celestial_Ascension_Inertia_Champion_Node_4_0": "Applies Ward",
    "MUTA_Ward_Ascension_Inertia_Champion_Node_4_1": "Scaled Resistances",
    "ACT_Defiance_Ascension_Inertia_Fortress_Node_1_3": "Extra Prepared AP",
    "ACT_Benevolence_Ascension_Inertia_Fortress_Node_2_0": "On Armor Depletion",
    "MUTA_Presence_Ascension_Inertia_Fortress_Node_2_1": "B/H Threshold",
    "MUTA_Abeyance_Ascension_Inertia_Fortress_Node_3_0": "Comeback Kid",
    "MUTA_Benevolence_Ascension_Inertia_Fortress_Node_3_1": "Armor Restoration",
    "MUTA_Abeyance_Ascension_Inertia_Fortress_Node_4_0": "Fortress Shared Abeyance",
    "MUTA_Benevolence_Ascension_Inertia_Fortress_Node_4_1": "Fortress Stockpile",
    "ACT_Defiance_Ascension_Life_TheBeetle_Node_2_0": "Increased Armor",
    "ACT_Celestial_Ascension_Life_TheHind_Node_3_0": "On Source Spent",
    "ACT_Elementalist_Ascension_Life_TheHind_Node_3_1": "On Aerotheurge/Hydrosophist",
    "MUTA_Celestial_Ascension_Life_TheHind_Node_4_0": "Source Generation",
    "MUTA_Elementalist_Ascension_Life_TheHind_Node_4_1": "Applies Charged & Brittle",
    "MUTA_Presence_Ascension_Life_TheLizard_Node_2_1": "Resistances & Restoration",
    "ACT_Prosperity_Ascension_Life_TheRabbit_Node_3_0": prosperityACT,
    "ACT_Purity_Ascension_Life_TheRabbit_Node_3_1": purityACT,
    "MUTA_Prosperity_Ascension_Life_TheRabbit_Node_4_0": "Status Duration & Resistances",
    "MUTA_Purity_Ascension_Life_TheRabbit_Node_4_1": "B/H Threshold",
    "ACT_Elementalist_Ascension_Life_TheEnchantress_Node_3_0": "On Centurion/Weakened III",
    "ACT_Prosperity_Ascension_Life_TheEnchantress_Node_3_1": "On Elementalist Stacks",
    "MUTA_Purity_Ascension_Life_TheEnchantress_Node_4_0": "Elementalist Stacks Reduction",
    "MUTA_Elementalist_Ascension_Life_TheEnchantress_Node_4_1": "Resistances & Crits",
    "MUTA_Prosperity_Ascension_Life_TheEnchantress_Node_4_2": "Effective Infusions",
    "ACT_Prosperity_Ascension_Life_TheHuntress_Node_3_0": "On Flurry",
    "ACT_Purity_Ascension_Life_TheHuntress_Node_3_1": "On Prosperity Lost",
    "MUTA_Prosperity_Ascension_Life_TheHuntress_Node_4_0": "Status Duration & Crits",
    "MUTA_Prosperity_Ascension_Life_TheHuntress_Node_4_1": "Huntress Effective SIs",
    "MUTA_Purity_Ascension_Life_TheHuntress_Node_4_2": purityCooldownReduction,
    "ACT_Celestial_Ascension_Life_TheNymph_Node_3_0": "On Purity/Paucity",
    "ACT_Purity_Ascension_Life_TheNymph_Node_3_1": purityACT,
    "MUTA_Purity_Ascension_Life_TheNymph_Node_3_2": "Cooldown Reduction on Celestial",
    "MUTA_Celestial_Ascension_Life_TheNymph_Node_4_0": "Nymph SP Transfer",
    "MUTA_Purity_Ascension_Life_TheNymph_Node_4_2": "SI: Combustion Emulation",
    "ACT_Benevolence_Ascension_Life_Pegasus_Node_2_0": "On Purity/Paucity (off-hand)",
    "ACT_Elementalist_Ascension_Life_Pegasus_Node_2_1": "On Aerotheurge/Hydrosophist",
    "MUTA_Presence_Ascension_Life_Pegasus_Node_2_2": "Movement",
    "ACT_Elementalist_Ascension_Life_Pegasus_Node_2_3": "On Huntsman/Warfare",
    "MUTA_Benevolence_Ascension_Life_Pegasus_Node_3_0": "Restoration & Resistances",
    "MUTA_Benevolence_Ascension_Life_Pegasus_Node_3_1": "Purity Activator",
    "MUTA_Elementalist_Ascension_Life_Pegasus_Node_3_2": "Celestial Stacks Reduction",
    "ACT_Celestial_Ascension_Life_TheStag_Node_2_0": "On Source Spent",
    "ACT_ViolentStrike_Ascension_Life_TheStag_Node_2_1": "On B/H Removal",
    "ACT_Defiance_Ascension_Life_TheStag_Node_2_2": "Elemental Resistances",
    "MUTA_Celestial_Ascension_Life_TheStag_Node_3_0": "Applies Hasted",
    "MUTA_Celestial_Ascension_Life_TheStag_Node_3_1": "Applies Magic Shell",
    "MUTA_ViolentStrike_Ascension_Life_TheStag_Node_3_2": "Purity Spell Emulation",
    "ACT_Celestial_Ascension_Life_TheGoddess_Node_2_0": "On Ally Ward",
    "MUTA_Celestial_Ascension_Life_TheGoddess_Node_2_1": "Armor Restoration",
    "MUTA_Benevolence_Ascension_Life_TheGoddess_Node_3_0": "Celestial Emulation",
    "MUTA_Celestial_Ascension_Life_TheGoddess_Node_3_1": "B/H Removal",
    "MUTA_Benevolence_Ascension_Life_TheGoddess_Node_4_0": "Goddess Benevolence",
    "ACT_Celestial_Ascension_Life_TheGoddess_Node_4_1": "SI: Ally Resurrection",
    "MUTA_Presence_Ascension_Life_Hope_Node_1_3": "Movement",
    "ACT_Purity_Ascension_Life_Hope_Node_2_0": "On Shields Up",
    "MUTA_Centurion_Ascension_Life_Hope_Node_2_1": "Dual-wield Crits",
    "MUTA_Centurion_Ascension_Life_Hope_Node_3_0": "Purity Damage Scaling",
    "MUTA_Centurion_Ascension_Life_Hope_Node_3_1": "SI: Supernova Emulation",
    "MUTA_Purity_Ascension_Life_Hope_Node_3_2": "Blinding Radiance",
    "ACT_Centurion_Ascension_Life_Hope_Node_4_0": "Hope Centurion",
    "MUTA_Purity_Ascension_Life_Hope_Node_4_1": "Hope Effective SIs",
    "ACT_Prosperity_Ascension_Life_Splendor_Node_2_0": "On Purity",
    "MUTA_Elementalist_Ascension_Life_Splendor_Node_3_0": "Increased Radius",
    "MUTA_Prosperity_Ascension_Life_Splendor_Node_3_1": "Ignition Emulation",
    "MUTA_Elementalist_Ascension_Life_Splendor_Node_4_0": "Splendor AoE",
    "MUTA_Prosperity_Ascension_Life_Splendor_Node_4_1": "Splendor Ignition",
    "MUTA_Prosperity_Ascension_Life_Splendor_Node_4_2": "Splendor SP",
    # "": "",
}

keywordCategories = {}

keywordNodes = {}

nodeToStat = {}

# todo special tab for voracity, remove VA and incarnate champ
keywordDisplayNames = {
    "Abeyance": "<font size='21'>———— Abeyance ————</font>",
    "Adaptation": "<font size='21'>———— Adaptation ————</font>",
    "Benevolence": "<font size='21'>——— Benevolence ———</font>",
    "Celestial": "<font size='21'>———— Celestial ————</font>",
    "Centurion": "<font size='21'>———— Centurion ————</font>",
    "Defiance": "<font size='21'>———— Defiance ————</font>",
    "Elementalist": "<font size='21'>———— Elementalist ————</font>",
    "Occultist": "<font size='21'>———— Occultist ————</font>",
    "Paucity": "<font size='21'>———— Paucity ————</font>",
    "Predator": "<font size='21'>———— Predator ————</font>",
    "Presence": "<font size='21'>———— Presence ————</font>",
    "Prosperity": "<font size='21'>——— Prosperity ———</font>",
    "Purity": "<font size='21'>———— Purity ————</font>",
    "ViolentStrike": "<font size='21'>——— Violent Strikes ———</font>",
    "VitalityVoid": "<font size='21'>———— Vitality Void ————</font>",
    "Volatile Armor": "<font size='21'>—— Volatile Armor ——</font>",
    "Voracity": "<font size='21'>———— Voracity ————</font>", # not actually used
    "Ward": "<font size='21'>—————— Ward ——————</font>",
    "Wither": "<font size='21'>————— Wither —————</font>",
    "IncarnateChampion": "<font size='21'>—— Incarnate Champion ——</font>",
}

keywordBoonShorthand = {"mutator": "MUTA", "activator": "ACT"}

def AddStat(aspect, nodeIndex, nodeSubIndex, stat, family):
    if stat["keyword"] == "Bane": # idk why the og python script misreports this keyword on a single node
        stat["keyword"] = "Occultist"

    displayName = "UNDEFINED"

    stringKey = "AMER_UI_Ascension_" + family.capitalize() + "_" + aspect["id"] + "_Node_" + str(nodeIndex) + "_" + str(nodeSubIndex)
    # print(stat)

    customStatIdNoPrefix = stat["keyword"] + "_Ascension_" + family.capitalize() + "_" + aspect["id"] + "_Node_" + str(nodeIndex) + "_" + str(nodeSubIndex)

    if "MUTA_" + customStatIdNoPrefix in keywordNodes or "ACT_" + customStatIdNoPrefix in keywordNodes:
        if stat["keywordBoon"].capitalize() == "Activator" and "MUTA_" + customStatIdNoPrefix in keywordNodes:
            del keywordNodes["MUTA_" + customStatIdNoPrefix]
            keywordCategories["Keyword_" + stat["keyword"]]["Stats"].remove("MUTA_" + customStatIdNoPrefix)
        else:
            return

    customStatId = keywordBoonShorthand[stat["keywordBoon"]] + "_" + customStatIdNoPrefix

    description = tskExport[stringKey]
    description = description.replace("\n» ", "<br><br>")
    # description = description.replace("»", " ")

    if customStatId in statDisplayNames:
        displayName = statDisplayNames[customStatId]

    newKeyword = {
        "Display": displayName,
        "Description": description,
        "Keyword": stat["keyword"],
        "Type": stat["keywordBoon"].capitalize(),
        "SourceAspect": aspect["name"],
        "ClusterId": family.capitalize() + "_" + aspect["id"],
        "NodeIndex": nodeIndex,
        "SubNodeIndex": subNodeIndex,
    }

    if family.capitalize() + "_" + aspect["id"] not in nodeToStat:
        nodeToStat[family.capitalize() + "_" + aspect["id"]] = {}

    nodeToStat[family.capitalize() + "_" + aspect["id"]]["Node_" + str(nodeIndex) + "." + str(nodeSubIndex)] = customStatId

    if customStatId in keywordNodes: # report when multiple stats with keywords come from the same node. Happens for nodes that grant basic ACT + some MUTA. Doesn't matter unless we decide to split those off into their own stats (imo unnecessary). If we want to do that, the simplest solution is to prepend ACT/MUTA to the stat ID
        print("duplicate key " + customStatId)

    keywordNodes[customStatId] = newKeyword

    categoryName = "Keyword_" + stat["keyword"]
    if categoryName not in keywordCategories:
        keywordCategories[categoryName] = {
            "Display": keywordDisplayNames[stat["keyword"]],
            "BehaviourWhenUnused": "Hidden",
            "Stats": [],
        }

    keywordCategories[categoryName]["Stats"].append(customStatId)

for family in ascension:
    for aspect in ascension[family]:
        for nodeIndex, node in enumerate(ascension[family][aspect]["nodes"]):
            for subNodeIndex, subNode in enumerate(node["subNodes"]):
                for stat in subNode:
                    if "keyword" in stat and stat["keyword"] != None:
                        AddStat(ascension[family][aspect], nodeIndex, subNodeIndex, stat, family)

for category in keywordCategories:
    keywordCategories[category]["Stats"] = sorted(keywordCategories[category]["Stats"])

# yeet the incarnate out
del keywordCategories["Keyword_IncarnateChampion"]

output = open("output.json", "w", encoding="utf8")
output.write(json.dumps(keywordNodes, indent=2, ensure_ascii=False))

output = open("categories_output.json", "w", encoding="utf8")
output.write(json.dumps(keywordCategories, indent=2, ensure_ascii=False))

output = open("nodeToStat_output.json", "w", encoding="utf8")
output.write(json.dumps(nodeToStat, indent=2, ensure_ascii=False))

print("Keyword ACTs/MUTAs count: " + str(len(keywordNodes.keys())))