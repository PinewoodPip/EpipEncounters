
local Rendal = {
    DATA_PATH = "Mods/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Story/RawFiles/Lua/Epip/ContextMenus/Vanity/Data/Templates_RendalNPCArmor.json",
    REQUIRED_MODS = {
        [Data.Mods.RENDAL_NPC_ARMOR] = "Rendal's NPC Armor",
    }
}
Epip.AddFeature("RendalNPCArmorCompatibility", "RendalNPCArmorCompatibility", Rendal)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.Vanity:RegisterHook("GenerateTemplateName", function(name, template, data)
    if data.Mod == Data.Mods.RENDAL_NPC_ARMOR then
        -- Remove Rendal prefix from name
        name = string.gsub(name, "^Rendal  ?", "")
    end

    return name
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function Rendal.__Setup()
    Client.UI.Vanity.LoadTemplateData(Rendal.DATA_PATH)
end