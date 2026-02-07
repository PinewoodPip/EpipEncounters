
---@class StatsLib
local Stats = Stats

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias StatsLib_Rune_Material "Bloodstone"|"Bone"|"Clay"|"Emerald"|"Flame"|"Frost"|"Gold"|"Granite"|"Iron"|"Jade"|"Lapis"|"Malachite"|"Masterwork"|"Obsidian"|"Onyx"|"Pearl"|"Ruby"|"Sapphire"|"Silver"|"Steel"|"Thunder"|"TigersEye"|"Topaz"|"Venom"

---@class ItemLib_RuneGroup
---@field Material StatsLib_Rune_Material
---@field SmallRune ItemLib_Rune
---@field MediumRune ItemLib_Rune
---@field LargeRune ItemLib_Rune
---@field GiantRune ItemLib_Rune

---@class ItemLib_Rune
---@field Material StatsLib_Rune_Material
---@field StatsID string
---@field Template GUID
---@field Size "Small"|"Medium"|"Large"|"Giant"
---@field IsFramed false Framed runes not currently tracked.
local _Rune = {}

function _Rune:GetStatsObject()
    return Stats.Get("Object", self.StatsID)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param statsID string
---@return ItemLib_Rune
function Stats.GetRuneDefinition(statsID)
    if not Stats._RuneDefinitionsGenerated then
        error("Rune definitions not yet available (wait until SessionLoading)")
    end

    return Stats.Runes[statsID]
end

---Returns the rune tier of an Object, if any.
---@param statsID string
---@return integer? -- `nil` if the Object is not a rune.
function Stats.GetRuneTier(statsID)
    local runeDef = Stats.GetRuneDefinition(statsID)
    local runeTier = nil
    if runeDef then
        local statsObj = Ext.Stats.GetForPip(statsID) ---@type StatsLib_StatsEntry_Object
        if Stats.GetType(statsObj) == "Object" then
            runeTier = statsObj.RuneLevel
        end
    end
    return runeTier
end

---@param materialID StatsLib_Rune_Material
---@return ItemLib_RuneGroup
function Stats.GetRuneGroup(materialID)
    return Stats.RuneGroups[materialID]
end

---------------------------------------------
-- SETUP
---------------------------------------------

Stats.Runes = {}
Stats.RuneGroups = {}
Stats._RuneDefinitionsGenerated = false

---Generate tables containing rune data of the current session.
---Objects are considered runes if their stats have RuneLevel > 0.
---@return table<string, ItemLib_RuneGroup>, table<string, ItemLib_Rune>
function Stats._GenerateRuneData()
    local stats = Ext.Stats.GetStats("Object")
    local runes = {}
    local runeGroups = {}

    for _,statID in ipairs(stats) do
        local stat = Stats.Get("StatsLib_StatsEntry_Object", statID)
        if stat.RuneLevel > 0 then
            local name, size = statID:match("^LOOT_Rune_([^_]+)_([^_]+)$")
            -- local isFramed = false -- TODO

            if name and size then
                ---@type ItemLib_Rune
                local rune = {
                    Material = name,
                    StatsID = statID,
                    Template = stat.RootTemplate,
                    Size = size,
                    IsFramed = false,
                }
                Inherit(rune, _Rune)

                if not runeGroups[name] then
                    runeGroups[name] = {Material = name}
                end
                runeGroups[name][size .. "Rune"] = rune

                runes[statID] = rune
            end
        end
    end

    return runeGroups, runes
end

-- Generate rune data on SessionLoading.
Ext.Events.SessionLoading:Subscribe(function (_)
    local runeGroups, runes = Stats._GenerateRuneData()

    Stats.Runes = runes
    Stats.RuneGroups = runeGroups
    Stats._RuneDefinitionsGenerated = true
end)