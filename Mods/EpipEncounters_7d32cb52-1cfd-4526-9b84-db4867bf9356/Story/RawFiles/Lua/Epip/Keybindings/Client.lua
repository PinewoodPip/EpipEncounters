
---------------------------------------------
-- Temporary script to register keybindings until a better API exists to register them onto the UI.
---------------------------------------------

local CommonStrings = Text.CommonStrings

---@type InputLib_Action[]
local keybinds = {
    -- Developer
    {Name = "Debug Teleport", ID = "EpipEncounters_DebugTeleport", DeveloperOnly = true},
    {Name = "Debug Copy Identifier", ID = "EpipEncounters_Debug_CopyIdentifier", DeveloperOnly = true, DefaultInput1 = {Keys = {"lctrl", "c"}}},
    {Name = "Debug Open Features Menu", ID = "EpipEncounters_Debug_OpenDebugMenu", DeveloperOnly = true, DefaultInput1 = {Keys = {"lctrl", "b"}}},
    {Name = "Debug Generic Hookable Hotkey", ID = "EpipEncounters_Debug_Generic", DeveloperOnly = true, DefaultInput1 = {Keys = {"lctrl", "e"}}},
    {Name = "Copy Position", ID = "EpipEncounters_Debug_CopyPosition", DeveloperOnly = true, DefaultInput1 = {Keys = {"lshift", "t"}}},

    {Name = "Log RootTemplate", ID = "EpipEncounters_Debug_LogRootTemplate", DeveloperOnly = true},
    -- {Name = "Open Cheats", ID = "EpipEncounters_DebugCheats_OpenUI", DeveloperOnly = true, DefaultInput1 = {Keys = {"g"}}}, -- Removed until the feature is more finished.

    {Name = "Open Quick Find", ID = "EpipEncounters_QuickFind", DefaultInput1 = {Keys = {"lctrl", "f"}}, Icon = "hotbar_icon_inventory"},

    -- Misc
    {Name = "Toggle Tooltip Scrolling", ID = "EpipEncounters_ScrollTooltip", DefaultInput1 = {Keys = {"middle"}}},
    {Name = "Toggle World Item Tooltips", ID = "EpipEncounters_ToggleWorldTooltips"},
    {Name = "Examine", ID = "EpipEncounters_Examine"},

    -- Hotbar
    {Name = "Hotbar Toggle Extra Bars Visibility", ID = "EpipEncounters_Hotbar_ToggleVisibility"},
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

    -- Housing
    {Name = "Housing: Select Furniture", ID = "EpipEncounters_Housing_MoveFurniture", DeveloperOnly = true},
    {Name = "Housing: Rotate Furniture (+ Axis)", ID = "EpipEncounters_Housing_RotateFurniture_Plus", DeveloperOnly = true},
    {Name = "Housing: Rotate Furniture (- Axis)", ID = "EpipEncounters_Housing_RotateFurniture_Minus", DeveloperOnly = true},
    {Name = "Housing: Raise Furniture", ID = "EpipEncounters_Housing_RaiseFurniture", DeveloperOnly = true, DefaultInput1 = {Keys = {"lctrl", "wheel_ypos"}}},
    {Name = "Housing: Lower Furniture", ID = "EpipEncounters_Housing_LowerFurniture", DeveloperOnly = true, DefaultInput1 = {Keys = {"lctrl", "wheel_yneg"}}},

    -- Fishing
    {Name = "Fishing: Open Collection Log", ID = "EpipEncounters_Fishing_OpenCollectionLog", DeveloperOnly = true, DefaultInput1 = {Keys = {"lshift", "f"}}},
}

-- Add EE-only keybinds
if EpicEncounters.IsEnabled() then
    table.insert(keybinds, {
        ID = "EpicEncounters_Meditate",
        Name = CommonStrings.Meditate,
        Icon = "hotbar_icon_nongachatransmute",
    })
    table.insert(keybinds, {
        ID = "EpipEncounters_SourceInfuse",
        Name = CommonStrings.SourceInfuse,
        Icon = "hotbar_icon_sp",
    })
end

for _,binding in ipairs(keybinds) do
    Client.Input.RegisterAction(binding.ID, binding)
end