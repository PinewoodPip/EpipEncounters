
---------------------------------------------
-- Scripting for the custom stats tab.
---------------------------------------------

local CustomStats = Epip.GetFeature("Feature_CustomStats")

---@class CharacterSheetUIStatsTab : Library
---@field Stats table<string, StatsTabStat>
---@field TOOLTIP_TALENT_ID number Enum of the talent ID we hijack the tooltip of.
---@field TOOLTIP_TALENT_NAME string String ID of the talent we hijack the tooltip of.
---@field DEFAULT_STAT_VALUE number
---@field ignoreUpdate boolean Internal; do not set
---@field nextNumericalID number Internal; do not set
local StatsTab = {
    Stats = {},

    TOOLTIP_TALENT_ID = 126,
    TOOLTIP_TALENT_NAME = "MasterThief",

    DEFAULT_STAT_VALUE = 0,

    ---------------------------------------------
    -- INTERNAL VARIABLES - DO NOT SET
    ---------------------------------------------
    ignoreUpdate = false,
    nextNumericalID = 0,
}
Client.UI.CharacterSheet.StatsTab = StatsTab
Epip.InitializeLibrary("CharacterSheet.StatsTab", StatsTab)
local CharacterSheet = Client.UI.CharacterSheet

---------------------------------------------
-- EVENTS
---------------------------------------------

---Fired when a stat is rendered.
---@class CharacterSheetUIStatsTab_EntryAdded : Event
---@field data StatsTabStat
---@field value number

---Fired before stats are (re-)rendered.
---@class CharacterSheetUIStatsTab_PreRender : Event

---Fired after a full render of the tab is complete.
---@class CharacterSheetUIStatsTab_PostRender : Event

---Fired when a stat element is created in Flash.
---@class CharacterSheetUIStatsTab_EntryRendered : Event
---@field element FlashMovieClip
---@field elementID string

---Fired when a stat is clicked.
---@class CharacterSheetUIStatsTab_StatClicked : Event
---@field elementID string

---Fired when a stat tooltip is being rendered.
---@class CharacterSheetUIStatsTab_TooltipRendering : Event
---@field statID string
---@field data StatsTabStat
---@field tooltip TooltipData The default tooltip, using Tooltip from the stat data, or Description as a fallback.

---Hook to change the calculated value of a stat.
---@class CharacterSheetUIStatsTab_GetStatValue : Hook
---@field value number
---@field data StatsTabStat
---@field char EclCharacter

---Hook to manipulate the string display of a stat's value.
---@class CharacterSheetUIStatsTab_FormatStatValue : Hook
---@field value number
---@field data StatsTabStat
---@field char EclCharacter

---Hook to manipulate the label display of a stat.
---@class CharacterSheetUIStatsTab_FormatLabel : Hook
---@field label string
---@field data StatsTabStat
---@field value number

---------------------------------------------
-- METHODS
---------------------------------------------

---Get the text display for a stat's value.
---@param id string The stat ID.
---@param value number The value to format.
---@param char EclCharacter?
---@return string|number
function StatsTab.FormatStatValue(id, value, char)
    local data = CustomStats.GetStat(id)
    value = value or CustomStats.GetStatValue(char, id)
    char = char or CharacterSheet.GetCharacter()

    value = StatsTab:ReturnFromHooks("FormatStatValue_" .. id, value, data, char)
    value = StatsTab:ReturnFromHooks("FormatStatValue", value, data, char)

    return value
end

---Formats the label for stat.
---@param stat Feature_CustomStats_Stat
---@param value any?
---@return string
function StatsTab._FormatLabel(stat, value) -- TODO make hookable
    local label = stat.Name

    -- Prefix keywords with ACT/MUTA
    if stat.Keyword and stat.BoonType then
        local prefix = "MUTA: "
        if stat.BoonType == "Activator" then
            prefix = "ACT: "
        end
        label = prefix .. label
    end

    -- Grey out stats at default value
    if value == stat.DefaultValue then
        label = "<font color='32302d'>" .. label .. "</font>"
    end

    return label
end

---Render a stat onto the tab.
---@param id string
function StatsTab.RenderStat(id)
    local char = CharacterSheet.GetCharacter()
    local data = CustomStats.GetStat(id)
    if not data then
        StatsTab:LogWarning("Attempted to render non-existent stat " .. id)
        return
    end
    
    local value = CustomStats.GetStatValue(char, id)
    local valueLabel = StatsTab.FormatStatValue(id, value)
    local label = data.Name

    label = StatsTab._FormatLabel(data, value)

    StatsTab.AddEntry(label, valueLabel, id)

    StatsTab:FireEvent("EntryAdded", data, value)
end

---Renders a category onto the tab.
---@param id string
function StatsTab.RenderCategory(id)
    local data = CustomStats.GetCategory(id)
    local label = data.Header

    StatsTab.AddEntry(label, "", id)

    -- Render category stats if the category is uncollapsed.
    if CustomStats.CategoryIsOpen(id) then
        StatsTab.RenderCategoryStats(id)
    end
end

---Returns whether a stat can be rendered onto the UI.
---@param char EclCharacter
---@param category Feature_CustomStats_Category
---@param stat Feature_CustomStats_Stat
---@return boolean
function StatsTab.CanRenderStat(char, category, stat)
    local canRender = true

    -- In Hidden categories stats do not display if they're at a default value.
    if category.Behaviour == "Hidden" then
        canRender = canRender and not CustomStats.StatIsAtDefaultValue(char, stat:GetID())
    end

    return canRender
end

