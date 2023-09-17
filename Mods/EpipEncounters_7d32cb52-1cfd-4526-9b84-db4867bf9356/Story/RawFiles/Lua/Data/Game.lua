
Data = {Game = {}, Patterns = {}, UI = {}}

Data.Game.FlexStats = {
    DAMAGEBOOST = {Type = "Stat"},
    VITALITYBOOST = {Type = "Stat"},
    Sight = {Type = "Stat"},
    Hearing = {Type = "Stat"},

    FIRERESISTANCE = {Type = "Stat"},
    WATERRESISTANCE = {Type = "Stat"},
    AIRRESISTANCE = {Type = "Stat"},
    EARTHRESISTANCE = {Type = "Stat"},
    POISONRESISTANCE = {Type = "Stat"},
    PHYSICALRESISTANCE = {Type = "Stat"},
    PIERCINGRESISTANCE = {Type = "Stat"},

    PHYSICALARMOR = {Type = "Stat"},
    PHYSICALARMORBOOST = {Type = "Stat"},
    MAGICARMOR = {Type = "Stat"},
    MAGICARMORBOOST = {Type = "Stat"},

    MOVEMENT = {Type = "Stat"},
    MOVEMENTSPEEDBOOST = {Type = "Stat"},

    INITIATIVE = {Type = "Stat"},
    DODGEBOOST = {Type = "Stat"},
    LIFESTEAL = {Type = "Stat"},
    CRITICALCHANCE = {Type = "Stat"},
    ACCURACYBOOST = {Type = "Stat"},

    APMAXIMUM = {Type = "Stat"},
    APRECOVERY = {Type = "Stat"},
    APSTART = {Type = "Stat"},

    RANGEBOOST = {Type = "Stat"},

    STRENGTH = {Type = "Attribute", Index = 1},
    FINESSE = {Type = "Attribute", Index = 2},
    INTELLIGENCE = {Type = "Attribute", Index = 3},
    CONSTITUTION = {Type = "Attribute", Index = 4},
    MEMORY = {Type = "Attribute", Index = 5},
    WITS = {Type = "Attribute", Index = 6},

    WarriorLore = {Type = "Ability", Index = 1},
    RangerLore = {Type = "Ability", Index = 2},
    RogueLore = {Type = "Ability", Index = 3},
    FireSpecialist = {Type = "Ability", Index = 4},
    WaterSpecialist = {Type = "Ability", Index = 5},
    AirSpecialist = {Type = "Ability", Index = 6},
    EarthSpecialist = {Type = "Ability", Index = 7},
    Necromancy = {Type = "Ability", Index = 8},
    Summoning = {Type = "Ability", Index = 9},
    Polymorph = {Type = "Ability", Index = 10},

    Leadership = {Type = "Ability", Index = 11},
    Perseverance = {Type = "Ability", Index = 12},
    PainReflection = {Type = "Ability", Index = 13},

    DualWielding = {Type = "Ability", Index = 14},
    Ranged = {Type = "Ability", Index = 15},
    SingleHanded = {Type = "Ability", Index = 16},
    TwoHanded = {Type = "Ability", Index = 17},

    Barter = {Type = "Ability", Index = 18},
    Charisma = {Type = "Ability", Index = 19},
    Luck = {Type = "Ability", Index = 20},
    Loremaster = {Type = "Ability", Index = 21},
    Telekinesis = {Type = "Ability", Index = 22},
    Sneaking = {Type = "Ability", Index = 23},
    Thievery = {Type = "Ability", Index = 24},

    -- Binary stats
    IMMUNITY_BURN = {Type = "Stat_Binary", Index = 1, SubType = "Immunity"},
    IMMUNITY_FREEZE = {Type = "Stat_Binary", Index = 2, SubType = "Immunity"},
    IMMUNITY_STUN = {Type = "Stat_Binary", Index = 3, SubType = "Immunity"},
    IMMUNITY_SHOCK = {Type = "Stat_Binary", Index = 4, SubType = "Immunity"},
    IMMUNITY_POISON = {Type = "Stat_Binary", Index = 5, SubType = "Immunity"},
    IMMUNITY_CHARM = {Type = "Stat_Binary", Index = 6, SubType = "Immunity"},
    IMMUNITY_FEAR = {Type = "Stat_Binary", Index = 7, SubType = "Immunity"},
    IMMUNITY_KNOCKDOWN = {Type = "Stat_Binary", Index = 8, SubType = "Immunity"},
    IMMUNITY_MUTE = {Type = "Stat_Binary", Index = 9, SubType = "Immunity"},
    IMMUNITY_CHILLED = {Type = "Stat_Binary", Index = 10, SubType = "Immunity"},
    IMMUNITY_WARM = {Type = "Stat_Binary", Index = 11, SubType = "Immunity"},
    IMMUNITY_WET = {Type = "Stat_Binary", Index = 12, SubType = "Immunity"},
    IMMUNITY_BLEEDING = {Type = "Stat_Binary", Index = 13, SubType = "Immunity"},
    IMMUNITY_CRIPPLED = {Type = "Stat_Binary", Index = 14, SubType = "Immunity"},
    IMMUNITY_BLIND = {Type = "Stat_Binary", Index = 15, SubType = "Immunity"},
    IMMUNITY_CURSED = {Type = "Stat_Binary", Index = 16, SubType = "Immunity"},
    IMMUNITY_WEAK = {Type = "Stat_Binary", Index = 17, SubType = "Immunity"},
    IMMUNITY_SLOWED = {Type = "Stat_Binary", Index = 18, SubType = "Immunity"},
    IMMUNITY_DISEASED = {Type = "Stat_Binary", Index = 19, SubType = "Immunity"},
    IMMUNITY_DISARMED = {Type = "Stat_Binary", Index = 20, SubType = "Immunity"},
    IMMUNITY_INFECTIOUSDISEASED = {Type = "Stat_Binary", Index = 21, SubType = "Immunity"},
    IMMUNITY_PETRIFIED = {Type = "Stat_Binary", Index = 22, SubType = "Immunity"},
    IMMUNITY_DRUNK = {Type = "Stat_Binary", Index = 23, SubType = "Immunity"},
    IMMUNITY_SLIPPING = {Type = "Stat_Binary", Index = 24, SubType = "Immunity"},
}

