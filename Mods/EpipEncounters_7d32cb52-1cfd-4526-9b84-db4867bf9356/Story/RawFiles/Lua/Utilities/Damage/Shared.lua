
---------------------------------------------
-- Contains data and methods related to damage.
---------------------------------------------

---@class DamageLib : Library
Damage = {
    _DamageTypeIDToStringID = {}, ---@type table<integer, DamageType> Initialized after library registration.

    TSKHANDLES = {
        DAMAGE_TYPE_TEMPLATE = "h784f42a9g95e6g4a55gb2b5g3ef52f6bbee6", -- "[1] Damage"
    },

    ---@type table<DamageType, DamageLib_DamageType>
    DAMAGE_TYPES = {
        None = {
            ID = 0,
            StringID = "None",
            NameHandle = "h37e16e2cgb2c7g46a6g942egb35eb0a825f1",
            LowercaseNameHandle = "hed58f57eg7b16g4b63g812ega842be8f1953",
            Color = "C80030",
        },
        Physical = {
            ID = 1,
            StringID = "Physical",
            NameHandle = "ha6c38456g4c6ag47b2gae87g60a26cf4bf7b",
            LowercaseNameHandle = "h666fff63g3033g4063gb364g72c7b70c0969",
            Color = "A8A8A8",
        },
        Piercing = {
            ID = 2,
            StringID = "Piercing",
            NameHandle = "h22f6b7bcgc548g49cbgbc04g9532e893fb55",
            LowercaseNameHandle = "h5022bb08ge403g4110gb272g043a6b5fcd05",
            Color = "C80030",
        },
        Corrosive = {
            ID = 3,
            StringID = "Corrosive",
            NameHandle = "hcbe11fb4g22adg4b10g938bg467f8c41107c", -- "Physical Armour reduction"
            LowercaseNameHandle = nil,
            Color = "797980",
        },
        Magic = {
            ID = 4,
            StringID = "Magic",
            NameHandle = "hd01e5f46g36d4g48f5g8550gabdc4bef1f04", -- "Magic Armour reduction"
            LowercaseNameHandle = nil,
            Color = "7F00FF",
        },
        Chaos = {
            ID = 5,
            StringID = "Chaos",
            NameHandle = "hf43ec8a1gb6c4g421dg983cg01535ee1bcdf",
            LowercaseNameHandle = nil,
            Color = "C80030",
        },
        Fire = {
            ID = 6,
            StringID = "Fire",
            NameHandle = "h051b2501g091ag4c93ga699g407cd2b29cdc",
            LowercaseNameHandle = "h72d4ba14gd1c7g4878ga2d6g940925b0332c",
            Color = "FE6E27",
        },
        Air = {
            ID = 7,
            StringID = "Air",
            NameHandle = "h1cea7e28gc8f1g4915ga268g31f90767522c",
            LowercaseNameHandle = "he90b8313g9f8dg4dddg871ag3deb9dfeeb10",
            Color = "7D71D9",
        },
        Water = {
            ID = 8,
            StringID = "Water",
            NameHandle = "hd30196cdg0253g434dga42ag12be43dac4ec",
            LowercaseNameHandle = "h67923c72gd6f7g4430gab14gd893c772d522",
            Color = "4197E2",
        },
        Earth = {
            ID = 9,
            StringID = "Earth",
            NameHandle = "h85fee3f4g0226g41c6g9d38g83b7b5bf96ba",
            LowercaseNameHandle = "h0d765ef8gca43g4e90ga3cegbb41065861cb",
            Color = "7F3D00",
        },
        Poison = {
            ID = 10,
            StringID = "Poison",
            NameHandle = "haa64cdb8g22d6g40d6g9918g61961514f70f",
            LowercaseNameHandle = "h7ecb0492g363fg4b80gb9e2gdb068327e2f8",
            Color = "65C900",
        },
        Shadow = {
            ID = 11,
            StringID = "Shadow",
            NameHandle = "hf4632a8fg42a7g4d53gbe26gd203f28e3d5e", -- "Rot"
            LowercaseNameHandle = "h168f52b6g342ag42e0g99d0g47d94b7363c8", -- "rot"
            Color = "797980",
        },
        Sulfuric = {
            ID = 12,
            StringID = "Sulfuric",
            NameHandle = nil,
            LowercaseNameHandle = nil,
            Color = "C7A758",
        },
        -- TODO is this one even usable?
        Sentinel = {
            ID = 13,
            StringID = "Sentinel",
            NameHandle = "h37e16e2cgb2c7g46a6g942egb35eb0a825f1",
            LowercaseNameHandle = "hed58f57eg7b16g4b63g812ega842be8f1953",
            Color = "C80030",
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

---@class DamageLib_DamageType
---@field ID integer
---@field StringID DamageType
---@field NameHandle TranslatedStringHandle?
---@field LowercaseNameHandle TranslatedStringHandle?
---@field Color htmlcolor Color used in tooltips. TODO is this the same color for combat log, etc.?

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the definition for a damage type.
---@param damageType DamageType|integer
---@return DamageLib_DamageType
function Damage.GetDamageTypeDefinition(damageType)
    if type(damageType) == "number" then -- Integer ID.
        damageType = Damage._DamageTypeIDToStringID[damageType]
    end

    return Damage.DAMAGE_TYPES[damageType]
end