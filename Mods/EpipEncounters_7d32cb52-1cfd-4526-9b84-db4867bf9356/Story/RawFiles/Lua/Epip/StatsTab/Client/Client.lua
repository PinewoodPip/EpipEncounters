
---------------------------------------------
-- Implements various EE-related stats to the character sheet custom stats tab,
-- with collapsable categories.
---------------------------------------------

local CharacterSheet = Client.UI.CharacterSheet
local EpipStats = Epip.Features.StatsTab

function EpipStats.GetCategory(statID)
    return EpipStats.CATEGORIES[statID]
end

function EpipStats.IsCategory(statID)
    return EpipStats.GetCategory(statID) ~= nil
end

-- Special tooltips for Ascension node stats
CharacterSheet.StatsTab:RegisterHook("GetStatTooltip", function(tooltip, stat, data)
    if data.Keyword then
        local aspectName = Data.Game.ASPECT_NAMES[data.Cluster]
        local source = string.format("Source: %s (Node %d.%d)", aspectName, data.NodeIndex, data.NodeSubIndex)
        local keywordName = Data.Game.KEYWORD_NAMES[data.Keyword] or data.Keyword
        local description = string.format('<p align="center"><font color="ebc808" size="22" face="Averia Serif">— %s %s —</font></p>', keywordName, data.BoonType) .. "<br>" .. data.Description

        return {
            {
                Type = "StatName",
                Label = data.Name,
            },
            {
                Type = "TalentDescription",
                Description = description,
                IncompatibleWith = "",
                Requirement = "",
                Selectable = true,
                TalentId = 126, -- TODO unhardcode
                Unknown = true,
            },
            {
                Type = "StatsTalentsBoost",
                Label = source,
            },
        }
    end

    return tooltip
end)

function EpipStats.ToggleCategory(id, state)
    if state ~= nil then -- Set
        EpipStats.openCategories[id] = state
    else -- Toggle
        if EpipStats.openCategories[id] then
            EpipStats.openCategories[id] = false
        else
            EpipStats.openCategories[id] = true
        end
    end
end

function EpipStats.CategoryIsOpen(categoryID)
    return EpipStats.openCategories[categoryID]
end

function EpipStats.RenderCategoryStats(categoryID)
    local category = EpipStats.GetCategory(categoryID)

    for i,statID in pairs(category.Stats) do

        if category.Behaviour == "Hidden" then
            if EpipStats.cachedStats[statID] then
                CharacterSheet.StatsTab.RenderStat(statID)
            end
        else
            CharacterSheet.StatsTab.RenderStat(statID)
        end
    end
end

function EpipStats.ParseStatsFromTags()
    -- Client.GetCharacter() is erroneous here while switching AMER UIs! TODO why?
    local char = CharacterSheet.GetCharacter() or Client.GetCharacter()
    
    EpipStats.cachedStats = {}

    for i,tag in pairs(char:GetTags()) do
        local stat,amount = tag:match(EpipStats.STAT_VALUE_TAG)
        
        if stat then
            EpipStats.cachedStats[stat] = amount
        end
    end
end

function EpipStats.RenderCategories()
    for i,id in pairs(EpipStats.CATEGORIES_ORDER) do
        local category = EpipStats.CATEGORIES[id]

        if category.Behaviour == "Hidden" then
            if EpipStats.HasAnyStatFromCategory(category) then
                CharacterSheet.StatsTab.RenderStat(id)
            end
        else
            CharacterSheet.StatsTab.RenderStat(id)
        end
    end
end

function EpipStats.HasAnyStatFromCategory(category)
    for i,stat in pairs(category.Stats) do
        local data = CharacterSheet.StatsTab.GetStatData(stat)

        if not data.IgnoreForHiding and EpipStats.cachedStats[stat] and EpipStats.cachedStats[stat] ~= 0 then
            return true
        end
    end
    return false
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Before rendering, get the stat values from tagged stats
CharacterSheet.StatsTab:RegisterListener("PreRender", function()
    EpipStats.ParseStatsFromTags()
end)