function StatsTab.RenderCategories()
    for _,id in pairs(CustomStats.CATEGORIES_ORDER) do
        local category = CustomStats.GetCategory(id)

        if category.Behaviour == "Hidden" then
            if CustomStats.HasAnyStatFromCategory(category) then
                StatsTab.RenderCategory(id)
            end
        else
            StatsTab.RenderCategory(id)
        end
    end
end

function StatsTab.RenderCategoryStats(categoryID)
    local category = CustomStats.GetCategory(categoryID)

    CustomStats:DebugLog("Rendering category", category.Name)

    for _,statID in pairs(category.Stats) do
        local statData = CustomStats.GetStat(statID)
        local canRender = StatsTab.CanRenderStat(Client.GetCharacter(), category, statData)

        if canRender then
            StatsTab.RenderStat(statID)
        end
    end
end

---Call to perform a full re-render of the tab.
---TODO some SetDirty call to prevent infinite loops with multiple modules calling this?
function StatsTab.RenderStats()
    if not CharacterSheet:IsVisible() then return nil end

    local root = CharacterSheet:GetRoot()
    local stats = root.stats_mc
    StatsTab.nextNumericalID = 0

    StatsTab:DebugLog("Rendering Custom Stats")

    stats.clearCustomStatsOptions()

    StatsTab.RenderCategories()

    StatsTab:DebugLog("Finished rendering")

    stats.customStats_mc.list.positionElements()

    -- Not sure why this is bugging out all of a sudden - TODO investigate
    stats.customStats_mc.list.m_scrollbar_mc.visible = CharacterSheet:GetRoot().stats_mc.currentOpenPanel == 8
end

---Register a FormatStatValue hook for a specific stat.
---@param stat string
---@param handler function
function StatsTab.RegisterStatValueFormatHook(stat, handler)
    CustomStats:LogWarning("StatValueFormatHook is deprecated: " .. stat)
    StatsTab:RegisterHook("FormatStatValue_" .. stat, handler)
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

-- Create a stat element element in Flash.
function StatsTab.AddEntry(label, value, elementID)
    local root = CharacterSheet:GetRoot()
    local stats = root.stats_mc

    stats.addCustomStat(StatsTab.nextNumericalID, label, value, elementID)

    -- TODO move to flash
    local elements = stats.customStats_mc.list.content_array
    local element = elements[#elements-1]
    element.text_txt.y = 0
    element.label_txt.y = 0
    element.line_mc.y = element.line_mc.y + 1
    element.hl_mc.y = element.hl_mc.y + 3
    element.text_txt.visible = true
    element.text_txt.width = element.text_txt.width + 40
    element.text_txt.x = element.text_txt.x - 40

    StatsTab.nextNumericalID = StatsTab.nextNumericalID + 1

    StatsTab:FireEvent("EntryRendered", element, elementID)
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Refresh stats tab.
Net.RegisterListener("EPIPENCOUNTERS_RefreshStatsTab", function(payload)
    -- Needs a delay, as applying tags is apparently slower than this.
    Timer.Start("UI_CharacterSheet", 0.1, function()
        StatsTab.RenderStats()
    end)
end)

local function OnStatClick(uiObj, methodName, elementID)
    StatsTab:FireEvent("StatClicked", elementID)
end

local function OnRequestRender(ui, method)
    local root = ui:GetRoot()

    StatsTab.RenderStats()
end

local function OnTabOpen(ui, method, tab)
    if tab == 8 then
        StatsTab.RenderStats()
    end
end

local function OnStatTooltipRender(_, stat, tooltip)
    if not StatsTab.currentlySelectedStat or stat ~= StatsTab.TOOLTIP_TALENT_NAME then return nil end

    local data = CustomStats.GetStat(StatsTab.currentlySelectedStat) or CustomStats.GetCategory(StatsTab.currentlySelectedStat)

    -- Construct generic tooltip if no special one is defined
    tooltip.Data = data.Tooltip
    if not tooltip.Data then
        tooltip.Data = {
            {
                Type = "StatName",
                Label = data:GetName() or "MISSING NAME",
            },
        }

        -- TODO add descriptions to categories
        if not CustomStats.IsCategory(StatsTab.currentlySelectedStat) then
            table.insert(tooltip.Data, 
            {
                Type = "StatsDescription",
                Label = data:GetDescription() or "MISSING .Description",
            })
        end
    end

    tooltip.Data = StatsTab:ReturnFromHooks("GetStatTooltip", tooltip.Data, StatsTab.currentlySelectedStat, data)

    StatsTab:FireEvent("TooltipRendering", StatsTab.currentlySelectedStat, data, tooltip)
end

-- When showCustomStatTooltip is sent to engine from flash, send a normal stat tooltip request, with a special, normally invalid statID.
local function ShowCustomStatTooltip(ui, call, elementID, ...)
    StatsTab.currentlySelectedStat = elementID

    ui:ExternalInterfaceCall("showTalentTooltip", StatsTab.TOOLTIP_TALENT_ID, ...)
end

Ext.Events.SessionLoaded:Subscribe(function()
    local ui = CharacterSheet:GetUI()

    Ext.RegisterUICall(ui, "pipRenderCustomStats", OnRequestRender)
    Ext.RegisterUICall(ui, "pipCustomStatClicked", OnStatClick) -- stat click handler
    Ext.RegisterUICall(ui, "selectedTab", OnTabOpen, "After") -- tab open handler

    -- Tooltip handlers
    Ext.RegisterUICall(ui, "showCustomStatTooltip", ShowCustomStatTooltip, "After")
    Game.Tooltip.RegisterListener("Talent", nil, OnStatTooltipRender)

    -- Position custom stats stuff
    local root = ui:GetRoot()
    local stats = root.stats_mc
    local customStats = stats.customStats_mc
    customStats.list.x = -40
    customStats.list.m_scrollbar_mc.x = 0
end)