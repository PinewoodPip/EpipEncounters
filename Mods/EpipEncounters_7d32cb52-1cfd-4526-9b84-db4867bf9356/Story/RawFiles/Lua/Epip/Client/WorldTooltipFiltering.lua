
local WorldTooltip = Client.UI.WorldTooltip

---@class Feature_WorldTooltipFiltering : Feature
local Filtering = {
    ---@type Feature_WorldTooltipFiltering_Setting[]
    SETTINGS = {},

    ---Index corresponds with dropdown setting value.
    EMPHASIS_COLORS = {
        "FFFFFF", -- For disabled (1) setting.
        Color.LARIAN.LIGHT_BLUE,
        Color.LARIAN.GREEN,
        Color.LARIAN.YELLOW,
        Color.LARIAN.ORANGE,
    },
    TSKHANDLE_EMPTY = "h823595e6g550fg4614gb1ddgdcd323bb4c69", -- "(empty)"

    TranslatedStrings = {
        Setting_ShowLights_Name = {
           Handle = "h8605ee5agf02ag4f24g9bf2g60906ab5ef57",
           Text = "Show lights",
           ContextDescription = "Setting name",
        },
        Setting_ShowLights_Description = {
           Handle = "h0d38d9a9gd416g4815gabc7gf9d8d901d40a",
           Text = "If enabled, light items such as torches, candles and braziers will show world tooltips.",
           ContextDescription = "Setting tooltip",
        },
        Setting_HighlightUnlootedContainers_Name = {
            Handle = "h30de9767g5383g4b75g979bg01c9c5bf8326",
            Text = "Highlight unlooted containers/corpses",
            ContextDescription = [[World tooltips setting name]],
        },
        Setting_HighlightUnlootedContainers_Description = {
            Handle = "hbaa04557g2699g4e7bgb81dge499656fef59",
            Text = "If enabled, containers and corpses that have not yet been looted will show an asterisk in their world tooltips.",
            ContextDescription = [[World tooltips setting name for "Highlight unlooted containers/corpses"]],
        },
    },
    Settings = {},
}
Epip.RegisterFeature("WorldTooltipFiltering", Filtering)
local TSK = Filtering.TranslatedStrings

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_WorldTooltipFiltering_Setting
---@field SettingID string
---@field ModTableID string
---@field FilterPredicate (fun(entry:WorldTooltipUI_Entry, entity:Entity):boolean)? Should return true for items to be filtered out. Called only if the respective setting is disabled.
---@field GetLabel (fun(entry:WorldTooltipUI_Entry, entity:Entity):string)? Allows you to add "post-processing" to world tooltip labels.

---------------------------------------------
-- SETTINGS
---------------------------------------------

