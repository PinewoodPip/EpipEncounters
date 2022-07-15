
local anims = {}
local DELAY = 1

local function PlayNext()
    if #anims > 0 then
        PlayAnimation(CharacterGetHostCharacter(), anims[1], "PIP_AnimTest_Finished")

        print(anims[1])

        table.remove(anims, 1)
    end
end

local function AnimTest()
    print("Testing animations...")
    print("Exit console to see IDs, or look at the combat log.")

    anims = Utilities.LoadJson("Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/anim_test.json", "data")

    PlayNext()
end

local function TagFetchPerformance()
    local guid = CharacterGetHostCharacter()
    local now = Ext.MonotonicTime()
    local tests = 10000000

    print(tests .. " calls:")

    for i=1,tests,1 do
        Osi.IsTagged(guid, "TEST_TAG")
    end

    local time = Ext.MonotonicTime()  - now
    print("Osi.IsTagged(): " .. time .. "ms")

    now = Ext.MonotonicTime()
    for i=1,tests,1 do
        Ext.GetCharacter(guid):HasTag("TEST_TAG")
    end

    time = Ext.MonotonicTime()  - now
    print("EsvCharacter:HasTag(): " .. time .. "ms")

    now = Ext.MonotonicTime()
    local char = Ext.GetCharacter(guid)
    for i=1,tests,1 do
        char:HasTag("TEST_TAG")
    end

    time = Ext.MonotonicTime()  - now
    print("EsvCharacter:HasTag() without refetching the character: " .. time .. "ms")
end

Osiris.RegisterSymbolListener("StoryEvent", 2, "after", function(obj, event)
    if event == "PIP_AnimTest_Finished" then
        PlayNext()
    end
end)

local commands = {
    ["animtest"] = AnimTest,
    ["worryaboutsuchsmallthings"] = TagFetchPerformance,
}

for name,command in pairs(commands) do
    Ext.RegisterConsoleCommand(name, command)
end