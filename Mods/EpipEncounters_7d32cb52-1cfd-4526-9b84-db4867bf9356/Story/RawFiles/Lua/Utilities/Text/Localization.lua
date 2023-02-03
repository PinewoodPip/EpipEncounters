
-- Automatically load localization files from mod folders.
local mods = Ext.Mod.GetLoadOrder()
for _,guid in ipairs(mods) do
    local mod = Ext.Mod.GetMod(guid)
    local currentLanguage = Text.GetCurrentLanguage()
    local modID = mod.Info.Directory

    -- Load localization override for each mod with a ModTable
    for modTableID,_ in pairs(Mods) do
        local path = string.format('Mods/%s/Localization/Epip/%s/%s.json', modID, currentLanguage, modTableID)

        Text.LoadLocalization(currentLanguage, path)
    end
end