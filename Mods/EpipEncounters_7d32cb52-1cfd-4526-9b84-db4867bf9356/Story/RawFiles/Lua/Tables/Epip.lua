
Epip = {
    Features = {}, ---@type table<string, Feature> Legacy table.
    _Features = {}, ---@type table<string, table<string, Feature>>
    _FeatureRegistrationOrder = {},

    PREFIXED_GUID = "EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356",
    VERSION = 1059, -- Also the story version.
    cachedAprilFoolsState = nil,
    _devMode = nil,

    ---@type table<string, OptionsSettingsOption>
    SETTINGS = {},
    SETTINGS_CATEGORIES = {},
}

---------------------------------------------
-- METHODS
---------------------------------------------

---@deprecated Legacy call.
function Epip.AddFeature(id, name, feature)
    Epip.RegisterFeature(id, feature)
    
    Epip.Features[id] = feature
end

---Registers a feature, initializing its utility metatable and exposing it to other mods via GetFeature(). Should be called outside of any listener, as soon as the table is defined. This will also check for required path overrides and disable the feature if the required mods are not enabled.
---@param modTable string
---@param id string
---@param feature Feature
---@overload fun(id:string, feature:Feature)
function Epip.RegisterFeature(modTable, id, feature)
    -- Overload for Epip's built-in features
    if not feature and type(id) == "table" then 
        ---@diagnostic disable-next-line: cast-local-type
        modTable,id,feature = "EpipEncounters",modTable,id
    end

    Epip.InitializeFeature(id, feature.NAME or id, feature)
    feature.MOD_TABLE = modTable

    -- Initialize mod data
    if not Epip._Features[modTable] then
        Epip._Features[modTable] = {Features = {}}
    end
    local modData = Epip._Features[modTable]

    -- Store the feature in the legacy table as well.
    if modTable == "EpipEncounters" then
        Epip.Features[id] = feature
    end

    modData.Features[id] = feature
end

---@overload fun(id:string):Feature
---@param modTable string
---@param id string
---@return Feature
function Epip.GetFeature(modTable, id)
    -- Overload to get features built-in into Epip.
    if id == nil then
        modTable, id = "EpipEncounters", modTable
    end
    local modData = Epip._Features[modTable]
    local feature

    if modData then
        feature = modData.Features[id]
    end

    if not feature then
        error("[EPIP] Attempted to fetch feature that does not exist: " .. id .. " from " .. modTable)
    end

    return feature
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

---TODO move to Feature
---@param id string
---@param name string
---@param feature Feature
function Epip.InitializeFeature(id, name, feature)
    setmetatable(feature, {__index = _Feature})

    feature._Tests = {}
    feature.MODULE_ID = id

    feature.NAME = name or id
    feature.REQUIRED_MODS = feature.REQUIRED_MODS or {}
    feature.FILEPATH_OVERRIDES = feature.FILEPATH_OVERRIDES or {}

    for ev,data in pairs(feature.Events) do
        if data.Legacy == false or feature.USE_LEGACY_EVENTS == false then
            feature:AddSubscribableEvent(ev, data.Preventable)
        else
            feature:AddEvent(ev, data)
        end
    end

    for hook,data in pairs(feature.Hooks) do
        if data.Legacy == false or feature.USE_LEGACY_HOOKS == false then
            feature:AddSubscribableHook(hook, data.Preventable)
        else
            feature:AddHook(hook, data)
        end
    end

    -- Check required mods
    local missingMods = {}
    for guid,modName in pairs(feature.REQUIRED_MODS) do
        if not Mod.IsLoaded(guid) then
            table.insert(missingMods, string.format("%s (%s)", guid, modName))
        end
    end

    if feature.DEVELOPER_ONLY and not Epip.IsDeveloperMode() then
        feature:Disable("NotDeveloper")
    end

    -- Disable the feature if required mods are missing.
    if #missingMods > 0 then
        Ext.PrintWarning("[EPIP] Feature '" .. feature.NAME .. "' has been disabled as some required mods are missing:")
        Ext.Dump(missingMods)

        feature:Disable("MISSING_MODS")
    elseif feature:IsEnabled() then
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
        Epip.InitializeFeature(id, ui.NAME or id, ui)
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