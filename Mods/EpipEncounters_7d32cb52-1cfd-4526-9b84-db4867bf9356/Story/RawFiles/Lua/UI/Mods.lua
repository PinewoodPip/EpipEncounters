
---------------------------------------------
-- Not done yet as it appears invokes/calls are not captured while in menu.
---------------------------------------------

local Mods = {
}
Epip.InitializeUI(Client.UI.Data.UITypes.mods, "Mods", Mods)

---------------------------------------------
-- LISTENERS
---------------------------------------------

Mods:RegisterInvokeListener("fadeIn", function(ev)
    print(ev.Args)
end)

Mods:RegisterCallListener("PlaySound", function(ev)
    print(ev.Args)
end)