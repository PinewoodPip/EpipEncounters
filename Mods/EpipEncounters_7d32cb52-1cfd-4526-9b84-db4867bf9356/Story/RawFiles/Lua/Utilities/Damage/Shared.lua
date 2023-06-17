
---------------------------------------------
-- Contains data and methods related to damage.
---------------------------------------------

---@class DamageLib : Library
Damage = {
    _DamageTypeIDToStringID = {}, ---@type table<integer, DamageLib_DamageType_StringID> Initialized after library registration.

    ---@type table<DamageType, DamageLib_DamageType>
    DAMAGE_TYPES = {
        Physical = {
            ID = 1,
            StringID = "Physical",
            NameHandle = "ha6c38456g4c6ag47b2gae87g60a26cf4bf7b",
        },
        Piercing = {
            ID = 2,
            StringID = "Piercing",
            NameHandle = "h22f6b7bcgc548g49cbgbc04g9532e893fb55",
        },
        Corrosive = {
            ID = 3,
            StringID = "Corrosive",
            NameHandle = "hcbe11fb4g22adg4b10g938bg467f8c41107c",
        },
        Magic = {
            ID = 4,
            StringID = "Magic",
            NameHandle = "hd01e5f46g36d4g48f5g8550gabdc4bef1f04",
        },
        Chaos = {
            ID = 5,
            StringID = "Chaos",
            NameHandle = "hf43ec8a1gb6c4g421dg983cg01535ee1bcdf",
        },
        Fire = {
            ID = 6,
            StringID = "Fire",
            NameHandle = "h051b2501g091ag4c93ga699g407cd2b29cdc",
        },
        Air = {
            ID = 7,
            StringID = "Air",
            NameHandle = "h1cea7e28gc8f1g4915ga268g31f90767522c",
        },
        Water = {
            ID = 8,
            StringID = "Water",
            NameHandle = "hd30196cdg0253g434dga42ag12be43dac4ec",
        },
        Earth = {
            ID = 9,
            StringID = "Earth",
            NameHandle = "h85fee3f4g0226g41c6g9d38g83b7b5bf96ba",
        },
        Poison = {
            ID = 10,
            StringID = "Poison",
            NameHandle = "haa64cdb8g22d6g40d6g9918g61961514f70f",
        },
        Shadow = {
            ID = 11,
            StringID = "Shadow",
            NameHandle = "hf4632a8fg42a7g4d53gbe26gd203f28e3d5e",
        },
        Sulfuric = {
            ID = 12,
            StringID = "Sulfuric",
            NameHandle = nil,
        },
        Sentinel = {
            ID = 13,
            StringID = "Sentinel",
            NameHandle = nil,
        },
    },
}
Epip.InitializeLibrary("Damage", Damage)

-- Create an integer lookup table for damage types
for stringID,damageType in pairs(Damage.DAMAGE_TYPES) do
    Damage._DamageTypeIDToStringID[damageType.ID] = stringID
end

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias DamageLib_DamageType_StringID "Physical"|"Piercing"|"Corrosive"|"Magic"|"Chaos"|"Fire"|"Air"|"Water"|"Earth"|"Poison"|"Shadow"|"Sulfuric"|"Sentinel"

---@class DamageLib_DamageType
---@field ID integer
---@field StringID DamageLib_DamageType_StringID
---@field NameHandle TranslatedStringHandle?

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the definition for a damage type.
---@param damageType DamageLib_DamageType_StringID|integer
---@return DamageLib_DamageType
function Damage.GetDamageTypeDefinition(damageType)
    if type(damageType) == "number" then -- Integer ID.
        damageType = Damage._DamageTypeIDToStringID[damageType]
    end

    return Damage.DAMAGE_TYPES[damageType]
end