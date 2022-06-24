
---------------------------------------------
-- Adds a hotbar action for portable respec mirror.
---------------------------------------------

local Mirror = {
    REQUIRED_MODS = {
        [Data.Mods.PORTABLE_RESPEC_MIRROR] = "Portable Respec Mirror (FJ Edition)",
    },
}
local Hotbar = Client.UI.Hotbar

function Mirror:OnFeatureInit()
    Hotbar.RegisterAction("PortableRespecMirror_Use", {
        Name = "Respec",
        Icon = "hotbar_icon_magic",
    })

    Hotbar.RegisterActionListener("PortableRespecMirror_Use", "ActionUsed", function(char, actionData, buttonIndex)
        Game.Net.PostToServer("EPIPENCOUNTERS_Hotkey_Respec", {NetID = char.NetID})
    end)
end

Epip.AddFeature("PortableRespecMirrorCompatibility", "PortableRespecMirrorCompatibility", Mirror)