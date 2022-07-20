
---------------------------------------------
-- Hotbar actions for Epic Encounters.
---------------------------------------------

local HA = {
    ---@type table<string, HotbarAction>
    Actions = {
        {
            ID = "EE_Meditate",
            Name = "Meditate",
            Icon = "hotbar_icon_nongachatransmute",
        },
        {
            ID = "EE_SourceInfuse",
            Name = "Source Infuse",
            Icon = "hotbar_icon_sp",
        },
    },
    REQUIRED_MODS = {
        [Mod.GUIDS.EE_CORE] = "Epic Encounters Core",
    },
}
local Hotbar = Client.UI.Hotbar

---------------------------------------------
-- SETUP
---------------------------------------------

function HA:OnFeatureInit()
    for i,action in ipairs(HA.Actions) do
        Hotbar.RegisterAction(action.ID, action)
    end
    
    -- Source Infuse
    Hotbar.RegisterActionListener("EE_SourceInfuse", "ActionUsed", function(char)
        Net.PostToServer("EPIPENCOUNTERS_Hotkey_SourceInfuse", {NetID = char.NetID})
    end)
    
    -- Meditate
    Hotbar.RegisterActionListener("EE_Meditate", "ActionUsed", function(char)
        Net.PostToServer("EPIPENCOUNTERS_Hotkey_Meditate", {NetID = char.NetID})
    end)
    
    -- Changelog
    Hotbar.RegisterActionListener("EPIP_OpenChangelog", "ActionUsed", function(char)
        OpenLatestChangelog()
    end)
    
    -- place these by default on the hotkeys bar
    Hotbar.SetHotkeyAction(11, "EE_Meditate")
    Hotbar.SetHotkeyAction(12, "EE_SourceInfuse")
end

Epip.AddFeature("EE_HotbarActions", "EE_HotbarActions", HA)