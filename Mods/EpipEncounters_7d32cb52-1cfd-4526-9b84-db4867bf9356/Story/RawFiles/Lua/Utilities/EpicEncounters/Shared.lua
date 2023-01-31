
---@class EpicEncountersLib : Library
EpicEncounters = {}
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
    return Mod.IsLoaded(Mod.GUIDS.EE_ORIGINS)
end