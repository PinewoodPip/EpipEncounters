
---------------------------------------------
-- Implements a custom UI to render character statuses,
-- as a replacement for PlayerInfo.
---------------------------------------------

local PlayerInfo = Client.UI.PlayerInfo

---@class Feature_StatusesDisplay : Feature
local StatusesDisplay = {
    _Displays = {}, ---@type table<ComponentHandle, Feature_StatusesDisplay_Manager>
    TranslatedStrings = {
        Setting_Enabled_Name = {
           Handle = "hb5e67864g87f1g4493gb758g47bdab2b69aa",
           Text = "Alternative Status Display",
           ContextDescription = "Setting name",
        },
        Setting_Enabled_Description = {
           Handle = "h0d296a7dgd716g475agb4c6g9b3de417c79f",
           Text = "Replaces the status bar by your characters's portraits with a custom UI that enables various sorting and filtering options.",
           ContextDescription = "Setting tooltip",
        },
        Setting_ShowSourceGeneration_Name = {
            Handle = "h82c7e2e1g5de2g4389ga7c5g639c3d653b96",
            Text = "Show Source Generation Status",
            ContextDescription = "Portrait status source gen filter setting name",
        },
        Setting_ShowSourceGeneration_Description = {
            Handle = "h4b67c715g0d30g4015gba18ge8ea4f357448",
            Text = "Shows the Source Generation status while Alternative Status Display is enabled.",
            ContextDescription = "Portrait status source gen filter setting tooltip",
        },
        Setting_ShowBatteredHarried_Name = {
            Handle = "haae0acc4gf8f6g4040g9038g52c50db75a38",
            Text = "Show Battered/Harried Statuses",
            ContextDescription = "Portrait status BH filter setting name",
        },
        Setting_ShowBatteredHarried_Description = {
            Handle = "hb9e14744g4868g4e08gb3d7ga9bd57629d03",
            Text = "Shows the Battered/Harries statuses while Alternative Status Display is enabled.<br>If you disable this, it is recommended to enable the B/H display on the portraits.",
            ContextDescription = "Portrait status BH filter setting tooltip",
        },
        Setting_FilteredStatuses_Name = {
           Handle = "h9e59177cgec69g4920g981bg8adee0d6600c",
           Text = "Filtered Statuses",
           ContextDescription = "Portrait status filtered statuses setting name",
        },
        Setting_FilteredStatuses_Description = {
           Handle = "hca56dcd2gf7f6g4662g94cfga66262672545",
           Text = "Statuses in this list will be filtered out and not shown in the status bar.",
           ContextDescription = "Portrait status filtered statuses setting tooltip",
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetStatuses = {}, ---@type Event<Feature_StatusesDisplay_Hook_GetStatuses>
        IsStatusFiltered = {}, ---@type Event<Feature_StatusesDisplay_Hook_IsStatusFiltered>
    },
}
Epip.RegisterFeature("StatusesDisplay", StatusesDisplay)

---------------------------------------------
-- SETTINGS
---------------------------------------------

StatusesDisplay:RegisterSetting("Enabled", {
    Type = "Boolean",
    Name = StatusesDisplay.TranslatedStrings.Setting_Enabled_Name,
    Description = StatusesDisplay.TranslatedStrings.Setting_Enabled_Description,
    Context = "Client",
    DefaultValue = false,
})
StatusesDisplay:RegisterSetting("ShowSourceGeneration", {
    Type = "Boolean",
    Name = StatusesDisplay.TranslatedStrings.Setting_ShowSourceGeneration_Name,
    Description = StatusesDisplay.TranslatedStrings.Setting_ShowSourceGeneration_Description,
    Context = "Client",
    DefaultValue = true,
})
StatusesDisplay:RegisterSetting("ShowBatteredHarried", {
    Type = "Boolean",
    Name = StatusesDisplay.TranslatedStrings.Setting_ShowBatteredHarried_Name,
    Description = StatusesDisplay.TranslatedStrings.Setting_ShowBatteredHarried_Description,
    Context = "Client",
    DefaultValue = true,
})
StatusesDisplay:RegisterSetting("FilteredStatuses", {
    Type = "Set",
    Name = StatusesDisplay.TranslatedStrings.Setting_FilteredStatuses_Name,
    Description = StatusesDisplay.TranslatedStrings.Setting_FilteredStatuses_Description,
    Context = "Client",
})

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_StatusesDisplay_Hook_GetStatuses
---@field Character EclCharacter
---@field Statuses EclStatus[] Hookable. Defaults to the visible statuses of the character.

---@class Feature_StatusesDisplay_Hook_IsStatusFiltered
---@field Status EclStatus
---@field Filtered boolean Hookable. Defaults to `false`.

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function StatusesDisplay:IsEnabled()
    return self:GetSettingValue("Enabled") and _Feature.IsEnabled(self)
end

---Creates a status display for a character.
---@param char EclCharacter
function StatusesDisplay.Create(char)
    if StatusesDisplay.Get(char) ~= nil then
        StatusesDisplay:Error("Create", char.DisplayName, "already has a manager")
    end
    local class = StatusesDisplay:GetClass("Feature_StatusesDisplay_Manager")
    local instance = class.Create(char)

    StatusesDisplay._Displays[char.Handle] = instance
end

---Returns the manager for a character, if any.
---@param char EclCharacter
---@return Feature_StatusesDisplay_Manager?
function StatusesDisplay.Get(char)
    return StatusesDisplay._Displays[char.Handle]
end

---Returns the visible statuses of char in a sorted order.
---@param char EclCharacter
---@return EclStatus[]
function StatusesDisplay.GetStatuses(char)
    local allStatuses = char:GetStatusObjects() ---@type EclStatus[]
    local visibleStatuses = {} ---@type EclStatus[]

    for _,status in ipairs(allStatuses) do
        if Stats.IsStatusVisible(status) and not StatusesDisplay.IsStatusFiltered(status) then
            table.insert(visibleStatuses, status)
        end
    end

    -- Invoke hook for filtering and sorting
    visibleStatuses = StatusesDisplay.Hooks.GetStatuses:Throw({
        Character = char,
        Statuses = visibleStatuses,
    }).Statuses

    return visibleStatuses
end

---Returns whether a status is filtered out.
---Assumes the status is a visible one.
---@param status EclStatus
---@return boolean
function StatusesDisplay.IsStatusFiltered(status)
    return StatusesDisplay.Hooks.IsStatusFiltered:Throw({
        Status = status,
        Filtered = false,
    }).Filtered
end

---Returns whether a status is filtered out by the user-defined filter list setting.
---@param status EclStatus
---@return boolean
function StatusesDisplay.IsStatusFilteredBySetting(status)
    local filterSet = StatusesDisplay:GetSettingValue(StatusesDisplay.Settings.FilteredStatuses) ---@type DataStructures_Set

    return filterSet:Contains(status.StatusId)
end

---Creates managers for all characters in PlayerInfo.
function StatusesDisplay._Initialize()
    -- Create managers for existing characters
    local chars = Character.GetPartyMembers(Client.GetCharacter())
    for _,char in ipairs(chars) do
        if StatusesDisplay.Get(char) == nil then
            StatusesDisplay.Create(char)
        end
    end

    -- Hide vanilla status displays.
    PlayerInfo.ToggleStatuses(false)
end

---Destroys all status managers.
function StatusesDisplay._Destroy()
    for _,manager in pairs(StatusesDisplay._Displays) do
        manager:Destroy()
    end
    StatusesDisplay._Displays = {}

    PlayerInfo.ToggleStatuses(true)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Create displays for characters being added to playerInfo UI.
PlayerInfo:RegisterInvokeListener("addInfo", function (_, handle)
    local char = Character.Get(handle, true)

    if StatusesDisplay.Get(char) == nil and StatusesDisplay:IsEnabled() then
        StatusesDisplay.Create(char)
    end
end, "After")

-- Listen for setting being toggled.
Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting == StatusesDisplay.Settings.Enabled then
        local enabled = ev.Value

        if enabled then
            StatusesDisplay._Initialize()
        else
            StatusesDisplay._Destroy()
        end
    end
end)

-- Create managers on load.
GameState.Events.GameReady:Subscribe(function (_)
    if StatusesDisplay:IsEnabled() then
        StatusesDisplay._Initialize()
    end
end)

-- Default implementation for filtering statuses.
StatusesDisplay.Hooks.IsStatusFiltered:Subscribe(function (ev)
    local id = ev.Status.StatusId

    -- Filter out statuses based on user settings
    if StatusesDisplay.IsStatusFilteredBySetting(ev.Status) then
        ev.Filtered = true
    elseif table.reverseLookup(EpicEncounters.SourceInfusion.SOURCE_GENERATION_DISPLAY_STATUSES, id) and StatusesDisplay:GetSettingValue(StatusesDisplay.Settings.ShowSourceGeneration) == false then -- Filter Source Generation statuses
        ev.Filtered = true
    elseif EpicEncounters.BatteredHarried.IsDisplayStatus(id) and StatusesDisplay:GetSettingValue(StatusesDisplay.Settings.ShowBatteredHarried) == false then -- Filter BH statuses
        ev.Filtered = true
    end
end, {StringID = "DefaultFilterImplementation"})