---@class Dye
---@field Name string
---@field Template string
---@field Icon string
---@field Deltamod string Must be prefixed with ``Boost_Armor_`` or ``Boost_Weapon_`` to be used. 

---@type table<string, Dye>
Data.Game.DYES = {
    ABYSS = {
        Name = "Abyss Dye",
        Template = "AMER_TOOL_Dye_Abyss_c7cf04d2-1bcf-4223-a245-a32dcb98c457",
        Icon = "AMER_Dyes_Abyss",
        Deltamod = "Dye_Abyss",
    },
    CLAY = {
        Name = "Clay Dye",
        Template = "AMER_TOOL_Dye_Clay_95f74ac5-ec9c-4018-b8ac-b5099bcf319a",
        Icon = "AMER_Dyes_Clay",
        Deltamod = "Dye_Clay",
    },
    CORAL = {
        Name = "Coral Dye",
        Template = "AMER_TOOL_Dye_Coral_4b4b1e09-417b-4319-8e04-b859db48d077",
        Icon = "AMER_Dyes_Coral",
        Deltamod = "Dye_Coral",
    },
    EARTH = {
        Name = "Earth Dye",
        Template = "AMER_TOOL_Dye_Earth_f60a93bb-0d6c-459f-af62-9a3472d93374",
        Icon = "AMER_Dyes_Earth",
        Deltamod = "Dye_Earth",
    },
    FOG = {
        Name = "Fog Dye",
        Template = "AMER_TOOL_Dye_Fog_923c1158-5972-456d-813a-1655fa4c175a",
        Icon = "AMER_Dyes_Fog",
        Deltamod = "Dye_Fog",
    },
    LICHEN = {
        Name = "Lichen Dye",
        Template = "AMER_TOOL_Dye_Lichen_bbe83a2c-9ed9-473a-96ab-0b71809b42a5",
        Icon = "AMER_Dyes_Lichen",
        Deltamod = "Dye_Lichen",
    },
    MIDNIGHT = {
        Name = "Midnight Dye",
        Template = "AMER_TOOL_Dye_Midnight_41d07754-b3ae-4100-85ed-8d174e940f8a",
        Icon = "AMER_Dyes_Midnight",
        Deltamod = "Dye_Midnight",
    },
    NEMESIS = {
        Name = "Nemesis Dye",
        Template = "AMER_TOOL_Dye_Nemesis_b8324054-f302-4309-a956-82a9f569d3dc",
        Icon = "AMER_Dyes_Nemesis",
        Deltamod = "Dye_Nemesis",
    },
    SAFFRON = {
        Name = "Saffron Dye",
        Template = "AMER_TOOL_Dye_Saffron_4bd3a715-3688-40b2-9940-4fbd3b4655e7",
        Icon = "AMER_Dyes_Saffron",
        Deltamod = "Dye_Saffron",
    },
    SEAFOAM = {
        Name = "Seafoam Dye",
        Template = "AMER_TOOL_Dye_Seafoam_799fe8de-d76f-405e-a0d6-c2481d1a864d",
        Icon = "AMER_Dyes_Seafoam",
        Deltamod = "Dye_Seafoam",
    },
    SMOKE = {
        Name = "Smoke Dye",
        Template = "AMER_TOOL_Dye_Smoke_ce1e8c3e-8067-4b96-bf4b-0519521101fd",
        Icon = "AMER_Dyes_Smoke",
        Deltamod = "Dye_Smoke",
    },
    STEALTH = {
        Name = "Stealth Dye",
        Template = "AMER_TOOL_Dye_Stealth_2e776366-3fd1-4ad9-8002-fc61026c9809",
        Icon = "AMER_Dyes_Stealth",
        Deltamod = "Dye_Stealth",
    },
    VERDURE = {
        Name = "Verdure Dye",
        Template = "AMER_TOOL_Dye_Verdure_a4f8691b-9d56-4e98-92c7-404e9ec6bfb1",
        Icon = "AMER_Dyes_Verdure",
        Deltamod = "Dye_Verdure",
    },
    VOID = {
        Name = "Void Dye",
        Template = "AMER_TOOL_Dye_Void_a74799d1-d54f-4ad3-bb93-a46ad98ce06b",
        Icon = "AMER_Dyes_Void",
        Deltamod = "Dye_Void",
    },
    -- BLACK = {
    --     Name = "Black Dye",
    --     Template = "TOOL_Dye_Black_0f000ee0-e47a-47aa-888a-b54742467fac",
    --     Icon = "Item_TOOL_Dye_Black",
    --     Deltamod = "Boost_Armor_Dye_Clay",
    -- },
    -- BLUE = {
    --     Name = "Blue Dye",
    --     Template = "TOOL_Dye_Blue_cdffcc74-44a4-4f95-a1ce-5f7bd11e1dc5",
    --     Icon = "Item_TOOL_Dye_Blue",
    --     Deltamod = "Boost_Armor_Dye_Clay",
    -- },
    -- GREEN = {
    --     Name = "Green Dye",
    --     Template = "TOOL_Dye_Green_49a19fd6-8035-4f4f-bd61-95e85b4b91e3",
    --     Icon = "Item_TOOL_Dye_Green",
    --     Deltamod = "Boost_Armor_Dye_Clay",
    -- },
    -- PURPLE = {
    --     Name = "Purple Dye",
    --     Template = "TOOL_Dye_Purple_4a02aa47-05e2-4442-9936-6683963051f0",
    --     Icon = "Item_TOOL_Dye_Purple",
    --     Deltamod = "Boost_Armor_Dye_Clay",
    -- },
    -- RED = {
    --     Name = "Red Dye",
    --     Template = "TOOL_Dye_Red_5284e851-3f59-45b7-bce6-cdafdd98da25",
    --     Icon = "Item_TOOL_Dye_Red",
    --     Deltamod = "Boost_Armor_Dye_Clay",
    -- },
    -- WHITE = {
    --     Name = "White Dye",
    --     Template = "TOOL_Dye_White_75236993-92c7-482b-aba6-7b54b791ed7c",
    --     Icon = "Item_TOOL_Dye_White",
    --     Deltamod = "Boost_Armor_Dye_Clay",
    -- },
    -- YELLOW = {
    --     Name = "Yellow Dye",
    --     Template = "TOOL_Dye_Yellow_4e6aedcb-75f8-4b05-8ee5-f86b5a86845d",
    --     Icon = "Item_TOOL_Dye_Yellow",
    --     Deltamod = "Boost_Armor_Dye_Clay",
    -- },
    -- MYSTERY = {
    --     Name = "Mystery Dye",
    --     Template = "TOOL_UNI_Dye_A_Mystery_0e9a6aa9-5e66-45ed-8d2c-99aa02659bd6",
    --     Icon = "Item_TOOL_Dye_Black",
    --     Deltamod = "Boost_Armor_Dye_Clay",
    -- },
}

