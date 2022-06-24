
---@meta GameStats, ContextShared

Game.Stats = {
}
local Stats = Game.Stats
Epip.InitializeLibrary("Stats", Stats)

local ElementalAffinityAiFlags = {
    Fire = {0x1000000, 0x20000000},
    Water = { 0x2000000 },
    Air = { 0x40000000000000 },
    Earth = { 0x10000000, 0x8000000 },
    Death = { 0x4000000 },
    Sulfurology = { 0x200000000 }
}

function bitand(a, b)
    local result = 0
    local bitval = 1
    while a > 0 and b > 0 do
      if a % 2 == 1 and b % 2 == 1 then -- test the rightmost bits
          result = result + bitval      -- set the current bit
      end
      bitval = bitval * 2 -- shift left
      a = math.floor(a/2) -- shift right
      b = math.floor(b/2)
    end
    return result
end

function GetSkillAPCost(skill, character, grid, position, radius)
    local baseAP = skill.ActionPoints
    if character == nil or baseAP <= 0 then
        return baseAP, false
    end
    
    local ability = skill.Ability
    local elementalAffinity = false
    if ability ~= "None" and baseAP > 1 and character.TALENT_ElementalAffinity and grid ~= nil and position ~= nil and radius ~= nil then
        local aiFlags = ElementalAffinityAiFlags[ability]
        if aiFlags ~= nil then
            elementalAffinity = grid:SearchForCell(position[1], position[3], radius, aiFlags[1], -1.0)

            local cell = grid:GetCellInfo(position[1], position[3])
            
            elementalAffinity = bitand(cell.Flags, aiFlags[1]) > 0

            if elementalAffinity then
                baseAP = baseAP - 1
            end
        end
    end

    local characterAP = 1
    if skill.Requirement ~= "None" and skill.OverrideMinAP == "No" then
        characterAP = Game.Math.GetCharacterWeaponAPCost(character)
    end

    return math.max(characterAP, baseAP), elementalAffinity
end

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
        local apCost,EA = GetSkillAPCost(data, char.Stats, Ext.Entity.GetAiGrid(), char.Translate, 1)

        -- Consider APCostBoost
        local extraApCost = Stats.CountStat(char.Stats, "APCostBoost")
        if stats.CurrentAP < apCost + extraApCost then
            return false
        end
    end

    -- Muted
    if not isItem and data.IgnoreSilence ~= "Yes" and (data.UseWeaponDamage ~= "Yes" and data.Requirement == "None") then
        if Game.Character.IsMuted(char) then
            return false
        end
    end

    -- Disarmed
    if not isItem and data.UseWeaponDamage == "Yes" then
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
        for i,req in ipairs(data.Requirements) do
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