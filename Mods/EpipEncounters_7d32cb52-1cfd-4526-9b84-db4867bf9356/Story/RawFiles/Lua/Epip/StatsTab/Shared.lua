
---------------------------------------------
-- Stat definitions for Epip's custom stats.
-- Shared script, as these must exist on the server as well to update them.
---------------------------------------------

-- TODO update this documentation lmao
---------------------------------------------
-- To add new stats, define them in .STATS and insert them into a category in .CATEGORIES.
-- See StatGetters.lua for actually setting them - for stats formatted in the same
-- manner as the built-in Ascension ones, this is automatic - 
-- but you need to call PerformFullStatsUpdate() in a patch script when adding them.
-- We only keep track of equipped nodes that have a stat defined.
---------------------------------------------

---@class EpipStats
---@field CATEGORIES table<string, EpipStatCategory> Category definitions.
---@field CATEGORIES_ORDER string[]
---@field STATS table<string, EpipStat>
---@field MISSING_REGEN_CAP number TODO move
---@field TOOLTIP_TALENT number TODO remove
---@field TOOLTIP_TALENT_NAME string TODO remove

---@alias EpipStatCategoryBehaviour "GreyOut" | "Hidden"

---@class Feature_CustomStats : Feature
local EpipStats = {
    USERVAR_STATS = "Stats",
    CATEGORIES = {},
    
    -- TODO rework as a hook
    CATEGORIES_ORDER = {},

    STATS = {},

    MISSING_REGEN_CAP = 50,

    TOOLTIP_TALENT = 126,
    TOOLTIP_TALENT_NAME = "MasterThief",

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetStatValue = {}, ---@type Event<Feature_CustomStats_Hook_GetStatValue>
    },

    ---------------------------------------------
    -- INTERNAL VARIABLES - DO NOT SET
    ---------------------------------------------

    openCategories = {
        Vitals = true, -- Open by default.
        Reactions = true,
    },
    nextTooltipIsStat = false,
}
Epip.RegisterFeature("CustomStats", EpipStats)

---------------------------------------------
-- USER VARS
---------------------------------------------

EpipStats:RegisterUserVariable(EpipStats.USERVAR_STATS, {Persistent = true})

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Feature_CustomStats_Hook_GetStatValue
---@field Character Character
---@field Stat Feature_CustomStats_Stat
---@field Value any Hookable. Defaults to `nil`.

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_CustomStats_Category : Class, I_Identifiable, I_Describable
---@field Header string Name of the collapsable stat.
---@field Name string Name of the category in the tooltip.
---@field Behaviour EpipStatCategoryBehaviour Controls how default-value stats are shown. GreyOut greys out their label and value, hidden hides them - and the whole category - if no stats are owned.
---@field Stats string[] Stats displayed in the category, ordered.
local _Category = {
    Name = "Missing name",
    Description = "Missing description",
    Behaviour = "GreyOut",
}
Interfaces.Apply(_Category, "I_Identifiable")
Interfaces.Apply(_Category, "I_Describable")
EpipStats:RegisterClass("Feature_CustomStats_Category", _Category)

---Creates a category.
---@param data Feature_CustomStats_Category
---@return Feature_CustomStats_Category
function _Category.Create(data)
    local instance = _Category:__Create(data) ---@cast instance Feature_CustomStats_Category

    return instance
end

---@class Feature_CustomStats_Stat : Class, I_Identifiable, I_Describable
---@field Name string
---@field Description string Fallback description in case a formatted Tooltip isn't set.
---@field Tooltip TooltipData
---@field Footnote string Italic text after description, in new paragraph.
---@field Suffix string Suffix for value display.
---@field Prefix string Prefix for value display.
---@field Boolean boolean Boolean stats show no value label.
---@field MaxCharges string If specified, this stat will display as "{Value}/{Value of MaxCharges stat}"
---@field IgnoreForHiding boolean If true, this stat will not be considered as added when determining if a Hidden category should display.
---@field DefaultValue any?
local _Stat = {}
EpipStats:RegisterClass("Feature_CustomStats_Stat", _Stat)
Interfaces.Apply(_Stat, "I_Identifiable")
Interfaces.Apply(_Stat, "I_Describable")