Data.Game.DYE_TEMPLATES = {}

for id,data in pairs(Data.Game.DYES) do
    data.ID = id
    Data.Game.DYE_TEMPLATES[id] = true
end

Data.Game.ABILITIES = {
    WarriorLore = "Warfare",
    RangerLore = "Huntsman",
    RogueLore = "Scoundrel",
    FireSpecialist = "Pyrokinetic",
    WaterSpecialist = "Hydrosophist",
    AirSpecialist = "Aerotheurge",
    EarthSpecialist = "Geomancer",
    Sourcery = "Sourcery",
    Necromancy = "Necromancer",
    Summoning = "Summoning",
    Polymorph = "Polymorph",

    SingleHanded = "Single-Handed",
    TwoHanded = "Two-Handed",
    Ranged = "Ranged",
    DualWielding = "Dual Wielding",

    Telekinesis = "Telekinesis",
    Sneaking = "Sneaking",
    Thievery = "Thievery",
    Loremaster = "Loremaster",
    Luck = "Lucky Charm",

    Perseverance = "Perseverance",
    Leadership = "Leadership",
    PainReflection = "Retribution",
}

-- translate skill requirements from Stats objects to actual field name
Data.Game.StatObjectAbilities = {
    Warrior = "WarriorLore",
    Earth = "EarthSpecialist",
    Water = "WaterSpecialist",
    Air = "AirSpecialist",
    Summoning = "Summoning",
    Death = "Necromancy",
    Rogue = "RogueLore",
    Ranger = "RangerLore",
    Polymorph = "Polymorph",
    Source = "Sourcery",
    Fire = "FireSpecialist",
}

