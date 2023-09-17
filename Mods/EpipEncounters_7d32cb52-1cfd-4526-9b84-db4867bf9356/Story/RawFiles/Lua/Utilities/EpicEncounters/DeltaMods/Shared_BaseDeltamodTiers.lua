
---------------------------------------------
-- Holds data of the "tiers" of base boosts for generated equipment.
-- Unfortunately hard-coded. Generating this would be complex and still require certain assumptions.
---------------------------------------------

---@class EpicEncounters_DeltaModsLib
local Deltamods = EpicEncounters.DeltaMods

---@class EpicEncounters.DeltaMods.BaseBoostTier
---@field Tiers integer
---@field Boosts table<string, integer>

---@type table<ItemSlot|ArmorType, EpicEncounters.DeltaMods.BaseBoostTier>
Deltamods.EQUIPMENT_BASE_BOOST_TIERS = {
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

    Plate = {
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

    Robe = {
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