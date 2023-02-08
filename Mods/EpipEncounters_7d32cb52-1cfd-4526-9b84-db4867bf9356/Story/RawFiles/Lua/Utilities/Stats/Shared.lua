
---@class StatsLib : Library
Stats = {
    STATS_OBJECT_TYPES = {
        Boost = true,
        Armor = true,
        Weapon = true,
        SkillData = true,
        Object = true,
        Character = true,
        Shield = true,
        StatusData = true,
        Potion = true,
    },

    Enums = {
        ---@enum StatEntry_CastCheckType
        CastCheckType = {
            [0] = "None",
            [1] = "Distance",
            [2] = "DamageType",
            [3] = "TargetSurfaceType",
        },
        ---@enum StatEntry_SkillRequirement
        SkillElement = {
            [0] = "None",
        },
        ---@enum StatEntry_SkillAbility
        SkillAbility = {
            [0] = "None",
            [1] = "Warrior",
            [2] = "Ranger",
            [3] = "Rogue",
            [4] = "Source",
            [5] = "Fire",
            [6] = "Water",
            [7] = "Air",
            [8] = "Earth",
            [9] = "Death",
            [10] = "Summoning",
            [11] = "Polymorph",
        },
    },

    ModifierLists = {},

    ---@type table<GUID, table<string, number>> Default values, per mod.
    EXTRA_DATA_DEFAULT_VALUES = nil, -- See Shared_ExtraData.lua

    ---@type table<string, ExtraDataEntry>
    ExtraData = {
    },
}
Game.Stats = Stats
Epip.InitializeLibrary("Stats", Stats)

---------------------------------------------
-- METHODS
---------------------------------------------

-- Unavailable as the relevant call is currently bugged.
--@param statID string
--@param statType StatsObjectType?
--@return GUID
-- function Stats.GetSourceMod(statID, statType)
--     local mods = Ext.Mod.GetLoadOrder()
--     local source

--     for _,guid in ipairs(mods) do
--         print(Text.EqualizeSpace(Ext.Mod.GetMod(guid).Info.Name, guid, 130))
--     end

--     for i,guid in ipairs(mods) do
--         local stats = Ext.Stats.GetStatsLoadedBefore(guid, statType)

--         for _,stat in ipairs(stats) do
--             if stat == statID then
--                 source = mods[i - 1] -- If we find a stat in mod[i], it was declared in mods[i - 1].
--                 break
--             end
--         end

--         if source then
--             break
--         end
--     end
    
--     return source
-- end

