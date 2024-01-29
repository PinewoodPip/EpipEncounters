
---@class Epip
---@field VERSION integer In the format ex. `1066`
Epip = {
    Features = {}, ---@type table<string, Feature> Legacy table.
    _Features = {}, ---@type table<string, Epip.ModTable>
    _FeatureRegistrationOrder = {},

    PREFIXED_GUID = "EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356",
    cachedAprilFoolsState = nil,
    _devMode = nil,

    Events = {
        BeforeFeatureInitialization = SubscribableEvent:New("BeforeFeatureInitialization"), ---@type Event<Epip.Events.FeatureInitialization>
        AfterFeatureInitialization = SubscribableEvent:New("AfterFeatureInitialization"), ---@type Event<Epip.Events.FeatureInitialization>
    }
}
setmetatable(Epip, {
    __index = function (_, k)
        if k == "VERSION" then -- Backwards compatibility. This field used to be static.
            local major, minor, revision, build = Mod.GetStoryVersion(Mod.GUIDS.EPIP_ENCOUNTERS)
            return (major * 10^3) + (minor * 10^2) + (revision * 10) + build -- Epip's version always uses one digit for each component.
        end
    end
})

---------------------------------------------
-- CLASSES
---------------------------------------------

---Holds data for a mod and its registered Epip content.
---@class Epip.ModTable
---@field Features table<string, Feature>

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---Fired during feature initialization.
---@class Epip.Events.FeatureInitialization
---@field Feature Feature

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a feature, initializing its utility metatable and exposing it to other mods via GetFeature(). Should be called outside of any listener, as soon as the table is defined. This will also check for required path overrides and disable the feature if the required mods are not enabled.
---@param modTable string
---@param id string
---@param feature Feature
---@overload fun(id:string, feature:Feature)
function Epip.RegisterFeature(modTable, id, feature)
    -- Overload for Epip's built-in features
    if not feature and type(id) == "table" then
        ---@diagnostic disable-next-line: cast-local-type
        modTable, id, feature = "EpipEncounters", modTable, id
    end

    feature.MOD_TABLE_ID = modTable

    Epip.InitializeFeature(modTable, id, feature)
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

    -- Throw initialization events
    -- These are delayed by 1 tick to give later scripts a chance to subscribe
    Ext.OnNextTick(function (_)
        Epip.Events.BeforeFeatureInitialization:Throw({Feature = feature})
        ---@diagnostic disable-next-line: invisible
        feature:__Initialize()
        Epip.Events.AfterFeatureInitialization:Throw({Feature = feature})
    end)

    -- Auto-mute Epip features if Epip developer mode is not enabled
    if not Epip.IsDeveloperMode(true) then
        feature:Mute()
    end
end

---Overload for fetching features defined in EpipEncounters.
---@generic T
---@param id `T`
---@return Feature|`T`
---@diagnostic disable-next-line: missing-return, unused-local
function Epip.GetFeature(id) end -- IDE dummy

---@generic T
---@param modTable string
---@param id `T`
---@param required boolean? If `true`, an error will be thrown if the feature could not be fetched.
---@return Feature|`T`
function Epip.GetFeature(modTable, id, required)
    -- Overload to get features built-in into Epip.
    if id == nil then
        modTable, id = "EpipEncounters", modTable
    end

    -- Also attempt to fetch the feature using an ID with the "Feature(s)" prefix stripped as in many old Epip features it is only part of the IDE class and not in the feature ID.
    local strippedID = id:gsub("^Feature_", "", 1)
    strippedID = strippedID:gsub("^Features%.", "", 1) -- New naming convention
    local modData = Epip._Features[modTable]
    local feature

    if modData then
        feature = modData.Features[id] or modData.Features[strippedID]
    end

    if not feature and required then
        error("[EPIP] Attempted to fetch feature that does not exist: " .. id .. " from " .. modTable, 2)
    end

    return feature
end

function Epip.InitializeLibrary(id, lib)
    -- TODO allow setting it to others
    OOP.GetClass("Library").Create("EpipEncounters", id, lib)
end

---Returns whether developer mode is enabled.
---@param requirePipPoem boolean? Whether a poem to Pip is required for `true` to be returned. Defaults to `false`, which checks for Extender developer mode instead.
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

---Returns whether the game is using Pip's Script Extender fork.
function Epip.IsPipFork()
    ---@diagnostic disable-next-line: undefined-field
    return Ext.IsPipFork == true
end

---Silences logging from all features of a mod.
---@param modTable modtable? Defaults to `"EpipEncounters"`
function Epip.ShutUp(modTable)
    modTable = modTable or "EpipEncounters"
    local modData = Epip._Features[modTable] or {}
    for _,feature in pairs(modData.Features) do
        feature:ShutUp()
    end
