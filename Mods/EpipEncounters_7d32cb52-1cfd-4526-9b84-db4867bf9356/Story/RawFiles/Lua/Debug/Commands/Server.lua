
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

local commands = {
    ["animtest"] = AnimTest,
}

for name,command in pairs(commands) do
    Ext.RegisterConsoleCommand(name, command)
end