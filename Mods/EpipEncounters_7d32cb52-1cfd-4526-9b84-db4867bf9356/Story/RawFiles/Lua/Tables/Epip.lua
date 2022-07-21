
Epip = {
    Features = {},
    _FeatureRegistrationOrder = {},

    PREFIXED_GUID = "EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356",
    VERSION = 1056, -- Also the story version.
    cachedAprilFoolsState = nil,
    _devMode = nil,

    ---@type table<string, OptionsSettingsOption>
    SETTINGS = {},
    SETTINGS_CATEGORIES = {},
}

---------------------------------------------
-- SETUP FEATURES
---------------------------------------------

-- Call to initialize a feature, setting its metatable and
-- initializing path overrides, as well as checking for required mods.
-- Should be done outside of any listener, as soon as the script loads.
function Epip.AddFeature(id, name, feature)
    Epip.InitializeFeature(id, name, feature)
    
    Epip.Features[id] = feature
end

function Epip.InitializeLibrary(id, lib)
    Epip.InitializeFeature(id, id, lib)
end

---@param requirePipPoem boolean? Whether a poem to Pip is required for this call to succeed. Defaults to false (which checks Extender dev mode instead)
---@return boolean
function Epip.IsDeveloperMode(requirePipPoem)
    local devMode = false

    -- Initialize _devMode variable
    if Epip._devMode == nil then
        Epip._devMode = Ext.IO.LoadFile("Epip_DevMode.txt") ~= nil
    end

    if requirePipPoem then
        devMode = Epip._devMode
    else
        devMode = Ext.Debug.IsDeveloperMode()
    end

    return devMode
end

function Epip.InitializeFeature(id, name, feature)
    setmetatable(feature, {__index = _Feature})

    feature.MODULE_ID = id

    feature.Name = name or id
    feature.REQUIRED_MODS = feature.REQUIRED_MODS or {}
    feature.FILEPATH_OVERRIDES = feature.FILEPATH_OVERRIDES or {}

    for ev,data in pairs(feature.Events) do
        if data.Legacy == false or feature.USE_LEGACY_EVENTS == false then
            feature:AddSubscribableEvent(ev)
        else
            feature:AddEvent(ev, data)
        end
    end

    for hook,data in pairs(feature.Hooks) do
        feature:AddHook(hook, data)
    end

    -- Check required mods
    local missingMods = {}
    for guid,modName in pairs(feature.REQUIRED_MODS) do
        if not Mod.IsLoaded(guid) then
            table.insert(missingMods, string.format("%s (%s)", guid, modName))
        end
    end

    -- Disable the feature if required mods are missing.
    if #missingMods > 0 then
        Ext.PrintWarning("[EPIP] Feature '" .. feature.Name .. "' has been disabled as some required mods are missing:")
        Ext.Dump(missingMods)

        feature:Disable("MISSING_MODS")
    else
        -- Add filepath overrides.
        for old,new in pairs(feature.FILEPATH_OVERRIDES) do
            Ext.IO.AddPathOverride(old, new)
        end

        feature._initialized = true

        -- Run init routine
        if feature.OnFeatureInit then
            feature:OnFeatureInit()
        end
    end

    table.insert(Epip._FeatureRegistrationOrder, feature)
end

if Ext.IsClient() then
    function Epip.InitializeUI(type, id, ui)
        Epip.InitializeFeature(id, ui.Name or id, ui)
        setmetatable(ui, {__index = Client.UI._BaseUITable})
    
        ui.UITypeID = type
    
        if ui.INPUT_DEVICE == "Controller" and not Client.IsUsingController() then
            ui:Disable()
        elseif ui.INPUT_DEVICE == "KeyboardMouse" and Client.IsUsingController() then
            ui:Disable()
        end
    
        Client.UI[id] = ui
    end

    function Epip.IsAprilFools()
        -- Minor optimisation
        if Epip.cachedAprilFoolsState == nil then
            local date = Client.GetDate()
            Epip.cachedAprilFoolsState = (date.Day == 1 and date.Month == 4)
        end

        -- Hotbar mod gets no festivities.
        return (Epip.cachedAprilFoolsState or Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "DEBUG_AprilFools") and not IS_IMPROVED_HOTBAR)
    end
end