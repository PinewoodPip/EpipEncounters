
---------------------------------------------
-- Compatibility for Visitors From Cyseal.
-- Adds its templates to the Vanity feature.
---------------------------------------------

---@type Feature
local VFS = {
    DATA_PATH = "Mods/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Story/RawFiles/Lua/Epip/ContextMenus/Vanity/Data/Templates_VisitorsFromCyseal.json",

    PATH_OVERRIDES = {
        ["Public/VFC_Weapons_f21e7a68-c39c-4387-9a3f-04dfd216caba/Stats/Generated/Data/ItemProgressionVisuals.txt"] = "Mods/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Story/RawFiles/Lua/Empty.lua",
        ["Public/VFC_Weapons_f21e7a68-c39c-4387-9a3f-04dfd216caba/Stats/Generated/Data/ItemProgressionNames.txt"] = "Mods/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Story/RawFiles/Lua/Empty.lua",
    },
}

Epip.RegisterFeature("VisitorsFromCysealCompatibility", VFS)

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function()
    if VFS:IsEnabled() then
        -- Load templates data
        Client.UI.Vanity.LoadTemplateData(VFS.DATA_PATH)
    end
end)