end

---Copies Epip's globals into a table.
---Intended usage is to copy into another mod's `_ENV`.
---@param tbl table
function Epip.ImportGlobals(tbl)
    for k,v in pairs(_G) do
        tbl[k] = v
    end
end

---TODO move to Feature
---@param modTable string
---@param id string
---@param feature Feature
function Epip.InitializeFeature(modTable, id, feature)
    OOP.GetClass("Feature").Create(modTable, id, feature)

    feature._Tests = {}
    feature.MODULE_ID = id

    feature.NAME = id
    feature.FILEPATH_OVERRIDES = feature.FILEPATH_OVERRIDES or {}

    if feature.DEVELOPER_ONLY and not Epip.IsDeveloperMode() then
        feature:SetEnabled("NotDeveloper", false)
    end

    if feature:IsEnabled() then
        -- Add filepath overrides.
        for old,new in pairs(feature.FILEPATH_OVERRIDES) do
            Ext.IO.AddPathOverride(old, new)
        end

        feature._initialized = true
    end

    table.insert(Epip._FeatureRegistrationOrder, feature)
end

---@param obj any
---@param opts any?
---@param fileName string?
function Epip.SaveDump(obj, opts, fileName)
    IO.SaveFile(fileName or "debug_dump.json", Text.Dump(obj, opts or {
        Beautify = true,
        StringifyInternalTypes = true,
        IterateUserdata = true,
        AvoidRecursion = true,
        LimitDepth = 6,
    }), true)
end

---Registers a `FeatureInitialization` listener for a specific feature.
---@param modTable modtable
---@param featureID string
---@param timing "Before"|"After"
---@param listener fun(ev:Epip.Events.FeatureInitialization)
function Epip.RegisterFeatureInitializationListener(modTable, featureID, timing, listener)
    if timing ~= "Before" and timing ~= "After" then
        error("Invalid timing option " .. timing)
    end
    local event = timing == "Before" and Epip.Events.BeforeFeatureInitialization or Epip.Events.AfterFeatureInitialization

    event:Subscribe(function (ev)
        if ev.Feature:GetModTable() == modTable and ev.Feature:GetFeatureID() == featureID then
            listener(ev)
        end
    end)
end

if Ext.IsClient() then
    ---Initializes a UI table.
    ---@param type integer?
    ---@param id string
    ---@param ui UI Will be initialized.
    ---@param assignToUINamespace boolean?
    function Epip.InitializeUI(type, id, ui, assignToUINamespace)
        if assignToUINamespace == nil then assignToUINamespace = true end
        local instance = Client.UI._BaseUITable.Create(id, type, ui)

        if assignToUINamespace then
            Client.UI[id] = ui
        end

        -- TODO fix code duplication; and some of these aspects UIs never should've had
        xpcall(function ()
            instance._Tests = {}
            instance.MODULE_ID = id

            instance.NAME = id
            instance.FILEPATH_OVERRIDES = instance.FILEPATH_OVERRIDES or {}

            -- Add filepath overrides.
            for old,new in pairs(instance.FILEPATH_OVERRIDES) do
                Ext.IO.AddPathOverride(old, new)
            end

            instance._initialized = true
        end, function (msg)
            Ext.Utils.PrintError(msg)
        end)

        local path = ui:GetPath()
        if path then -- Not all UIs have this pre-set, and the UI might not exist at this time.
            Client._PathToUI[path] = ui
        end
    end

    ---Returns whether it is currently 1st of April or the "Out of season April Fools jokes" setting is enabled.
    ---@return boolean
    function Epip.IsAprilFools()
        -- Minor optimisation
        if Epip.cachedAprilFoolsState == nil then
            local date = Client.GetDate()
            Epip.cachedAprilFoolsState = (date.Day == 1 and date.Month == 4)
        end

        return Epip.cachedAprilFoolsState or Settings.GetSettingValue("Epip_Developer", "DEBUG_AprilFools")
    end

    ---Returns whether it is currently Pip's birthday.
    ---@return boolean
    function Epip.IsPipBirthday()
        local date = Client.GetDate()
        return date.Day == 26 and date.Month == 1
    end
end

---@deprecated Legacy call. Use RegisterFeature() instead.
function Epip.AddFeature(id, _, feature)
    Ext.Utils.PrintWarning("[EPIP] Registering Features with AddFeature() is deprecated.", id)
    Epip.RegisterFeature(id, feature)
    Epip.Features[id] = feature
end