
local function DumpUIInstances()
    print("Finding UIs...")
    for i=0,4000,1 do
        local ui = Ext.UI.GetByType(i)

        if ui then
            print("Found UI: " .. ui:GetTypeId() .. " " .. ui.Path)
        end
    end
end

local function SoundTest()
    print("Testing sounds...")
    print("Exit console to see IDs, and turn off mute-when-out-of-focus in game settings.")
    local sounds = Utilities.LoadJson("Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/sound_test.json", "data")
    local delay = 2 -- 2 seconds delay so you can exit console in time
    local DELAY = 0.65

    for guid,sound in pairs(sounds) do
        Client.Timer.Start("soundTest_" .. sound, delay, function()
            print("Playing", sound)
            Client.UI.Time:PlaySound(sound)
        end)

        delay = delay + DELAY
    end
end

local commands = {
    ["bruteforceuitypes"] = DumpUIInstances,
    ["soundtest"] = SoundTest,
}

for name,command in pairs(commands) do
    Ext.RegisterConsoleCommand(name, command)
end