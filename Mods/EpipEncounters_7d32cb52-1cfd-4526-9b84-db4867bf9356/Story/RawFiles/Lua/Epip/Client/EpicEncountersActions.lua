
---------------------------------------------
-- Hotbar actions for Epic Encounters.
---------------------------------------------

local Hotbar = Client.UI.Hotbar

---@type Feature
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
Epip.RegisterFeature("EE_HotbarActions", HA)

---------------------------------------------
-- SETUP
---------------------------------------------

function HA:OnFeatureInit()
    for _,action in ipairs(HA.Actions) do
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
    
    -- place these by default on the hotkeys bar
    Hotbar.SetHotkeyAction(11, "EE_Meditate")
    Hotbar.SetHotkeyAction(12, "EE_SourceInfuse")
end