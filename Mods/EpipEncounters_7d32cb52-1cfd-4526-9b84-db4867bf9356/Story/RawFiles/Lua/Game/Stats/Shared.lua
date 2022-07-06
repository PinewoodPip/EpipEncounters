
---@meta GameStats, ContextShared

Stats = {
    STATS_OBJECT_TYPES = {
        Boost = true,
        Armor = true,
        Weapon = true,
        Skill = true,
        Object = true,
        Character = true,
        Shield = true,
        Status = true,
        Potion = true,
    },
}
Game.Stats = Stats
Epip.InitializeLibrary("Stats", Stats)

---Returns whether char meets the requirements for a stat object to be used.
---@param char Character
---@param skillID string
---@return boolean
function Stats.MeetsRequirements(char, statID, isItem)
    local data = Ext.Stats.Get(statID)
    local stats = char.Stats
    local dynamicStats = char.Stats.DynamicStats

    -- Dead chars cannot use skills or items.
    if Game.Character.IsDead(char) then
        return false
    end

    if not data then
        return false
    end

    --- AP cost
    if not isItem then
        local apCost,EA = Game.Math.GetSkillAPCost(data, char.Stats, Ext.Entity.GetAiGrid(), char.Translate, 1)

        -- Consider APCostBoost
        local extraApCost = Stats.CountStat(char.Stats, "APCostBoost")
        if stats.CurrentAP < apCost + extraApCost then
            return false
        end
    end

    -- Muted
    if not isItem and data.IgnoreSilence ~= "Yes" and (data.UseWeaponDamage ~= "Yes" and (data.Requirement == "None" or data.Requirement == "ShieldWeapon")) then
        if Game.Character.IsMuted(char) then
            return false
        end
    end

    -- Disarmed
    if not isItem and data.Requirement ~= "None" then
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
    if charSkillData and charSkillData.ActiveCooldown > 0 then
        return false
    end

    local grantedByExternalSource = false
    if charSkillData then
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
        elseif data.Requirement == "RangedWeapon" and not Game.Character.HasRangedWeapon(char) then
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
                reqMet = Game.Character.IsInCombat(char, skillID)
            elseif req.Requirement == "Tag" then
                reqMet = char:HasTag(req.Param)
            elseif req.Requirement == "Immobile" then
                reqMet = Game.Character.GetMovement(char) <= 0
            else
                if not Stats.MeetsRequirementsINT(char, req) then
                    return false
                else
                    reqMet = true
                end
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
            for i,req in ipairs(data.MemorizationRequirements) do
                if not Stats.MeetsRequirementsINT(char, req) then
                    return false
                end
            end
        end
    end

    return true
end

---@alias StatsObjectType "ItemColor"|"Boost"|"Armor"|"Weapon"|"Skill"|"Object"|"Character"|"Data"|"ItemProgressionNames"|"ItemProgressionVisuals"|"Potion"|"Requirements"|"Shield"|"Status"|"CraftingStationsItemComboPreviewData"|"DeltaModifier"|"Equipment"|"ItemCombos"|"ItemTypes"|"ObjectCategoriesItemComboPreviewData"|"SkillSet"|"TreasureGroups"|"TreasureTable"|"DeltaMod"

---@param statType StatsObjectType
---@param id string
---@return any
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

    if type(char.Stats[req.Requirement]) == "boolean" then
        reqMet = char.Stats[req.Requirement]
    else
        local amount = char.Stats[req.Requirement]

        -- Attribute requirements appear bugged at the moment.
        if not Data.Game.ATTRIBUTE_STATS[req.Requirement] then
            reqMet = amount >= req.Param
        else
            reqMet = true
        end
    end

    if req.Not then
        reqMet = not reqMet
    end

    if not reqMet then
        return false
    end

    return true
end