Data.Game.SLOTS_WITH_SUBTYPES = {
    ["Gloves"] = true,
    ["Breast"] = true,
    ["Boots"] = true,
    ["Helmet"] = true,
    ["Leggings"] = true,
    ["Weapon"] = true,
}

Data.NULLGUID = "NULL_00000000-0000-0000-0000-000000000000"

Data.Game.DamageTypes = {
    None = {
        Name = "Pure",
        Color = "#a8a8a8"
    },
    Physical = {
        Name = "physical damage",
        Color = "#a8a8a8"
    },
    Piercing = {
        Name = "piercing damage",
        Color = "#CD1F1F"
    },
    Corrosive = {
        Name = "Physical Armour",
        Color = "#797980"
    },
    Magic = {
        Name = "Magic Armour",
        Color = "#7F00FF"
    },
    Chaos = {
        Name = "damage",
        Color = "#13D177"
    },
    Fire = {
        Name = "fire damage",
        Color = "#FE6E27"
    },
    Air = {
        Name = "air damage",
        Color = "#7D71D9"
    },
    Water = {
        Name = "water damage",
        Color = "#4197E2"
    },
    Earth = {
        Name = "earth damage",
        Color = "#763900"
    },
    Poison = {
        Name = "poison damage",
        Color = "#65C900"
    },
    Shadow = {
        Name = "tenebrium damage", -- wrong?
        Color = "#797980"
    },
    Sulfuric = {
        Name = "sulfuric damage", -- wrong?
        Color = "#13D177"
    },
    Sentinel = {
        Name = "sentinel damage", -- is this even usable or just a "Total" enum?
        Color = "#13D177"
    },
}

Data.Game.KEYWORD_NAMES = { -- TODO fill out
    ViolentStrike = "Violent Strikes",
    ViolentStrikes = "Violent Strikes",
    VitalityVoid = "Vitality Void",
}

---------------------------------------------
-- STATUSES
---------------------------------------------

Data.Game.SYSTEM_STATUSES = {
    ["AMER_ASCPOINTREMINDER"] = 1,
    ["AMER_SOURCEGEN_DISPLAY_1"] = 2,
    ["AMER_SOURCEGEN_DISPLAY_2"] = 2,
    ["AMER_SOURCEGEN_DISPLAY_3"] = 2,
    ["AMER_SOURCEGEN_DISPLAY_4"] = 2,
    ["AMER_SOURCEGEN_DISPLAY_5"] = 2,
    ["AMER_SOURCEGEN_DISPLAY_6"] = 2,
    ["AMER_SOURCEGEN_DISPLAY_7"] = 2,
}

