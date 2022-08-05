
local Options = Client.UI.OptionsInput

Options.RegisterTab("EpipEncounters", {
    Name = "Epip Encounters",
    Keybinds = {
        {Name = "Quick Examine", ID = "EpipEncounters_QuickExamine", DefaultInput1 = {Keys = {"v"}}},
        {Name = "Meditate", ID = "EpicEncounters_Meditate"},
        {Name = "Source Infuse", ID = "EpipEncounters_SourceInfuse"},
        {Name = "Debug Teleport", ID = "EpipEncounters_DebugTeleport", DeveloperOnly = true},
        {Name = "Debug Teleport (Party)", ID = "EpipEncounters_DebugTeleport_Party", DeveloperOnly = true},
        {Name = "Debug Copy Identifier", ID = "EpipEncounters_Debug_CopyIdentifier", DeveloperOnly = true, DefaultInput1 = {Keys = {"lctrl", "c"}}},
        {Name = "Hotbar Action 1 (bottom row)", ID = "EpipEncounters_Hotbar_1"},
        {Name = "Hotbar Action 2 (bottom row)", ID = "EpipEncounters_Hotbar_2"},
        {Name = "Hotbar Action 3 (bottom row)", ID = "EpipEncounters_Hotbar_3"},
        {Name = "Hotbar Action 4 (bottom row)", ID = "EpipEncounters_Hotbar_4"},
        {Name = "Hotbar Action 5 (bottom row)", ID = "EpipEncounters_Hotbar_5"},
        {Name = "Hotbar Action 6 (bottom row)", ID = "EpipEncounters_Hotbar_6"},
        {Name = "Hotbar Action 7 (top row)", ID = "EpipEncounters_Hotbar_7"},
        {Name = "Hotbar Action 8 (top row)", ID = "EpipEncounters_Hotbar_8"},
        {Name = "Hotbar Action 9 (top row)", ID = "EpipEncounters_Hotbar_9"},
        {Name = "Hotbar Action 10 (top row)", ID = "EpipEncounters_Hotbar_10"},
        {Name = "Hotbar Action 11 (top row)", ID = "EpipEncounters_Hotbar_11"},
        {Name = "Hotbar Action 12 (top row)", ID = "EpipEncounters_Hotbar_12"},

        {Name = "Move Furniture", ID = "EpipEncounters_Housing_MoveFurniture", DeveloperOnly = true},
        {Name = "Log RootTemplate", ID = "EpipEncounters_Debug_LogRootTemplate", DeveloperOnly = true},
    },
})

Options.Events.ActionExecuted:RegisterListener(function (action, _)
    if action == "EpicEncounters_Meditate" then
        Net.PostToServer("EPIPENCOUNTERS_Hotkey_Meditate", {
            NetID = Client.GetCharacter().NetID,
        })
    elseif action == "EpipEncounters_SourceInfuse" then
        Net.PostToServer("EPIPENCOUNTERS_Hotkey_SourceInfuse", {NetID = Client.GetCharacter().NetID})
    end
end)