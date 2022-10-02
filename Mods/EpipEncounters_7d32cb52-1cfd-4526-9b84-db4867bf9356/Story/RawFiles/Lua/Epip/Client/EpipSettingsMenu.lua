
local Menu = Epip.GetFeature("Feature_SettingsMenu")

---@type table<string, Feature_SettingsMenu_Tab>
local tabs = {
    ["EpipEncounters"] = {
        ID = "Epip Encounters",
        ButtonLabel = "Epip Encounters",
        HeaderLabel = "Epip Encounters",
        Settings = {
            "AutoIdentify",
            "ImmersiveMeditation",
            "ExaminePosition",
        }
    }
}

for moduleID,tab in pairs(tabs) do
    for i,settingID in ipairs(tab.Settings) do
        tab.Settings[i] = {Module = moduleID, ID = settingID}
    end

    Menu.RegisterModule(tab)
end