Data.Game.TIERED_STATUSES = {
    Ataxia = {
        Name = "Ataxia",
        Tiers = {
            "AMER_ATAXIA_1",
            "AMER_ATAXIA_2",
            "AMER_ATAXIA_3",
        },
    },
    Enthralled = {
        Name = "Subjugated",
        Tiers = {
            "AMER_ENTHRALLED_1",
            "AMER_ENTHRALLED_2",
            "AMER_ENTHRALLED_3",
        }
    },
    Decaying = {
        Name = "Vulnerable",
        Tiers = {
            "AMER_DECAYING_1",
            "AMER_DECAYING_2",
            "AMER_DECAYING_3",
        }
    },
    Weakened = {
        Name = "Weakened",
        Tiers = {
            "AMER_WEAKENED_1",
            "AMER_WEAKENED_2",
            "AMER_WEAKENED_3",
        }
    },
    Slowed = {
        Name = "Slowed",
        Tiers = {
            "AMER_SLOWED_1",
            "AMER_SLOWED_2",
            "AMER_SLOWED_3",
        }
    },
    Terrified = {
        Name = "Terrified",
        Tiers = {
            "AMER_TERRIFIED_1",
            "AMER_TERRIFIED_2",
            "AMER_TERRIFIED_3",
        }
    },
    Squelched = {
        Name = "Squelched",
        Tiers = {
            "AMER_SQUELCHED_1",
            "AMER_SQUELCHED_2",
            "AMER_SQUELCHED_3",
        }
    },
    Blind = {
        Name = "Dazzled",
        Tiers = {
            "AMER_BLIND_1",
            "AMER_BLIND_2",
            "AMER_BLIND_3",
        }
    },
}

-- Quick boolean check table
Data.Game.IS_TIERED_STATUS = {}
for _,data in pairs(Data.Game.TIERED_STATUSES) do
    for _,status in pairs(data.Tiers) do
        Data.Game.IS_TIERED_STATUS[status] = true
    end
end

Data.Game.ATTRIBUTES = {
    Strength = "Strength",
    Finesse = "Finesse",
    Intelligence = "Power",
    Memory = "Memory",
    Wits = "Wits",
}

-- Links a status to a projectile skill.
Data.Game.DAMAGING_STATUS_SKILLS = {
    AMER_ENTHRALLED_1 = "Projectile_AMER_SCRIPT_StatusDamage_Enthralled_1",
    AMER_ENTHRALLED_2 = "Projectile_AMER_SCRIPT_StatusDamage_Enthralled_1",
    AMER_ENTHRALLED_3 = "Projectile_AMER_SCRIPT_StatusDamage_Enthralled_1",
    AMER_SCORCHED = "Projectile_AMER_SCRIPT_StatusDamage_Burning",
    AMER_CALCIFYING = "Projectile_AMER_SCRIPT_StatusDamage_Calcifying",
    POISONED = "Projectile_AMER_SCRIPT_StatusDamage_Poisoned",
    BLEEDING = "Projectile_AMER_SCRIPT_StatusDamage_Bleeding",
    AMER_HEMORRHAGE = "Projectile_AMER_SCRIPT_StatusDamage_Bleeding",
    AMER_CORRODING = "Projectile_AMER_SCRIPT_StatusDamage_Acid",
    ACID = "Projectile_AMER_SCRIPT_StatusDamage_Acid",
    SUFFOCATING = "Projectile_AMER_SCRIPT_StatusDamage_Suffocating",
    AMER_BANE = "Projectile_AMER_SCRIPT_StatusDamage_Bane",
    AMER_THEKRAKEN_FIRE = "Projectile_AMER_SCRIPT_StatusDamage_Kraken_Fire",
    AMER_THEKRAKEN_WATER = "Projectile_AMER_SCRIPT_StatusDamage_Kraken_Water",
    AMER_THEKRAKEN_EARTH = "Projectile_AMER_SCRIPT_StatusDamage_Kraken_Earth",
    AMER_THEKRAKEN_AIR = "Projectile_AMER_SCRIPT_StatusDamage_Kraken_Air",
    AMER_CHARGED = "Projectile_AMER_SCRIPT_StatusDamage_Charged",
    AMER_BRITTLE_1 = "Projectile_AMER_SCRIPT_StatusDamage_Brittle",
    AMER_BRITTLE_2 = "Projectile_AMER_SCRIPT_StatusDamage_Brittle",
    AMER_BRITTLE_3 = "Projectile_AMER_SCRIPT_StatusDamage_Brittle",
}