---Returns whether char meets the requirements for a stat object to be used.
---@param char Character
---@param statID string
---@param isItem boolean
---@param itemSource Item?
---@return boolean
function Stats.MeetsRequirements(char, statID, isItem, itemSource)
    local data = Ext.Stats.Get(statID)
    local stats = char.Stats
    local isEquipment = false
    -- local dynamicStats = char.Stats.DynamicStats

    if isItem and itemSource then
        if not itemSource.Stats then
            return true
        else
            isEquipment = itemSource.Stats.ItemType ~= ""
        end
    end

    -- Dead chars cannot use skills or items.
    if Game.Character.IsDead(char) then
        return false
    end

    if not data then
        return false
    end

    --- AP cost
    local apCost

    if isEquipment then
        apCost = 1 -- TODO is this affected by extra AP costs?
    elseif itemSource and itemSource.StatsId then
        apCost = Item.GetUseAPCost(itemSource)
    else
        apCost, _ = Game.Math.GetSkillAPCost(data, char.Stats, Ext.Entity.GetAiGrid(), char.Translate, 1)
    end

    apCost = apCost or 0

    -- Consider APCostBoost
    local extraApCost = Stats.CountStat(char.Stats, "APCostBoost")
    if stats.CurrentAP < apCost + extraApCost then
        return false
    end

    -- Muted
    if not isItem and data.IgnoreSilence ~= "Yes" and (data.UseWeaponDamage ~= "Yes" and (data.Requirement == "None" or data.Requirement == "ShieldWeapon")) then
        if Game.Character.IsMuted(char) then
            return false
        end
    end

    -- Disarmed
    if not isItem and (data.Requirement ~= "None" or data.UseWeaponDamage == "Yes") then
        if Game.Character.IsDisarmed(char) then
            return false
        end
    end

    -- Source cost
    if not isItem and data["Magic Cost"] > 0 then
        local mpCost = data["Magic Cost"]

        if char.Stats.MPStart < mpCost or char:GetStatus("SOURCE_MUTED") ~= nil then
            return false
        end
    end

    ---@type EclSkill
    local charSkillData = char.SkillManager.Skills[statID]

    -- Cooldown
    if charSkillData and charSkillData.ActiveCooldown > 0 and not itemSource then
        return false
    end

    local grantedByExternalSource = false or itemSource
    if charSkillData and not itemSource then
        grantedByExternalSource = charSkillData.CauseListSize > 0
    end

    -- Memorization
    if charSkillData and (not charSkillData.IsLearned and not grantedByExternalSource) then
        return false
    end
    
    -- Weapon requirements
    if not isItem and data.Requirement ~= "None" then
        if data.Requirement == "MeleeWeapon" and not Game.Character.HasMeleeWeapon(char) then
            return false
        elseif data.Requirement == "RangedWeapon" and not Character.HasRangedWeapon(char) then
            return false
        elseif data.Requirement == "ShieldWeapon" and not Game.Character.HasShield(char) then
            return false
        elseif data.Requirement == "DaggerWeapon" and not Game.Character.HasDagger(char) then
            return false
        end
    end

    -- Only check other requirements if this spell is natural to the character
    if not grantedByExternalSource then
        -- Requirements
        for _,req in ipairs(data.Requirements) do
            local reqMet = false

            if req.Requirement == "Combat" then
                reqMet = Character.IsInCombat(char)
            elseif req.Requirement == "Tag" then
                reqMet = char:HasTag(req.Param)
            elseif req.Requirement == "Immobile" then
                reqMet = Character.GetMovement(char) <= 0
            else
                reqMet = Stats.MeetsRequirementsINT(char, req)
            end

            if req.Not then
                reqMet = not reqMet
            end

            if not reqMet then
                return false
            end
        end

        -- Memorization requirements
        if not isItem then
            for _,req in ipairs(data.MemorizationRequirements) do
                if not Stats.MeetsRequirementsINT(char, req) then
                    return false
                end
            end
        end
    end

    if itemSource and itemSource.Stats then
        for _,req in ipairs(itemSource.Stats.Requirements) do
            local reqMet = false

            if req.Requirement == "Combat" then
                reqMet = Character.IsInCombat(char)
            elseif req.Requirement == "Tag" then
                reqMet = char:HasTag(req.Param)
            elseif req.Requirement == "Immobile" then
                reqMet = Character.GetMovement(char) <= 0
            else
                reqMet = Stats.MeetsRequirementsINT(char, req)
            end

            if req.Not then
                reqMet = not reqMet
            end

            if not reqMet then
                return false
            end
        end
    end

    return true
end

---@alias StatsObjectType "ItemColor"|"Boost"|"Armor"|"Weapon"|"SkillData"|"Object"|"Character"|"Data"|"ItemProgressionNames"|"ItemProgressionVisuals"|"Potion"|"Requirements"|"Shield"|"StatusData"|"CraftingStationsItemComboPreviewData"|"DeltaModifier"|"Equipment"|"ItemCombos"|"ItemTypes"|"ObjectCategoriesItemComboPreviewData"|"SkillSet"|"TreasureGroups"|"TreasureTable"|"DeltaMod"