CharacterSheet.StatsTab:RegisterListener("PostRender", function()
    EpipStats.RenderCategories()
end)

-- Center text on categories
CharacterSheet.StatsTab:RegisterListener("EntryRendered", function(element, statID)
    if EpipStats.IsCategory(statID) then
        element.label_txt.width = 240
        element.label_txt.autoSize = "center"
        element.label_txt.x = element.label_txt.x + 12
        element.label_txt.y = -1
    end
end)

-- Render category stats if the category is uncollapsed.
CharacterSheet.StatsTab:RegisterListener("EntryAdded", function(statData, value)
    if EpipStats.IsCategory(statData.ID) and EpipStats.CategoryIsOpen(statData.ID) then
        EpipStats.RenderCategoryStats(statData.ID)
    end
end)

-- Collapse/uncollapse categories on click.
CharacterSheet.StatsTab:RegisterListener("StatClicked", function(statID)
    if EpipStats.IsCategory(statID) then
        EpipStats.ToggleCategory(statID)

        -- Re-render the tab
        CharacterSheet.StatsTab.RenderStats()
    end
end)

-- Request stat update if the sheet is opened while the tab is open.
Ext.RegisterUITypeInvokeListener(CharacterSheet.UITypeID, "setHelmetOptionState", function()
    if CharacterSheet:GetRoot().stats_mc.currentOpenPanel == 8 then
        Game.Net.PostToServer("EPIPENCOUNTERS_UpdateCustomStats", {NetID = CharacterSheet.GetCharacter().NetID})
    end
end)

-- Request update when the tab is opened.
Ext.RegisterUITypeCall(CharacterSheet.UITypeID, "selectedTab", function(ui, method, tab)
    if tab == 8 then
        Game.Net.PostToServer("EPIPENCOUNTERS_UpdateCustomStats", {NetID = CharacterSheet.GetCharacter().NetID})
    end
end)

-- Set custom icon for keyword stats when their tooltip is being rendered.
CharacterSheet.StatsTab:RegisterListener("TooltipRendering", function(stat, data, tooltip)
    if data.Keyword then
        local ui = Ext.UI.GetByType(Client.UI.Data.UITypes.tooltip)
        ui:SetCustomIcon("tt_talent_" .. CharacterSheet.StatsTab.TOOLTIP_TALENT_ID, "PIP_KeywordScaled_" .. data.Keyword, 128, 128)
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

Ext.Events.SessionLoaded:Subscribe(function()
    -- Define stats
    for statID,stat in pairs(EpipStats.STATS) do
        local tooltip = nil
        local description = stat.Description

        if stat.Footnote then
            description = description .. "<br><br>" .. string.format("<font color='a8a8a8' face='Averia Serif'>%s</font>", stat.Footnote)
        end

        -- TODO why not just link to the same table...
        -- CharacterSheet.StatsTab.Stats[statID] = {
        --     ID = statID,
        --     Name = stat.Name,
        --     Description = description,
        --     Tooltip = stat.Tooltip,
        --     MaxCharges = stat.MaxCharges,
        --     Suffix = stat.Suffix,
        --     Prefix = stat.Prefix,
        --     Boolean = stat.Boolean,
        --     Keyword = stat.Keyword,
        --     BoonType = stat.BoonType,
        --     IgnoreForHiding = stat.IgnoreForHiding,

        --     NodeIndex = stat.NodeIndex,
        --     NodeSubIndex = stat.NodeSubIndex,
        --     Cluster = stat.Cluster,
        -- }
        stat.ID = statID
        CharacterSheet.StatsTab.Stats[statID] = stat
    end

    -- Define the clickable category headers as stats
    for i,categoryID in pairs(EpipStats.CATEGORIES_ORDER) do
        local category = EpipStats.GetCategory(categoryID)

        CharacterSheet.StatsTab.Stats[categoryID] = {
            ID = categoryID,
            Name = category.Header,
            Tooltip = {
                {
                    Type = "StatName",
                    Label = category.Name,
                },
                {
                    Type = "StatsDescription",
                    Label = "Click to toggle.",
                },
            },
        }
    end
end)