Data.Game.TORTURER_SKILL_OVERRIDES = {
    Projectile_AMER_SCRIPT_StatusDamage_Burning = "Projectile_AMER_SCRIPT_StatusDamage_Burning_Tort",
    -- Projectile_AMER_SCRIPT_StatusDamage_Calcifying = "Projectile_AMER_SCRIPT_StatusDamage_Calcifying_Tort",
    Projectile_AMER_SCRIPT_StatusDamage_Poisoned = "Projectile_AMER_SCRIPT_StatusDamage_Poisoned_Tort",
    Projectile_AMER_SCRIPT_StatusDamage_Bleeding = "Projectile_AMER_SCRIPT_StatusDamage_Bleeding_Tort",
    Projectile_AMER_SCRIPT_StatusDamage_Acid = "Projectile_AMER_SCRIPT_StatusDamage_Acid_Tort",
    Projectile_AMER_SCRIPT_StatusDamage_Corroding_Removed = "Projectile_AMER_SCRIPT_StatusDamage_Corroding_Removed_Tort",
    Projectile_AMER_SCRIPT_StatusDamage_Suffocating = "Projectile_AMER_SCRIPT_StatusDamage_Suffocating_Tort",
    Projectile_AMER_SCRIPT_StatusDamage_Charged = "Projectile_AMER_SCRIPT_StatusDamage_Charged_Tort",
}

Data.Patterns.GUID = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
Data.Patterns.GUID_CAPTURE = "_(" .. Data.Patterns.GUID .. ")$"
Data.Patterns.ARTIFACT_ROOTTEMPLATE_SUBTYPE = "^AMER_UNI_.*_(.*)_" .. Data.Patterns.GUID .. "$"

Data.Game.ATTRIBUTE_STATS = {
    ["Strength"] = true,
    ["Finesse"] = true,
    ["Intelligence"] = true,
    ["Constitution"] = true,
    ["Memory"] = true,
    ["Wits"] = true,
}

Data.Game.SLOTS_WITH_VISUALS = {
    "Helmet",
    "Breast",
    "Leggings",
    "Weapon",
    "Shield",
    "Boots",
    "Gloves",
    -- "Wings",
    -- "Horns",
    -- "Overhead",
}

Data.Game.BASE_BOOST_TO_EQUIP_TYPE = {
    ["ARM_Heavy_UpperBody"] = "Platemail",
    ["ARM_Heavy_LowerBody"] = "Platemail",
    ["ARM_Heavy_Boots"] = "Platemail",
    ["ARM_Heavy_Gloves"] = "Platemail",
    ["ARM_Heavy_Helmet"] = "Platemail",

    ["ARM_Mage_UpperBody"] = "Robes",
    ["ARM_Mage_LowerBody"] = "Robes",
    ["ARM_Mage_Boots"] = "Robes",
    ["ARM_Mage_Gloves"] = "Robes",
    ["ARM_Mage_Helmet"] = "Robes",

    ["ARM_Light_UpperBody"] = "Leather",
    ["ARM_Light_LowerBody"] = "Leather",
    ["ARM_Light_Boots"] = "Leather",
    ["ARM_Light_Gloves"] = "Leather",
    ["ARM_Light_Helmet"] = "Leather",

    ["ARM_Belt"] = "Belt",
    ["ARM_Ring"] = "Ring",
    ["ARM_Amulet"] = "Amulet",

    ["WPN_Shield"] = "Shield",

    -- Weapons
    ["WPN_Dagger"] = "Knife",
    ["WPN_Dagger_ReqB"] = "Knife",
    ["WPN_Sword_1H"] = "Sword",
    ["WPN_Sword_1H_ReqB"] = "Sword",
    ["WPN_Axe_1H"] = "Axe",
    ["WPN_Axe_1H_ReqB"] = "Axe",
    ["WPN_Mace_1H"] = "Mace",
    ["WPN_Mace_1H_ReqB"] = "Mace",
    ["WPN_Common_Mace_1H_C"] = "Mace",
    ["WPN_Common_Mace_1H_A"] = "Mace",
    ["WPN_Sword_2H"] = "Sword",
    ["WPN_Sword_2H_ReqB"] = "Sword",
    ["WPN_Axe_2H"] = "Axe",
    ["WPN_Axe_2H_ReqB"] = "Axe",
    ["WPN_Mace_2H"] = "Mace",
    ["WPN_Mace_2H_ReqB"] = "Mace",
    ["WPN_Spear"] = "Spear",
    ["WPN_Spear_ReqB"] = "Spear",
    ["WPN_Staff_Fire"] = "Staff",
    ["WPN_Staff_Fire_ReqB"] = "Staff",
    ["WPN_Staff_Water"] = "Staff",
    ["WPN_Staff_Water_ReqB"] = "Staff",
    ["WPN_Staff_Poison"] = "Staff",
    ["WPN_Staff_Poison_ReqB"] = "Staff",
    ["WPN_Staff_Air"] = "Staff",
    ["WPN_Staff_Air_ReqB"] = "Staff",
    ["WPN_Staff_Earth"] = "Staff",
    ["WPN_Staff_Earth_ReqB"] = "Staff",
    ["WPN_Bow"] = "Bow",
    ["WPN_Bow_ReqB"] = "Bow",
    ["WPN_Crossbow"] = "Crossbow",
    ["WPN_Crossbow_ReqB"] = "Crossbow",
    ["WPN_Wand_Fire"] = "Wand",
    ["WPN_Wand_Fire_ReqB"] = "Wand",
    ["WPN_Wand_Air"] = "Wand",
    ["WPN_Wand_Air_ReqB"] = "Wand",
    ["WPN_Wand_Water"] = "Wand",
    ["WPN_Wand_Water_ReqB"] = "Wand",
    ["WPN_Wand_Poison"] = "Wand",
    ["WPN_Wand_Poison_ReqB"] = "Wand",
    ["WPN_Wand_Earth"] = "Wand",
    ["WPN_Wand_Earth_ReqB"] = "Wand",
}

