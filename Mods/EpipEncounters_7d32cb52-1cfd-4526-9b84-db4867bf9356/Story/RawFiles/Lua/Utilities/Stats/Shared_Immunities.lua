
---@type table<string, StatsLib_Immunity>
Stats.Immunities = {
    Acid = {
        NameHandle = "hf507641cg021eg4d43ga010gb7b27421c40b",
    },
    Bleeding = {
        NameHandle = "he7ec9e93g750eg4538g9d87g989c66d27bc9",
    },
    Blessed = {
        NameHandle = "h18b65055g123ag4d72gb0afg7f4eeea7270b",
    },
    Blind = {
        NameHandle = "h95b2ee3dg5689g456fg82d9ge0daea8c0337",
    },
    Burn = {
        NameHandle = "h59e5e5e0g4b5fg4f9cg8395g13eb81a9325c",
    },
    Charm = {
        NameHandle = "h30fc0122g6378g408cgac6fg6e3bcb3c852b",
    },
    Chicken = {
        NameHandle = "h97e21ae8g0d85g44d8g9ac0g3917aa5ab8d0",
    },
    Chilled = {
        NameHandle = "ha15e9170g189bg42dag8cbdg68bc6363dac7",
    },
    Clairvoyant = {
        NameHandle = "h386f194eg7bf3g4214g81f8g325fd5b2c38a",
    },
    Crippled = {
        NameHandle = "he2818248g8662g4db3g8facgdc4539a9b781",
    },
    Cursed = {
        NameHandle = "hf32d4e02g103cg4dddgbb6fgdcc2ff63efc5",
    },
    Decaying = {
        NameHandle = "hbc2789fegb2deg4952ga436ga8a0aad070bf",
    },
    Disarmed = {
        NameHandle = "ha582d6bcg2279g465bg9cd8g728fbb9d7a1e",
    },
    Diseased = {
        NameHandle = "h791f1994g94e9g4471g9e10g398f8d194c90",
    },
    Fear = {
        NameHandle = "h6f38a9b4gc4deg4318g9f6cg4d073b48bde2",
    },
    Freeze = {
        NameHandle = "h07a85ff5g0167g4189g9033gf91fd00071aa",
    },
    Hasted = {
        NameHandle = "h6feb5d8bgb0bcg4a66g8cc3g7f7bc00fd565",
    },
    InfectiousDiseased = {
        NameHandle = "h791f1994g94e9g4471g9e10g398f8d194c90", -- TODO
    },
    Invisibility = {
        NameHandle = "he6325c0cg1995g4585gad82g050fda70ba65",
    },
    Knockdown = {
        NameHandle = "hdfa48bb0g5f7dg4756gb6c8g8835b5d8950c",
    },
    Madness = {
        NameHandle = "h66739cceg40b9g4efcgaabbgd5136091bec9",
    },
    Petrified = {
        NameHandle = "hf2cfd547ga22ag4992g8ed4g723b97f1f746",
    },
    Poison = {
        NameHandle = "h3252bb32g9bcfg4dd4gbc9dg5839ad5b509a",
    },
    Regenerating = {
        NameHandle = "he6959aa5g46aeg4cdegb66ag480eeb629c06",
    },
    ShacklesOfPain = {
        NameHandle = "hd5551babge481g41f2gb8e4g16761d19b39d",
    },
    Shocked = {
        NameHandle = "h8791e8c1g0260g407bg8af1gbb8e121c3c3e",
    },
    Sleeping = {
        NameHandle = "h6072e085g3c2ag4be9ga0abg2e0d0919fa2e",
    },
    Slipping = {
        NameHandle = "hf866dbebgab10g4913g8d4agaff311049d22",
    },
    Slowed = {
        NameHandle = "hb016fee2g5bc4g437dgbf8fg25fde21dd319",
    },
    Stun = {
        NameHandle = "hfb372aebg67b5g4336gb939g2c43d1ba610d",
    },
    Suffocating = {
        NameHandle = "h227945eeg40c9g446cgbc3dg0f9915fe7165",
    },
    Taunted = {
        NameHandle = "hccbbbbdfgf005g48bfg9306gbcad60055316",
    },
    Thrown = {
        NameHandle = "hfa754958gff75g4474g8cd5g508b4fb7a984",
    },
    Warm = {
        NameHandle = "h92aa75d2ge0b7g4e42g8a6cg530cffa7cd79",
    },
    Weak = {
        NameHandle = "hb69a3b34g75bcg4a7fga22dgb8d1d2f4545b",
    },
    Web = {
        NameHandle = "h758c25fcgc899g4016g8967g1812cf70e353",
    },
    Wet = {
        NameHandle = "h647ebe97gb196g4d69ga282g57df685c101a",
    },
}

---------------------------------------------
-- METHODS
---------------------------------------------

---@param name StatsLib_ImmunityID
---@return StatsLib_Immunity
function Stats.GetImmunity(name)
    return Stats.Immunities[name]
end

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias StatsLib_ImmunityID string TODO

---@class StatsLib_Immunity : I_Describable
local _Immunity = {
    NameHandle = nil,
}
Interfaces.Apply(_Immunity, "I_Describable")

function _Immunity:GetDescription()
    return Text.GetTranslatedString("h0b55e55fg0b1dg4c92g899egca5204be3932"):gsub("[1]", self:GetName())
end

---@param data StatsLib_Immunity
---@return StatsLib_Immunity
function _Immunity._Create(data)
    Inherit(data, _Immunity)

    return data
end

---------------------------------------------
-- SETUP
---------------------------------------------

for _,immunity in pairs(Stats.Immunities) do
    _Immunity._Create(immunity)
end