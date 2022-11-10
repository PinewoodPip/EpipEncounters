
-- TODO finish.

local Settings = Settings

---@class Feature_LoadingScreenReplacement : Feature
local LoadingScreen = {
    _loadingScreenArt = {}, ---@type string[]

    ART_PATH = "Public/Game/Assets/Textures/UI/DOS2_Loadscreen_DE.dds",
}
Epip.RegisterFeature("LoadingScreenReplacement", LoadingScreen)

---------------------------------------------
-- METHODS
---------------------------------------------

---@return path
function LoadingScreen.GetRandomArt()
    local arts = LoadingScreen._loadingScreenArt
    local rand = Ext.Random(1, #arts)

    return arts[rand]
end

---@param path path
function LoadingScreen.RegisterArt(path)
    table.insert(LoadingScreen._loadingScreenArt, path)
end

---@param state boolean
function LoadingScreen.Toggle(state)
    LoadingScreen:DebugLog("Toggling loading screen replacement", state)

    if state then
        Ext.IO.AddPathOverride(LoadingScreen.ART_PATH, LoadingScreen.GetRandomArt())
    else
        Ext.IO.AddPathOverride(LoadingScreen.ART_PATH, LoadingScreen.ART_PATH)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the setting being changed.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    local setting = ev.Setting

    if setting.ModTable == "EpipEncounters" and setting.ID == "LoadingScreen" then
        LoadingScreen.Toggle(ev.Value)
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

LoadingScreen.RegisterArt("Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/Assets/Textures/epip_encounters_loading_bg.dds")