-- Possible base boosts for each equipment type, for randomly generated items
Data.Game.EQUIPMENT_TYPE_BASE_BOOST_TIERS = {
    Weapon = {
        Tiers = 14,
        Boosts = {
            ["_Boost_Weapon_Damage_70"] = 1,
            ["_Boost_Weapon_Damage_80"] = 2,
            ["_Boost_Weapon_Damage_90"] = 3,
            ["_Boost_Weapon_Damage_100"] = 4,
            ["_Boost_Weapon_Damage_110"] = 5,
            ["_Boost_Weapon_Damage_120"] = 6,
            ["_Boost_Weapon_Damage_130"] = 7,
            ["_Boost_Weapon_Damage_140"] = 8,
            ["_Boost_Weapon_Damage_150"] = 9,
            ["_Boost_Weapon_Damage_160"] = 10,
            ["_Boost_Weapon_Damage_170"] = 11,
            ["_Boost_Weapon_Damage_180"] = 12,
            ["_Boost_Weapon_Damage_190"] = 13,
            ["_Boost_Weapon_Damage_200"] = 14,
        },
    },

    Ring = {
        Tiers = 8,
        Boosts = {
            ["_Boost_Armor_Phys20"] = 1,
            ["_Boost_Armor_Phys30"] = 2,
            ["_Boost_Armor_Phys40"] = 3,
            ["_Boost_Armor_Phys50"] = 4,
            ["_Boost_Armor_Phys60"] = 5,
            ["_Boost_Armor_Phys70"] = 6,
            ["_Boost_Armor_Phys80"] = 7,
            ["_Boost_Armor_Phys90"] = 8,
            ["_Boost_Armor_Magic20"] = 1,
            ["_Boost_Armor_Magic30"] = 2,
            ["_Boost_Armor_Magic40"] = 3,
            ["_Boost_Armor_Magic50"] = 4,
            ["_Boost_Armor_Magic60"] = 5,
            ["_Boost_Armor_Magic70"] = 6,
            ["_Boost_Armor_Magic80"] = 7,
            ["_Boost_Armor_Magic90"] = 8,
        },
    },

    Amulet = {
        Tiers = 8,
        Boosts = {
            ["_Boost_Armor_Phys30"] = 1,
            ["_Boost_Armor_Phys40"] = 2,
            ["_Boost_Armor_Phys50"] = 3,
            ["_Boost_Armor_Phys60"] = 4,
            ["_Boost_Armor_Phys70"] = 5,
            ["_Boost_Armor_Phys80"] = 6,
            ["_Boost_Armor_Phys90"] = 7,
            ["_Boost_Armor_Phys100"] = 8,
            ["_Boost_Armor_Magic30"] = 1,
            ["_Boost_Armor_Magic40"] = 2,
            ["_Boost_Armor_Magic50"] = 3,
            ["_Boost_Armor_Magic60"] = 4,
            ["_Boost_Armor_Magic70"] = 5,
            ["_Boost_Armor_Magic80"] = 6,
            ["_Boost_Armor_Magic90"] = 7,
            ["_Boost_Armor_Magic100"] = 8,
        },
    },

    Belt = {
        Tiers = 8,
        Boosts = {
            ["_Boost_Armor_Phys30"] = 1,
            ["_Boost_Armor_Phys40"] = 2,
            ["_Boost_Armor_Phys50"] = 3,
            ["_Boost_Armor_Phys60"] = 4,
            ["_Boost_Armor_Phys70"] = 5,
            ["_Boost_Armor_Phys80"] = 6,
            ["_Boost_Armor_Phys90"] = 7,
            ["_Boost_Armor_Phys100"] = 8,
            ["_Boost_Armor_Magic30"] = 1,
            ["_Boost_Armor_Magic40"] = 2,
            ["_Boost_Armor_Magic50"] = 3,
            ["_Boost_Armor_Magic60"] = 4,
            ["_Boost_Armor_Magic70"] = 5,
            ["_Boost_Armor_Magic80"] = 6,
            ["_Boost_Armor_Magic90"] = 7,
            ["_Boost_Armor_Magic100"] = 8,
        },
    },

    Shield = {
        Tiers = 12,
        Boosts = {
            ["_Boost_Shield_Phys10"] = 1,
            ["_Boost_Shield_Phys20"] = 2,
            ["_Boost_Shield_Phys30"] = 3,
            ["_Boost_Shield_Phys40"] = 4,
            ["_Boost_Shield_Phys50"] = 5,
            ["_Boost_Shield_Phys60"] = 6,
            ["_Boost_Shield_Phys70"] = 7,
            ["_Boost_Shield_Phys80"] = 8,
            ["_Boost_Shield_Phys90"] = 9,
            ["_Boost_Shield_Phys100"] = 10,
            ["_Boost_Shield_Phys110"] = 11,
            ["_Boost_Shield_Phys120"] = 12,
        },
    },

    Platemail = {
        Tiers = 12,
        Boosts = {
            ["_Boost_Armor_Phys10"] = 1,
            ["_Boost_Armor_Phys20"] = 2,
            ["_Boost_Armor_Phys30"] = 3,
            ["_Boost_Armor_Phys40"] = 4,
            ["_Boost_Armor_Phys50"] = 5,
            ["_Boost_Armor_Phys60"] = 6,
            ["_Boost_Armor_Phys70"] = 7,
            ["_Boost_Armor_Phys80"] = 8,
            ["_Boost_Armor_Phys90"] = 9,
            ["_Boost_Armor_Phys100"] = 10,
            ["_Boost_Armor_Phys110"] = 11,
            ["_Boost_Armor_Phys120"] = 12,
        }
    },

    Robes = {
        Tiers = 12,
        Boosts = {
            ["_Boost_Armor_Magic10"] = 1,
            ["_Boost_Armor_Magic20"] = 2,
            ["_Boost_Armor_Magic30"] = 3,
            ["_Boost_Armor_Magic40"] = 4,
            ["_Boost_Armor_Magic50"] = 5,
            ["_Boost_Armor_Magic60"] = 6,
            ["_Boost_Armor_Magic70"] = 7,
            ["_Boost_Armor_Magic80"] = 8,
            ["_Boost_Armor_Magic90"] = 9,
            ["_Boost_Armor_Magic100"] = 10,
            ["_Boost_Armor_Magic110"] = 11,
            ["_Boost_Armor_Magic120"] = 12,
        },
    },

    Leather = {
        Tiers = 12,
        Boosts = {
            ["_Boost_Armor_Phys10"] = 1,
            ["_Boost_Armor_Phys20"] = 2,
            ["_Boost_Armor_Phys30"] = 3,
            ["_Boost_Armor_Phys40"] = 4,
            ["_Boost_Armor_Phys50"] = 5,
            ["_Boost_Armor_Phys60"] = 6,
            ["_Boost_Armor_Phys70"] = 7,
            ["_Boost_Armor_Phys80"] = 8,
            ["_Boost_Armor_Phys90"] = 9,
            ["_Boost_Armor_Phys100"] = 10,
            ["_Boost_Armor_Phys110"] = 11,
            ["_Boost_Armor_Phys120"] = 12,
        },
    },
}