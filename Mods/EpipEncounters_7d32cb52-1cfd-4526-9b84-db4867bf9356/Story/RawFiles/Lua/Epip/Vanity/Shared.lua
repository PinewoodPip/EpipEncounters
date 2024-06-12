
local ARMOR_SLOTS = {
    Gloves = true,
    Breast = true,
    Boots = true,
    Leggings = true,
    Helmet = true,
}

---@class Feature_Vanity : Feature
local Vanity = {
    Name = "Vanity",

    ---@type table<string,VanityCategory>
    CATEGORIES = {
        -- Elven = {
        --     Name = "Elven",
        --     Slots = ARMOR_SLOTS,
        --     Tags = {
        --         Elven = true,
        --     },
        -- },
        -- Far too many items! Basically all armor.
        -- Human = {
        --     Name = "Human",
        --     Tags = {
        --         Human = true,
        --     },
        -- },
        -- Lizard = {
        --     Name = "Lizard",
        --     Slots = ARMOR_SLOTS,
        --     Tags = {
        --         Lizard = true,
        --     },
        -- },
        -- Dwarven = {
        --     Name = "Dwarven",
        --     Slots = ARMOR_SLOTS,
        --     Tags = {
        --         Dwarven = true,
        --     },
        -- },
        Classed = {
            Name = "Classed",
            Tags = {
                Battlemage = true,
                Enchanter = true,
                Inquisitor = true,
                Ranger = true,
                Rogue = true,
                Shadowblade = true,
                Wayfarer = true,
                Witch = true,
            },
        },
        Platemail = {
            Name = "Platemail",
            Tags = {Platemail = true,}
        },
        Scalemail = {
            Name = "Scalemail",
            Tags = {Scalemail = true,}
        },
        Leather = {
            Name = "Leather",
            Tags = {Leather = true,}
        },
        Mage = {
            Name = "Mage",
            Tags = {Mage = true,}
        },
        Common = {
            Name = "Common",
            Slots = ARMOR_SLOTS,
            Tags = {Common = true, Tool = true, Starter = true,}
        },

        -- WEAPONS
        OneHandedSwords = {
            Name = "One-Handed Swords",
            Slots = {Weapon = true}, -- Slot restriction.
            Tags = {Sword = true, ["1H"] = true},
            RequireAllTags = true,
        },
        TwoHandedSwords = {
            Name = "Two-Handed Swords",
            Slots = {Weapon = true},
            Tags = {Sword = true, ["2H"] = true},
            RequireAllTags = true,
        },
        OneHandedAxes = {
            Name = "One-Handed Axes",
            Slots = {Weapon = true}, -- Slot restriction.
            Tags = {Axe = true, ["1H"] = true},
            RequireAllTags = true,
        },
        TwoHandedAxes = {
            Name = "Two-Handed Axes",
            Slots = {Weapon = true},
            Tags = {Axe = true, ["2H"] = true},
            RequireAllTags = true,
        },
        OneHandedMaces = {
            Name = "One-Handed Maces",
            Slots = {Weapon = true}, -- Slot restriction.
            Tags = {Mace = true, ["1H"] = true},
            RequireAllTags = true,
        },
        TwoHandedMaces = {
            Name = "Two-Handed Maces",
            Slots = {Weapon = true},
            Tags = {Mace = true, ["2H"] = true},
            RequireAllTags = true,
        },
        Staves = {
            Name = "Staves",
            Slots = {Weapon = true},
            Tags = {Staff = true},
        },
        Bows = {
            Name = "Bows",
            Slots = {Weapon = true},
            Tags = {Bow = true},
        },
        Crossbows = {
            Name = "Crossbows",
            Slots = {Weapon = true},
            Tags = {Crossbow = true},
        },
        Daggers = {
            Name = "Daggers",
            Slots = {Weapon = true},
            Tags = {Dagger = true},
        },
        Wands = {
            Name = "Wands",
            Slots = {Weapon = true},
            Tags = {Wand = true},
        },
        Shields = {
            Name = "Shields",
            Slots = {Weapon = true},
            Tags = {Shield = true},
        },
        Other = {
            Name = "Other",
            Tags = {
                REF = true,
                Unique = true,
                Other = true, -- Fallback tag for items with 0 tags
            },
        },
    },

    CATEGORY_ORDER = {
        "Classed",
        "Platemail",
        "Scalemail",
        "Leather",
        "Mage",
        "Common",

        "OneHandedSwords",
        "TwoHandedSwords",
        "OneHandedAxes",
        "TwoHandedAxes",
        "OneHandedMaces",
        "TwoHandedMaces",
        "Staves",
        "Bows",
        "Crossbows",
        "Daggers",
        "Wands",
        "Shields",

        "Other",
    },

    -- Tags given to templates automatically through
    -- a word match from their name.
    -- Templates may end up in multiple categories
    -- if they match multiple of these.
    -- Mapping is pattern -> Tag.
    TEMPLATE_NAME_TAGS = {
        -- Elves = "Elven",
        -- Elf = "Elven",
        -- Humans = "Human",
        -- Dwarves = "Dwarven",
        -- Dwarf = "Dwarven",
        -- Lizard = "Lizard",
        -- Lizards = "Lizard",
        Chainmail = "Chainmail",
        Leather = "Leather",
        Mage = "Mage",
        Robe = "Mage",
        Platemail = "Platemail",
        Scalemail = "Scalemail",
        StarterArmor = "Starter",

        -- CHARACTER CREATION
        Ranger = "Ranger",
        Rogue = "Rogue",
        Battlemage = "Battlemage",
        Shadowblade = "Shadowblade",
        Enchanter = "Enchanter",
        Inquisitor = "Inquisitor",
        Wayfarer = "Wayfarer",
        Witch = "Witch",

        Common = "Common",
        Civilian = "Common",
        Broom = "Common",
        Bucket = "Common", -- lol
        Tool = "Common",
        FUR = "Common",
        TOOL = "Common",
        Unique = "Unique",
        REF = "Reference",

        -- Weapons
        Sword = "Sword",
        Axe = "Axe",
        Mace = "Mace",
        Shield = "Shield",
        Dagger = "Dagger",
        Staff = "Staff",
        Pitchfork = "Spear", -- lol
        Pickaxe = "Mace",
        Bow = "Bow",
        Crossbow = "Crossbow",
        Wand = "Wand",
        ["2H"] = "2H",
        ["1H"] = "1H",
    },

    -- The race/gender combo each visual slot in the root lsx corresponds to.
    SLOT_TO_RACE_GENDER = {
        {Race = "Human", Gender = "Male", LifeType = "Living"},
        {Race = "Human", Gender = "Female", LifeType = "Living"},
        {Race = "Dwarf", Gender = "Male", LifeType = "Living"},
        {Race = "Dwarf", Gender = "Female", LifeType = "Living"},
        {Race = "Elf", Gender = "Male", LifeType = "Living"},
        {Race = "Elf", Gender = "Female", LifeType = "Living"},
        {Race = "Lizard", Gender = "Male", LifeType = "Living"},
        {Race = "Lizard", Gender = "Female", LifeType = "Living"},

        {Race = "?", Gender = "?", LifeType = "?"},
        
        {Race = "Undead_Human", Gender = "Male", LifeType = "Undead"},
        {Race = "Undead_Human", Gender = "Female", LifeType = "Undead"},
        {Race = "Undead_Dwarf", Gender = "Male", LifeType = "Undead"},
        {Race = "Undead_Dwarf", Gender = "Female", LifeType = "Undead"},
        {Race = "Undead_Elf", Gender = "Male", LifeType = "Undead"},
        {Race = "Undead_Elf", Gender = "Female", LifeType = "Undead"},
        {Race = "Undead_Lizard", Gender = "Male", LifeType = "Undead"},
        {Race = "Undead_Lizard", Gender = "Female", LifeType = "Undead"},
    },

    SLOT_TO_DB_INDEX = {
        Helmet = 1,
        Breast = 2,
        Gloves = 3,
        Leggings = 4,
        Boots = 5,
        Weapon = 6,
        Shield = 7,
    },

    -- Patterns to replace within root template names
    -- to create a display name.
    ROOT_NAME_REPLACEMENTS = {
        ["EQ_Armor"] = "",
        ["EQ_"] = "",
        ["Elves"] = "Elven",
        ["WPN_"] = "",
        ["TOOL_"] = "",
        ["FUR_"] = "",
        ["Tool_"] = "",
        ["Clothing_"] = "",
        ["Maj_"] = "",
        ["ARM_UNIQUE_ARX"] = "", -- Fuck this one, screws the pascalcase pattern

        -- Actual keywords
        ["Upperbody"] = "Chest",
        ["UpperBody"] = "Chest",
        ["LowerBody"] = "Leggings",
        ["Lowerbody"] = "Leggings",
    },

    PERSISTENT_OUTFIT_TAG = "PIP_VANITY_PERSISTENT_OUTFIT",
    PERSISTENT_WEAPONRY_TAG = "PIP_VANITY_PERSISTENT_WEAPONRY",

    ARMOR_SLOTS = {
        Helmet = true,
        Breast = true,
        Gloves = true,
        Leggings = true,
        Boots = true,
    },

    WEAPON_SLOTS = {
        Weapon = true,
        Shield = true,
    },

    NETMSG_REVERT_APPEARANCE = "Features.Vanity.NetMsgs.RevertAppearance",

    TranslatedStrings = {
        FeatureName = {
            Handle = "h12e35ceeg43cbg4298ga0d1gfd1a6bf16b6a",
            Text = "Vanity",
            ContextDescription = [[Feature name]],
        },
        SettingsMenu_Description = {
            Handle = "h56a937e0gb868g4e6cg9f1ag634beba6c7b4",
            Text = [[Vanity allows you customize your equipment's appearance with transmog, custom dyes, and more.<br>Access it by right-clicking any equipped item and selecting "Vanity..." from the context menu.]],
            ContextDescription = [[Settings menu paragraph]],
        },
        Setting_RevertAppearanceOnUnequip_Name = {
            Handle = "h0655f2bfgcf50g4f99g9b72ge9d9d83a924e",
            Text = "Revert appearance of unequipped items",
            ContextDescription = [[Setting name]],
        },
        Setting_RevertAppearanceOnUnequip_Description = {
            Handle = "h6e951ad3g6994g4580gb0c7gbdbbf3853809",
            Text = "If enabled, items that are unequipped will have all their Vanity overrides (transmog, dyes, icon, etc.) removed automatically.<br><br>Host-only setting; applies to all players.",
            ContextDescription = [[Setting tooltip]],
        },
    },

    Settings = {},

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        ItemAppearanceReset = {}, ---@type Event<Features.Vanity.Events.ItemAppearanceResetted>
    }
}
Epip.RegisterFeature("Vanity", Vanity)
local TSK = Vanity.TranslatedStrings

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class VanityCategory
---@field ID string
---@field Name string
---@field Tags table<string, boolean>
---@field RequireAllTags boolean If true, the category will only show on items that have all its tags.
---@field Slots table<string, boolean>

---@class VanityTemplate
---@field GUID GUID
---@field Tags table<string, boolean>
---@field Name string
---@field Slot string
---@field Mod GUID
---@field RootName string
---@field Visuals GUID[]

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.Vanity.Events.ItemAppearanceResetted
---@field Item Item
---@field Character Character Character requesting the revert.

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.Vanity.NetMsgs.RevertAppearance : NetLib_Message_Character, NetLib_Message_Item

---------------------------------------------
-- SETTINGS
---------------------------------------------

Vanity.Settings.RevertAppearanceOnUnequip = Vanity:RegisterSetting("RevertAppearanceOnUnequip", {
    Type = "Boolean",
    Context = "Host",
    Name = TSK.Setting_RevertAppearanceOnUnequip_Name,
    Description = TSK.Setting_RevertAppearanceOnUnequip_Description,
    DefaultValue = false,
})
