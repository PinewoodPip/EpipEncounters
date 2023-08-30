
local function FixDyeStats()
    local char = Osiris.CharacterGetHostCharacter()

    Osiris.CharacterAddAttribute(char, "Strength", -10);
    Osiris.CharacterAddAttribute(char, "Finesse", -10);
    Osiris.CharacterAddAttribute(char, "Intelligence", -10);
    Osiris.CharacterAddAttribute(char, "Memory", -10);
    Osiris.CharacterAddAbility(char, "AirSpecialist", -4);
    Osiris.CharacterAddAbility(char, "WaterSpecialist", -4);
    Osiris.CharacterAddAbility(char, "EarthSpecialist", -4);
    Osiris.CharacterAddAbility(char, "FireSpecialist", -4);
    Osiris.CharacterAddAbility(char, "Necromancy", -4);
    Osiris.CharacterAddAbility(char, "RangerLore", -4);
    Osiris.CharacterAddAbility(char, "WarriorLore", -4);
    Osiris.CharacterAddAbility(char, "RogueLore", -4);
    Osiris.CharacterAddAbility(char, "Summoning", -4);
    Osiris.CharacterAddAbility(char, "Polymorph", -4);

    Ext.Utils.Print("Stat penalties applied")
end

local commands = {
    ["fixdyestats"] = FixDyeStats,
}

for name,command in pairs(commands) do
    Ext.RegisterConsoleCommand(name, command)
end