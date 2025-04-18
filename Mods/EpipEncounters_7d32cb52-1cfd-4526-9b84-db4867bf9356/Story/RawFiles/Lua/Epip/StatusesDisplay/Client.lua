
---------------------------------------------
-- Implements a custom UI to render character statuses,
-- as a replacement for PlayerInfo.
---------------------------------------------

local PlayerInfo = Client.UI.PlayerInfo
local WorldTooltip = Client.UI.WorldTooltip

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
            Text = "Show Source Generation status",
            ContextDescription = "Portrait status source gen filter setting name",
        },
        Setting_ShowSourceGeneration_Description = {
            Handle = "h4b67c715g0d30g4015gba18ge8ea4f357448",
            Text = "Shows the Source Generation status while Alternative Status Display is enabled.",
            ContextDescription = "Portrait status source gen filter setting tooltip",
        },
        Setting_ShowBatteredHarried_Name = {
            Handle = "haae0acc4gf8f6g4040g9038g52c50db75a38",
            Text = "Show Battered/Harried statuses",
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
           Text = "Statuses in this list will be filtered out and not shown in the status bar if \"Alternative Status Display\" is enabled. Holding shift temporarily disables this filter.",
           ContextDescription = "Portrait status filtered statuses setting tooltip",
        },
        Setting_SortingIndexes_Name = {
           Handle = "h8ef5106dg4b12g413cg87adgce524dad4d1e",
           Text = "Sorting Priority",
           ContextDescription = "Status sorting setting name",
        },
        Setting_SortingIndexes_Description = {
           Handle = "h4c594766g0190g4016gb7a5g0b99c3e2011a",
           Text = "Sets the sorting order for statuses. Statuses with a higher priority show in the left-most position, statuses with a lower priority show in the right-most position.",
           ContextDescription = "",
        },
        ContextMenu_SortingIndex = {
           Handle = "h0e24fb6bg2c78g4dd3g995cg9d04ea62eaab",
           Text = "Sorting Index",
           ContextDescription = "Context menu option",
        },
    },
    Settings = {},

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
    RequiredMods = {Mod.GUIDS.EE_CORE},
    DefaultValue = true,
})
StatusesDisplay:RegisterSetting("ShowBatteredHarried", {
    Type = "Boolean",
    Name = StatusesDisplay.TranslatedStrings.Setting_ShowBatteredHarried_Name,
    Description = StatusesDisplay.TranslatedStrings.Setting_ShowBatteredHarried_Description,
    Context = "Client",
    RequiredMods = {Mod.GUIDS.EE_CORE},
    DefaultValue = true,
})
StatusesDisplay:RegisterSetting("FilteredStatuses", {
    Type = "Set",
    Name = StatusesDisplay.TranslatedStrings.Setting_FilteredStatuses_Name,
    Description = StatusesDisplay.TranslatedStrings.Setting_FilteredStatuses_Description,
    Context = "Client",
})
StatusesDisplay:RegisterSetting("SortingIndexes", {
    Type = "Map",
    Name = StatusesDisplay.TranslatedStrings.Setting_SortingIndexes_Name,
    Description = StatusesDisplay.TranslatedStrings.Setting_SortingIndexes_Description,
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

    -- Update the UI every tick, and destroy it if the character is removed from the party.
    GameState.Events.Tick:Subscribe(function (ev)
        local uiChar = Character.Get(instance.CharacterHandle)
        if uiChar and uiChar.IsPlayer and GameState.IsInSession() then -- Do not update during level swap
            instance:Update(ev.DeltaTime / 1000)
        elseif not uiChar or not uiChar.IsPlayer then -- Destroy instance if character was removed or became non-player
            StatusesDisplay.Destroy(instance)
        end
    end, {StringID = instance.GUID})

    StatusesDisplay._Displays[char.Handle] = instance

    -- Required to handle buggy level swaps and recruitment.
    -- In the case of recruitment, the array does not have its size updated after addInfo until one tick later. The reason for this is unknown.
    Ext.OnNextTick(function ()
        PlayerInfo.ToggleStatuses(false)
    end)
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
---@param status string|EclStatus
---@return boolean
function StatusesDisplay.IsStatusFilteredBySetting(status)
    local statusID = status
    if GetExtType(status) ~= nil then -- EclStatus overload.
        statusID = status.StatusId
    end
    local filterSet = StatusesDisplay:GetSettingValue(StatusesDisplay.Settings.FilteredStatuses) ---@type DataStructures_Set

    return filterSet:Contains(statusID)
end

---Returns the priority of a status.
---@param status string|EclStatus
---@return integer --Default priority is `0`.
function StatusesDisplay.GetStatusPriority(status)
    local statusID = status ---@type string
    if GetExtType(status) ~= nil then -- EclStatus overload
        statusID = status.StatusId
    end
    local priority = StatusesDisplay:GetSettingValue(StatusesDisplay.Settings.SortingIndexes)[statusID] or 0

    return priority
end

---Creates managers for all characters in PlayerInfo.
function StatusesDisplay._Initialize()
    -- Create managers for existing characters within the UI
    local chars = PlayerInfo.GetCharacters()
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
        StatusesDisplay.Destroy(manager)
    end
    StatusesDisplay._Displays = {}

    PlayerInfo.ToggleStatuses(true)
end

---Destroys the UI for a character.
---@param ui Feature_StatusesDisplay_Manager
function StatusesDisplay.Destroy(ui)
    GameState.Events.Tick:Unsubscribe(ui.GUID)
    StatusesDisplay._Displays[ui.CharacterHandle] = nil
    ui:Destroy()
end

---Returns whether filters should be applied,
---based on whether the user is using the keybinds to toggle them
---(shift on KBM, world tooltips toggle on controller).
---@return boolean
function StatusesDisplay._ShouldUseFilters()
    local isController = Client.IsUsingController()
    return not Client.Input.IsShiftPressed() and (not isController or not WorldTooltip:IsVisible())
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

    -- Filter out statuses based on user settings, except while shift is being held or world tooltips are shown on controller (as an equivalent keybind).
    if StatusesDisplay._ShouldUseFilters() and StatusesDisplay.IsStatusFilteredBySetting(ev.Status) then
        ev.Filtered = true
    elseif EpicEncounters.IsEnabled() then
        if table.reverseLookup(EpicEncounters.SourceInfusion.SOURCE_GENERATION_DISPLAY_STATUSES, id) and StatusesDisplay:GetSettingValue(StatusesDisplay.Settings.ShowSourceGeneration) == false then -- Filter Source Generation statuses
            ev.Filtered = true
        elseif EpicEncounters.BatteredHarried.IsDisplayStatus(id) and StatusesDisplay:GetSettingValue(StatusesDisplay.Settings.ShowBatteredHarried) == false then -- Filter BH statuses
            ev.Filtered = true
        end
    end
end, {StringID = "DefaultFilterImplementation"})

-- Default implementation for sorting statuses.
StatusesDisplay.Hooks.GetStatuses:Subscribe(function (ev)
    local statuses = ev.Statuses
    local newStatuses = {table.unpack(statuses)}

    table.sort(newStatuses, function (status1, status2)
        local status1ID = status1.StatusId
        local status2ID = status2.StatusId
        local status1Priority = StatusesDisplay.GetStatusPriority(status1ID)
        local status2Priority = StatusesDisplay.GetStatusPriority(status2ID)

        if status1Priority ~= status2Priority then
            return status1Priority > status2Priority
        else -- Use them positions within the original list as the tie-breaker. Statuses in the list appear to be in the order they were applied, thereby matching vanilla UI behaviour.
            return table.reverseLookup(statuses, status1) < table.reverseLookup(statuses, status2)
        end
    end)

    ev.Statuses = newStatuses
end, {StringID = "DefaultSortingImplementation"})