
---------------------------------------------
-- Registers Epip settings to the OptionsSettings UI.
---------------------------------------------

if not IS_IMPROVED_HOTBAR then
    Client.UI.OptionsSettings.RegisterMod("EpipEncounters", {
        SideButtonLabel = "Epip Encounters",
        TabHeader = Text.Format("Epip Encounters", {Color = "7e72d6", Size = 23}),
    })

    for i,v in ipairs(Epip.SETTINGS_CATEGORIES) do
        Client.UI.OptionsSettings.RegisterOptions("EpipEncounters", v)
    end
end