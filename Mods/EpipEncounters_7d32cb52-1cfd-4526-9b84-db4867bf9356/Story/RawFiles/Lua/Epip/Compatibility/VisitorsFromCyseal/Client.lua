
---------------------------------------------
-- Compatibility for Majora's Fashion Sins.
-- Adds its templates to the Vanity feature.
---------------------------------------------

local VFS = {
    DATA_PATH = "Mods/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Story/RawFiles/Lua/Epip/ContextMenus/Vanity/Data/Templates_VisitorsFromCyseal.json",

    REQUIRED_MODS = {
        [Data.Mods.VISITORS_FROM_CYSEAL] = "Visitors From Cyseal - Weapons Pack",
    },
}

Epip.AddFeature("VisitorsFromCysealCompatibility", "Vanity - Visitors From Cyseal Support", VFS)

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function()
    if VFS:IsEnabled() then
        -- Load templates data
        Client.UI.Vanity.LoadTemplateData(VFS.DATA_PATH)
    end
end)