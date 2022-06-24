
---------------------------------------------
-- Hotbar actions added by Epip.
---------------------------------------------

local Hotbar = Client.UI.Hotbar

---@type table<string, HotbarAction>
local actions = {
    {
        ID = "EPIP_TogglePartyLink",
        Name = "Chain/Unchain",
        Icon = "hotbar_icon_infinity",
    },
    {
        ID = "EPIP_UserRest",
        Name = "Bedroll Rest",
        Icon = "hotbar_icon_laureate",
    },
}

for i,action in pairs(actions) do
    Hotbar.RegisterAction(action.ID, action)
end

-- Toggle Party Link
Hotbar.RegisterActionListener("EPIP_TogglePartyLink", "ActionUsed", function(char)
    Game.Net.PostToServer("EPIPENCOUNTERS_Hotkey_TogglePartyLink", {NetID = char.NetID})
end)

-- Bedroll rest
Hotbar.RegisterActionListener("EPIP_UserRest", "ActionUsed", function(char)
    Game.Net.PostToServer("EPIPENCOUNTERS_Hotkey_UserRest", {NetID = char.NetID})
end)

-- place these by default on the hotkeys bar
Hotbar.SetHotkeyAction(9, "EPIP_UserRest")
Hotbar.SetHotkeyAction(10, "EPIP_TogglePartyLink")

-- Journal action
if not Epip.IS_IMPROVED_HOTBAR then
    Hotbar.RegisterAction("EPIP_Journal", {
        Name = "Journal",
        Icon = "hotbar_icon_announcement",
    })

    Hotbar.RegisterActionListener("EPIP_Journal", "ActionUsed", function(char)
        Client.UI.Journal.Setup()
    end)
end