---@param statType StatsObjectType
---@param id string
---@return unknown
function Stats.Get(statType, id)
    local object

    if Stats.STATS_OBJECT_TYPES[statType] then
        object = Ext.Stats.Get(id, nil, false, false)  
    elseif statType == "ItemColor" then
        object = Ext.Stats.ItemColor.Get(id)
    elseif statType == "DeltaModifier" or statType == "DeltaMod" then
        object = Ext.Stats.DeltaMod.GetLegacy(id, "Armor") or Ext.Stats.DeltaMod.GetLegacy(id, "Weapon") or Ext.Stats.DeltaMod.GetLegacy(id, "Shield")
    elseif statType == "TreasureTable" then
        object = Ext.Stats.TreasureTable.GetLegacy(id)
    elseif statType == "TreasureGroups" then
        object = Ext.Stats.TreasureCategory.GetLegacy(id)
    elseif statType == "Data" then
        object = Ext.ExtraData[id]
    else
        Stats:LogError("Attempted to fetch unsupported stat type: " .. statType)
    end

    return object
end

---@param statType StatsObjectType
---@param data any
function Stats.Update(statType, data, ...)

    if statType == "ItemColor" then
        Ext.Stats.ItemColor.Update(data)
    elseif statType == "DeltaModifier" or statType == "DeltaMod" then
        Ext.Stats.DeltaMod.Update(data)
    elseif statType == "TreasureTable" then
        Ext.Stats.TreasureTable.Update(data)
    -- elseif statType == "TreasureGroups" then
    --     TODO
    elseif statType == "Data" then
        Ext.ExtraData[data] = ...
    else
        Stats:LogError("Attempted to update unsupported stat type: " .. statType)
    end
end

---@param status EclStatus|EsvStatus
function Stats.IsStatusVisible(status)
    local icon = Stats.GetStatusIcon(status)

    return icon and icon ~= "unknown" and icon ~= "" 
end

local HARDCODED_STATUS_ICONS = {
    ADRENALINE = "statIcons_Adrenaline",
    CHARMED = "statIcons_Charmed",
    CLEAN = "statIcons_Clean",
    DYING = "statIcons_Dead",
    ENCUMBERED = "statIcons_Encumbered",
    LEADERSHIP = "statIcons_Leadership", -- This one does have a potion entry, why doesn't our code pick it up? TODO investigate
}

---@param status EclStatus|EsvStatus
function Stats.GetStatusIcon(status)
    local stat = Stats.Get("StatusData", status.StatusId)
    local icon

    if stat then
        icon = stat.Icon

        if icon == "" then -- Fetch potion instead
            local potion = Stats.Get("Potion", stat.StatsId)

            if potion then
                icon = potion.StatusIcon
            end
        end
    end

    -- Use hardcoded icons for hardcoded status types.
    icon = icon or HARDCODED_STATUS_ICONS[status.StatusId]

    if not icon then
        Stats:LogError("GetStatusIcon(): Could not find icon for " .. status.StatusId)
        icon = "unknown"
    end

    return icon
end

function Stats.CountStat(stats, stat)
    local count = 0
    local dynStats = stats.DynamicStats

    for i=1,#dynStats,1 do
        local dynStat = dynStats[i]
        count = count + dynStat[stat]
    end

    -- Items
    -- for i,slot in ipairs(Data.Game.EQUIP_SLOTS) do
    --     local statItem = stats:GetItemBySlot(slot)

    --     if statItem then
    --         dynStats = statItem.DynamicStats
    --         for i=1,#dynStats,1 do
    --             local dynStat = dynStats[i]
    --             count = count + dynStat[stat]
    --         end
    --     end
    -- end

    return count
end

function Stats.MeetsRequirementsINT(char, req)
    local reqMet = false

    if req.Requirement == "None" then
        reqMet = true
    elseif req.Requirement == "Tag" then
        reqMet = char:HasTag(req.Param)
    elseif type(char.Stats[req.Requirement]) == "boolean" then
        reqMet = char.Stats[req.Requirement]
    else
        local amount = char.Stats[req.Requirement]

        reqMet = amount >= req.Param
    end

    if req.Not then
        reqMet = not reqMet
    end

    return reqMet
end