Filtering.Settings.ShowLights = Filtering:RegisterSetting("ShowLights", {
    ID = "ShowLights",
    Type = "Boolean",
    NameHandle = TSK.Setting_ShowLights_Name,
    DescriptionHandle = TSK.Setting_ShowLights_Description,
    DefaultValue = false,
})
Filtering.Settings.HighlightUnlootedContainers = Filtering:RegisterSetting("HighlightUnlootedContainers", {
    Type = "Boolean",
    Name = TSK.Setting_HighlightUnlootedContainers_Name,
    Description = TSK.Setting_HighlightUnlootedContainers_Description,
    DefaultValue = false,
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@param setting Feature_WorldTooltipFiltering_Setting
function Filtering.RegisterFilter(setting)
    table.insert(Filtering.SETTINGS, setting)
end

---@param setting Feature_WorldTooltipFiltering_Setting
function Filtering._IsSettingEnabled(setting)
    local enabled = false
    local value = Settings.GetSettingValue(setting.ModTableID, setting.SettingID)

    if type(value) == "boolean" then
        enabled = value
    else
        enabled = value > 1
    end

    return enabled
end

---Returns whether a tooltip entry should be filtered. Checks the registered settings.
---@param entry WorldTooltipUI_Entry
---@param enabledFilters table<Feature_WorldTooltipFiltering_Setting, boolean>? If unset or has missing keys, the setting values will be checked from SettingsLib.
---@param entity (EclItem|EclCharacter)? If unset, will be fetched from the entry.
---@return boolean
function Filtering.ShouldFilter(entry, enabledFilters, entity)
    entity = entity or Ext.Entity.GetGameObject(Ext.UI.DoubleToHandle(entry.ID)) ---@cast entity EclItem|EclCharacter
    local shouldFilter = false

    for _,setting in ipairs(Filtering.SETTINGS) do
        local isFilterEnabled
        if enabledFilters then
            isFilterEnabled = Filtering._GetCachedFilterSettingValue(enabledFilters, setting)
        else
            isFilterEnabled = Filtering._IsSettingEnabled(setting)
        end
        if not isFilterEnabled and setting.FilterPredicate then
            shouldFilter = setting.FilterPredicate(entry, entity)

            -- Break if any setting deems this entry filterable.
            if shouldFilter then
                break
            end
        end
    end

    return shouldFilter
end

---Returns the cached value of a filter setting, or adds it to the cache if need be.
---@param cache table<Feature_WorldTooltipFiltering_Setting, boolean>
---@param setting Feature_WorldTooltipFiltering_Setting
---@return boolean
function Filtering._GetCachedFilterSettingValue(cache, setting)
    if cache[setting] == nil then
        cache[setting] = Filtering._IsSettingEnabled(setting)
    end
    return cache[setting]
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

WorldTooltip.Hooks.UpdateContent:Subscribe(function (ev)
    local filterSettingStates = {} ---@type table<Feature_WorldTooltipFiltering_Setting, boolean>
    local filteredEntries = {} ---@type WorldTooltipUI_Entry[]
    local filteredEntriesCount = 0
    for _,entry in ipairs(ev.Entries) do
        local entity = Ext.Entity.GetGameObject(Ext.UI.DoubleToHandle(entry.ID)) ---@cast entity EclItem|EclCharacter

        -- Only keep entries that were not filtered out
        if not Filtering.ShouldFilter(entry, filterSettingStates, entity) then
            filteredEntriesCount = filteredEntriesCount + 1
            filteredEntries[filteredEntriesCount] = entry

            -- Apply label edits
            for _,setting in ipairs(Filtering.SETTINGS) do
                local isFilterEnabled = Filtering._GetCachedFilterSettingValue(filterSettingStates, setting)
                if isFilterEnabled and setting.GetLabel then
                    entry.Label = setting.GetLabel(entry, entity)
                end
            end
        end
    end
    ev.Entries = filteredEntries
end)

---------------------------------------------
-- SETUP
---------------------------------------------

---@param entry WorldTooltipUI_Entry
---@param entity Entity
---@param isItem boolean
---@param settingID string
---@return string
local function EmphasizeLabel(entry, entity, isItem, settingID)
    local label = entry.Label
    local canEmphasize = true

    -- Cannot emphasize illegal items
    if isItem then
        if not Item.IsLegal(entity) then
            canEmphasize = false
        end
    end

    if canEmphasize then
        local color = Filtering.EMPHASIS_COLORS[Settings.GetSettingValue("Epip_Tooltips", settingID)]
        local splitLabel = Text.Split_2(label, "<br>")
        splitLabel[1] = Text.StripFontTags(splitLabel[1])

        for i=2,#splitLabel,1 do -- Make subtitle(s?) smaller again
            splitLabel[i] = Text.Format(splitLabel[i], {Size = 19, RemovePreviousFormatting = true})
        end

        local separator = ""
        if #splitLabel > 1 then separator = "<br>" end
        label = string.concat(splitLabel, separator)
        label = Text.Format(label, {Color = color})
    end

    return label
end

---Appends an asterisk to an entry label, with a distinctive color.
---@param entry WorldTooltipUI_Entry
---@return string
local function AppendAsterisk(entry)
    -- Append a colored asterisk to the tooltip, ignoring other color formatting to make it stand out.
    local pattern = [[<font color="?'?#?(%x%x%x%x%x%x)"?'?>(.+)</font>]]
    local label, _ = entry.Label:gsub(pattern, [[<font color="#%1">%2</font>]] .. Text.Format("*", {Color = Color.LARIAN.GOLD}))
    return label
end

-- Register default settings.
---@type Feature_WorldTooltipFiltering_Setting[]
local settings = {
    {
        SettingID = "WorldTooltip_EmptyContainers",
        ModTableID = "Epip_Tooltips",
        FilterPredicate = function (entry, _)
            local emptyLabel = Text.GetTranslatedString(Filtering.TSKHANDLE_EMPTY)
            if entry.Label:find(emptyLabel, nil, true) then
                return true
            else
                return false
            end
        end,
    },
    {
        SettingID = "WorldTooltip_ShowSittableAndLadders",
        ModTableID = "Epip_Tooltips",
        FilterPredicate = function (_, entity)
            if GetExtType(entity) == "ecl::Item" then
                return Item.HasUseAction(entity, "Sit") or Item.HasUseAction(entity, "Ladder") or Item.HasUseAction(entity, "Lying")
            else
                return false
            end
        end
    },
    {
        SettingID = "WorldTooltip_ShowDoors",
        ModTableID = "Epip_Tooltips",
        FilterPredicate = function (_, entity)
            if GetExtType(entity) == "ecl::Item" then
                return Item.HasUseAction(entity, "Door")
            else
                return false
            end
        end
    },
    {
        SettingID = Filtering.Settings.ShowLights.ID,
        ModTableID = Filtering.Settings.ShowLights.ModTable,
        FilterPredicate = function (_, entity)
            if GetExtType(entity) == "ecl::Item" then
                ---@cast entity EclItem
                return Item.IsLight(entity)
            else
                return false
            end
        end
    },
    {
        SettingID = "WorldTooltip_ShowInactionable",
        ModTableID = "Epip_Tooltips",
        FilterPredicate = function (_, entity)
            if GetExtType(entity) == "ecl::Item" then
                return not Item.HasUseActions(entity) and not Item.IsEquipment(entity)
            else
                return false
            end
        end
    },
    {
        SettingID = "WorldTooltip_HighlightConsumables",
        ModTableID = "Epip_Tooltips",
        GetLabel = function (entry, entity)
            local label = entry.Label

            if GetExtType(entity) == "ecl::Item" then
                if Item.HasUseAction(entity, "Consume") then
                    label = EmphasizeLabel(entry, entity, true, "WorldTooltip_HighlightConsumables")
                end
            end

            return label
        end
    },
    {
        SettingID = "WorldTooltip_HighlightEquipment",
        ModTableID = "Epip_Tooltips",
        GetLabel = function (entry, entity)
            local label = entry.Label

            if GetExtType(entity) == "ecl::Item" then
                if Item.IsEquipment(entity) then
                    label = EmphasizeLabel(entry, entity, true, "WorldTooltip_HighlightEquipment")
                end
            end

            return label
        end
    },
    {
        SettingID = "WorldTooltip_HighlightContainers",
        ModTableID = "Epip_Tooltips",
        GetLabel = function (entry, entity)
            local label = entry.Label

            if GetExtType(entity) == "ecl::Item" then
                if Item.IsContainer(entity) then
                    label = EmphasizeLabel(entry, entity, true, "WorldTooltip_HighlightContainers")
                end
            end

            return label
        end
    },
    {
        SettingID = Filtering.Settings.HighlightUnlootedContainers.ID,
        ModTableID = Filtering.Settings.HighlightUnlootedContainers.ModTable,
        GetLabel = function (entry, entity)
            local isHighlighted = false
            if Entity.IsCharacter(entity) then
                local char = entity ---@type EclCharacter
                isHighlighted = not char.HasInventory -- This is actually the "has been looted" flag.
            elseif Entity.IsItem(entity) then
                local item = entity ---@cast entity EclItem
                isHighlighted = Item.IsContainer(item) and not item.WasOpened
            end
            return isHighlighted and AppendAsterisk(entry) or entry.Label
        end
    },
}

for _,setting in ipairs(settings) do
    Filtering.RegisterFilter(setting)
end