---Creates a new stat.
---@param data Feature_CustomStats_Stat
---@return Feature_CustomStats_Stat
function _Stat.Create(data)
    local instance = _Stat:__Create(data) ---@cast instance Feature_CustomStats_Stat

    return instance
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Registers a stat bound to an Ascension node.
---@tpwd RequireBothContexts
---@param clusterId string
---@param nodeIndex number
---@param nodeSubIndex number
---@param keyword Keyword
---@param keywordType KeywordBoonType
---@param statData Feature_CustomStats_Stat Stat metadata.
function EpipStats.AddNodeStat(clusterId, nodeIndex, nodeSubIndex, keyword, keywordType, statData)
    local statID = string.format("%s_Node_%d.%d", clusterId, nodeIndex, nodeSubIndex)

    statData.Boolean = true
    statData.Keyword = keyword
    statData.BoonType = keywordType
    statData.NodeIndex = nodeIndex + 1
    statData.NodeSubIndex = nodeSubIndex + 1
    statData.Cluster = clusterId
    statData.DefaultValue = 0
    EpipStats.RegisterStat(statID, statData)

    -- Add stat to category
    local category = "Keyword_" .. keyword
    if EpipStats.CATEGORIES[category] then
        table.insert(EpipStats.CATEGORIES[category].Stats, statID)
    else
        EpipStats:LogError("Keyword category missing: " .. category)
    end
end

---Register a stat.
---@tpwd RequireBothContexts
---@param id string
---@param data Feature_CustomStats_Stat
function EpipStats.RegisterStat(id, data)
    data.ID = id

    EpipStats.STATS[id] = _Stat.Create(data)
end

---Register a category.
---@tpwd RequireBothContexts
---@param id string
---@param data Feature_CustomStats_Category
---@param index? integer Order in the stats tab relative to other categories.
function EpipStats.RegisterCategory(id, data, index)
    data.ID = id
    local instance = _Category.Create(data)

    EpipStats.CATEGORIES[id] = instance
    
    index = index or #EpipStats.CATEGORIES_ORDER + 1

    table.insert(EpipStats.CATEGORIES_ORDER, index, id)
end

---Returns a category by its ID.
---@param id string
---@return Feature_CustomStats_Category
function EpipStats.GetCategory(id)
    return EpipStats.CATEGORIES[id]
end

---Returns whether an ID corresponds to a category.
---@param statID string
---@return boolean
function EpipStats.IsCategory(statID)
    return EpipStats.GetCategory(statID) ~= nil
end

---Add a stat to a category.
---@tpwd RequireBothContexts
---@param statID string
---@param categoryID string
---@param index? integer
function EpipStats.AddStatToCategory(statID, categoryID, index)
    local category = EpipStats.CATEGORIES[categoryID]

    index = index or #category.Stats + 1

    table.insert(category.Stats, index, statID)
end

---Returns the descriptor for a stat.
---@param id string
---@return Feature_CustomStats_Stat
function EpipStats.GetStat(id)
    return EpipStats.STATS[id]
end

---Returns the value of a stat for a character.
---@param char Character? Defaults to client character.
---@param statID string
---@return any?
function EpipStats.GetStatValue(char, statID)
    char = char or Client.GetCharacter()
    local stat = EpipStats.GetStat(statID)
    local value = EpipStats.Hooks.GetStatValue:Throw({
        Character = char,
        Stat = stat,
        Value = stat.DefaultValue or nil,
    }).Value

    return value
end

---Returns whether a character has any non-hidden stat from a category
---at a non-default value.
---@param category Feature_CustomStats_Category
---@return boolean
function EpipStats.HasAnyStatFromCategory(category)
    local hasAnyStat = false

    for _,stat in pairs(category.Stats) do
        local data = EpipStats.GetStat(stat)

        if not data.IgnoreForHiding and not EpipStats.StatIsAtDefaultValue(Client.GetCharacter(), stat) then
            hasAnyStat = true
            break
        end
    end

    return hasAnyStat
end

---Returns whether a character has a stat at its default value.
---@param char Character
---@param statID string
---@return boolean
function EpipStats.StatIsAtDefaultValue(char, statID)
    local data = EpipStats.GetStat(statID)

    return data ~= nil and EpipStats.GetStatValue(char, statID) == data.DefaultValue
end

---Registers a value hook for a specific stat.
---@param statID string
---@param handler fun(ev:Feature_CustomStats_Hook_GetStatValue)
---@param opts Event_Options?
function EpipStats.RegisterStatValueHook(statID, handler, opts)
    EpipStats.Hooks.GetStatValue:Subscribe(function (ev)
        if ev.Stat:GetID() == statID then
            handler(ev)
        end
    end, opts)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Look for stat values in the uservar.
EpipStats.Hooks.GetStatValue:Subscribe(function (ev)
    local vars = EpipStats:GetUserVariable(ev.Character, EpipStats.USERVAR_STATS) or {}
    local value = vars[ev.Stat:GetID()]

    if value then
        ev.Value = value
    end
end)