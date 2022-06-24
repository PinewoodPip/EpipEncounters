
local Options = Client.UI.OptionsInput

Options.RegisterTab("EpipEncounters", {
    Name = "Epip Encounters",
    Label = Text.Format("If you wish to use extra mouse buttons for these hotkeys, please bind the 'Special Binding X' keybinds in the normal menu and use them to set these custom ones.", {Size = 15}),
    Keybinds = {
        {Name = "Meditate", ID = "EpicEncounters_Meditate"},
        {Name = "Source Infuse", ID = "EpipEncounters_SourceInfuse"},
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
    },
})

Options.Events.ActionExecuted:RegisterListener(function (action, binding)
    if action == "EpicEncounters_Meditate" then
        Game.Net.PostToServer("EPIPENCOUNTERS_Hotkey_Meditate", {
            NetID = Client.GetCharacter().NetID,
        })
    elseif action == "EpipEncounters_SourceInfuse" then
        Game.Net.PostToServer("EPIPENCOUNTERS_Hotkey_SourceInfuse", {NetID = Client.GetCharacter().NetID})
    end
end)