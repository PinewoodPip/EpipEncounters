
---------------------------------------------
-- Compatibility for Majora's Fashion Sins.
-- Adds its templates to the Vanity feature.
---------------------------------------------

---@type Feature
local Majora = {
    DATA_PATH = "Mods/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Story/RawFiles/Lua/Epip/ContextMenus/Vanity/Data/Templates_MajoraFashionSins.json",
}

Epip.RegisterFeature("MajoraFashionSinsCompatibility", Majora)

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function()
    if Majora:IsEnabled() then
        -- Load templates data
        Client.UI.Vanity.LoadTemplateData(Majora.DATA_PATH)
    end
end)