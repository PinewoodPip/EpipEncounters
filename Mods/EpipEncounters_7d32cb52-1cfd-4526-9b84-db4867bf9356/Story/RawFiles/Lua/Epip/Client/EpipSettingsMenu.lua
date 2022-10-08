
local Menu = Epip.GetFeature("Feature_SettingsMenu")

---@type table<string, Feature_SettingsMenu_Tab>
local tabs = {
    ["EpipEncounters"] = {
        ID = "Epip Encounters",
        ButtonLabel = "Epip Encounters",
        HeaderLabel = "Epip Encounters",
        Elements = {
            "AutoIdentify",
            "ImmersiveMeditation",
            "ExaminePosition",
            {Type = "Label", Label = "Testing!!!"}
        }
    }
}

for moduleID,tab in pairs(tabs) do
    for i,entry in ipairs(tab.Elements) do
        if type(entry) == "string" then
            tab.Elements[i] = {Type = "Setting", Module = moduleID, ID = entry}
        end
    end

    Menu.RegisterModule(tab)
end