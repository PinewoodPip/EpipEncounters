
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
    },
    Settings = {},
}
Epip.RegisterFeature("WorldTooltipFiltering", Filtering)

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
    NameHandle = Filtering.TranslatedStrings.Setting_ShowLights_Name,
    DescriptionHandle = Filtering.TranslatedStrings.Setting_ShowLights_Description,
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
---@return boolean
function Filtering.ShouldFilter(entry)
    local entity = Ext.Entity.GetGameObject(Ext.UI.DoubleToHandle(entry.ID))
    local shouldFilter = false

    for _,setting in ipairs(Filtering.SETTINGS) do
        if not Filtering._IsSettingEnabled(setting) and setting.FilterPredicate then
            shouldFilter = setting.FilterPredicate(entry, entity)

            -- Break if any setting deems this entry filterable.
            if shouldFilter then
                break
            end
        end
    end

    return shouldFilter
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

WorldTooltip.Hooks.UpdateContent:Subscribe(function (ev)
    local i = 1
    while i <= #ev.Entries do
        local entry = ev.Entries[i]

        if Filtering.ShouldFilter(entry) then
            table.remove(ev.Entries, i)
        else
            for _,setting in ipairs(Filtering.SETTINGS) do
                if Filtering._IsSettingEnabled(setting) and setting.GetLabel then
                    local entity = Ext.Entity.GetGameObject(Ext.UI.DoubleToHandle(entry.ID))

                    entry.Label = setting.GetLabel(entry, entity)
                end
            end
            i = i + 1
        end
    end
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
}

for _,setting in ipairs(settings) do
    Filtering.RegisterFilter(setting)
end