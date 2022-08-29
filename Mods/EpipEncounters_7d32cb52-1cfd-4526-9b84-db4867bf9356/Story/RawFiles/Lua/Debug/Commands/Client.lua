
local function DumpUIInstances()
    print("Finding UIs...")
    for i=0,4000,1 do
        local ui = Ext.UI.GetByType(i)

        if ui then
            print("Found UI: " .. ui:GetTypeId() .. " " .. ui.Path)
        end
    end
end

local function TestActionHandles()
    for id,action in pairs(Stats.Actions) do
        print(id, action:GetName(), action:GetName(true), action:GetDescription())
    end
end

local function SoundTest()
    print("Testing sounds...")
    print("Exit console to see IDs, and turn off mute-when-out-of-focus in game settings.")
    local sounds = Utilities.LoadJson("Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/sound_test.json", "data")
    local delay = 2 -- 2 seconds delay so you can exit console in time
    local DELAY = 0.65

    for _,sound in pairs(sounds) do
        if not sound:match("_GM_") then
            Timer.Start("soundTest_" .. sound, delay, function()
                print("Playing", sound)
                Client.UI.Time:PlaySound(sound)
            end)
    
            delay = delay + DELAY
        end
    end
end

local commands = {
    ["bruteforceuitypes"] = DumpUIInstances,
    ["soundtest"] = SoundTest,
    ["testactionhandles"] = TestActionHandles,
}

for name,command in pairs(commands) do
    Ext.RegisterConsoleCommand(name, command)
end