
---@class EpicEncountersLib : Library
EpicEncounters = {
    TranslatedStrings = {
        Embodiment_Force = {
            Handle = "h53c27242gdc58g43f2g999fg1305a5e6aeaa",
            Text = "Force",
            ContextDescription = [[Embodiment name]],
        },
        Embodiment_Entropy = {
            Handle = "h53d49f75g5520g48e1g8fc0gb793134dd234",
            Text = "Entropy",
            ContextDescription = [[Embodiment name]],
        },
        Embodiment_Form = {
            Handle = "haa562285gecd2g41efg9db6gb3aa2b0b32b3",
            Text = "Form",
            ContextDescription = [[Embodiment name]],
        },
        Embodiment_Inertia = {
            Handle = "hca631646g887ag4958g8efcgc0adb2cb7969",
            Text = "Inertia",
            ContextDescription = [[Embodiment name]],
        },
        Embodiment_Life = {
            Handle = "hd8b2a948g5b60g41dfgae0eg4efb456d8c24",
            Text = "Life",
            ContextDescription = [[Embodiment name]],
        },
    },
}
Epip.InitializeLibrary("EpicEncounters", EpicEncounters)

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether EE Core is loaded.
---@return boolean
function EpicEncounters.IsEnabled()
    local devSettingValue = Settings.GetSettingValue("Epip_Developer", "Developer_SimulateNoEE")

    return Mod.IsLoaded(Mod.GUIDS.EE_CORE) and devSettingValue == false
end

---Returns whether EE Origins is loaded.
---@return boolean
function EpicEncounters.IsOrigins()
    return Mod.IsLoaded(Mod.GUIDS.EE_ORIGINS) -- Not really necessary to check for Core as well since it's a dependency.
end
