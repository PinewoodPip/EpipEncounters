
local anims = {}

local function PlayNext()
    if #anims > 0 then
        Osiris.PlayAnimation(Osiris.CharacterGetHostCharacter(), anims[1], "PIP_AnimTest_Finished")

        print(anims[1])

        table.remove(anims, 1)
    end
end

local function AnimTest()
    print("Testing animations...")
    print("Exit console to see IDs, or look at the combat log.")

    anims = IO.LoadFile("Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/anim_test.json", "data")

    PlayNext()
end

Osiris.RegisterSymbolListener("StoryEvent", 2, "after", function(_, event)
    if event == "PIP_AnimTest_Finished" then
        PlayNext()
    end
end)

local function GenerateOsiEventIDEHelpers(_, outputPath)
    Epip.GetFeature("Feature_OsirisIDEAnnotationGenerator").GenerateEventAnnotations("Mods/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Story/story_header.div", outputPath)
end

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
    ["animtest"] = AnimTest,
    ["generateosieventidehelpers"] = GenerateOsiEventIDEHelpers,
    ["fixdyestats"] = FixDyeStats,
}

for name,command in pairs(commands) do
    Ext.RegisterConsoleCommand(name, command)
end