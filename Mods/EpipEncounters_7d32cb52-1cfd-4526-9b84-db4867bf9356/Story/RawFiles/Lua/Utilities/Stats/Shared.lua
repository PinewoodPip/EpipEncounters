
local Set = DataStructures.Get("DataStructures_Set")

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
        Crime = true,
    },
    _STAT_OBJECT_CLASSES = Set.Create({
        "StatsLib_StatsEntry_Weapon",
        "StatsLib_StatsEntry_Armor",
        "StatsLib_StatsEntry_Shield",
        "StatsLib_StatsEntry_Character",
        "StatsLib_StatsEntry_Object",
        "StatsLib_StatsEntry_Crime",
        "StatsLib_StatsEntry_Potion",
        "StatsLib_StatsEntry_SkillData",
        "StatsLib_StatsEntry_StatusData"
    }),

    CONSUME_STATUS_SUBTYPES = Set.Create({
        "ACTIVE_DEFENSE",
        "ADRENALINE",
        "DAMAGE",
        "DAMAGE_ON_MOVE",
        "CHALLENGE",
        "CHARMED",
        "ENCUMBERED",
        "FLOATING",
        "GUARDIAN_ANGEL",
        "HEALING",
        "INCAPACITATED",
        "LEADERSHIP",
        "POLYMORPHED",
        "SPARK",
    }),
    STATUS_TYPES_WITH_STATS_DISPLAY_NAME = Set.Create({
        "FEAR",
        "HEALING",
        "BLIND",
        "KNOCKED_DOWN",
        "MUTED",
        "STANCE", -- Not tested
        "DAMAGE_ON_MOVE",
    }),
    HARDCODED_STATUS_NAME_HANDLES = {
        DYING = "h2e807311g8c4bg4141g85f3gcc88ee095888",
        FLOATING = "h278121a7g2132g4efdgb151g9af722d670dc",
        HEAL = "h069389c2gc635g4e5cga15fg28d1eae30e3e",
        CHARMED = "h30fc0122g6378g408cgac6fg6e3bcb3c852b",
        THROWN = "hfa754958gff75g4474g8cd5g508b4fb7a984",
        SNEAKING = "h6bf7caf0g7756g443bg926dg1ee5975ee133",
        SITTING = "h33b529f1g6fb3g4210g8b40ga41e4d05c0d0",
        SMELLY = "h312fc6d0gd271g40ffg949dge80fba98335e",
        CLEAN = "h8fb688afg29efg4804g9d68g955c3c463053",
        INVISIBLE = "h7fa4cea8gf162g40a8g83cbg133d613ee6eb",
        ENCUMBERED = "hdc2c6815g4c4fg4e81g94d5g299646e91500",
        LEADERSHIP = "h7c65fe39g1526g427bg8a2dgab7e74c66202",
        ADRENALINE = "h4c891442g3b79g4dbeg906fgf8eeffcf60df",
        SHACKLES_OF_PAIN = "h36a82a09gc2dag46feg990cgf3807db54d54",
        SHACKLES_OF_PAIN_CASTER = "h89ad2635gd8acg4dc1gb7f5g2287082b3733",
        WIND_WALKER = "hc7566374g36afg4345gaf18gab4ba7d7c809",
        DARK_AVENGER = "h64892b81g9543g4608ga303gcffa5055d869",
        REMORSE = "h7e0fe51fg9df2g4854gb8f1g183251dcc25b",
        DECAYING_TOUCH = "hbc2789fegb2deg4952ga436ga8a0aad070bf",
        UNHEALABLE = "hc33f0ac7gc3f0g47b3gba3cg8c3ddb82508e",
        FLANKED = "hd052e4cfg1a83g4ee5g886cgbf15dc656a0b",
        DRAIN = "h9cf08d12gc1b8g4c7cg8662g40d03ca96df5",
        LINGERING_WOUNDS = "h3924a821gdb1fg4d6fg920eg62ee3c4586ed",
        INFUSED = "hae4ca8a4g56feg480eg95c8ge5761ab1eb2e",
        SPIRIT = "h90cedca8g690cg4aabg8df0g98da27d72991",
        SOURCE_MUTED = "h534aec4fgecc5g4b34gb0f5g8b08c3c4309e",
        GUARDIAN_ANGEL = "hfe33ce6aged4fg4cb7g8bd8g47e3956c6ba7",
        DISARMED = "h4904c1c3g1485g48a1g9084g13b821449d0f",
        EXTRA_TURN = "h320c5fb3gca9dg4f13gb43ag5f41792b28b3",
        PLAY_DEAD = "hb541d496g70efg45cbg84c9g07e626209303",
        DEACTIVATED = "h134f5495g54ccg48a9g96bfgcdbdd31faec0",
    },

    HARDCODED_STATUS_ICONS = {
        ADRENALINE = "statIcons_Adrenaline",
        CHARMED = "statIcons_Charmed",
        CLEAN = "statIcons_Clean",
        DYING = "statIcons_Dead",
        ENCUMBERED = "statIcons_Encumbered",
        SNEAKING = "Action_Sneak",
        LEADERSHIP = "statIcons_Leadership", -- This one does have a potion entry, why doesn't our code pick it up? TODO investigate
        SHACKLES_OF_PAIN = "statIcons_ShacklesOfPain",
        SHACKLES_OF_PAIN_CASTER = "statIcons_ShacklesOfPain",
        SOURCE_MUTED = "statIcons_SourceMuted",
        WIND_WALKER = "statIcons_WindWalker",
        DARK_AVENGER = "statIcons_DarkAvenger_0", -- There's multiple tiers of this, not sure exactly how they behave
        REMORSE = "statIcons_Remorse",
        DECAYING_TOUCH = "statIcons_DecayingTouch",
        UNHEALABLE = "statIcons_Unhealable",
        FLANKED = "statIcons_Flanked",
        DRAIN = "Skill_Vampirism_Source",
        INFUSED = "Skill_Vampirism_Source",
        SPIRIT = "statIcons_Spirit",
        SPIRIT_VISION = "Skill_Source_SpiritVision",
        DISARMED = "statIcons_Disarmed",
        EXTRA_TURN = "Skill_TimeWarp",
    },
    HARDCODED_STATUSES_WITHOUT_ICONS = Set.Create({
        "UNSHEATHED",
        "COMBAT",
        "INSURFACE",
        "HIT",
        "THROWN",
        "SHIELD",
        "ATTACKOFOPP",
        "STORY_FROZEN",
        "UNLOCK",
        "BOOST",
        "SITTING",
        "IDENTIFY",
        "REPAIR",
        "ROTATE",
        "EXPLODE",
        "CLIMBING",
        "SPARK",
        "TUTORIAL_BED",
        "TELEPORT_FALLING",
        "LYING",
        "FORCE_MOVE",
        "OVERPOWER",
        "COMBUSTION",
        "CHANNELING",
        "LINGERING_WOUNDS", -- statIcons_LingeringWounds exists but is unused.
        "DEACTIVATED",
        "CONSTRAINTED",
    }),

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
            local customReqMet = Ext.Stats.Requirement.Evaluate(stats, req.Requirement, req.Param, req.Tag, req.Not)

            if not customReqMet then
                return false
            end
        end
    end

    return true
end

---@alias StatsObjectType "ItemColor"|"Boost"|"Armor"|"Weapon"|"SkillData"|"Object"|"Character"|"Data"|"ItemProgressionNames"|"ItemProgressionVisuals"|"Potion"|"Requirements"|"Shield"|"StatusData"|"CraftingStationsItemComboPreviewData"|"DeltaModifier"|"Equipment"|"ItemCombos"|"ItemTypes"|"ObjectCategoriesItemComboPreviewData"|"SkillSet"|"TreasureGroups"|"TreasureTable"|"DeltaMod"

---Returns a stat object by its ID.
---@generic T
---@param statType StatsObjectType|StatsLib_StatsEntryType|`T`
---@param id string
---@return T
function Stats.Get(statType, id)
    local object

    if Stats.STATS_OBJECT_TYPES[statType] or Stats._STAT_OBJECT_CLASSES:Contains(statType) then
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

---Returns the display name of a status.
---@param status EclStatus|EsvStatus
---@return string --Defaults to status ID.
function Stats.GetStatusName(status)
    local name = nil
    local stat

    if Stats.HARDCODED_STATUS_NAME_HANDLES[status.StatusId] ~= nil then
        name = Ext.L10N.GetTranslatedString(Stats.HARDCODED_STATUS_NAME_HANDLES[status.StatusId], status.StatusId)
    elseif (status.StatusType == "CONSUME" and status.StatusId ~= "CONSUME") or Stats.CONSUME_STATUS_SUBTYPES:Contains(status.StatusType) or Stats.STATUS_TYPES_WITH_STATS_DISPLAY_NAME:Contains(status.StatusType) then
        ---@cast status EclStatusConsumeBase|EsvStatusConsume
        local statsID = status.StatusId
        stat = Stats.Get("StatsLib_StatsEntry_StatusData", statsID)

        if stat then
            name = Ext.L10N.GetTranslatedStringFromKey(stat.DisplayName)
        end
    elseif status.StatusType == "CONSUME" and status.StatusId == "CONSUME" then
        ---@cast status EclStatusConsumeBase|EsvStatusConsume
        name = Ext.L10N.GetTranslatedStringFromKey(status.StatsId)
    end

    return name or status.StatusId
end

---@param status EclStatus|EsvStatus
function Stats.GetStatusIcon(status)
    local stat = Stats.Get("StatsLib_StatsEntry_StatusData", status.StatusId)
    local isInvisible = Stats.HARDCODED_STATUSES_WITHOUT_ICONS:Contains(status.StatusId)
    local icon

    if not isInvisible then
        if status.StatusType == "CONSUME" then
            ---@cast status EclStatusConsumeBase|EsvStatusConsume
            icon = status.Icon
        elseif stat then
            icon = stat.Icon
    
            if icon == "" then -- Fetch potion instead
                local potion = Stats.Get("Potion", stat.StatsId) ---@type StatsLib_StatsEntry_Potion
                
                if potion then
                    icon = potion.StatusIcon

                    if icon == "" then -- Use RootTemplate icon instead
                        local template = Ext.Template.GetTemplate(potion.RootTemplate) ---@type ItemTemplate

                        icon = template and template.Icon or icon
                    end
                end
            end
        end
    
        -- Use hardcoded icons for hardcoded status types.
        icon = icon or Stats.HARDCODED_STATUS_ICONS[status.StatusId]
    
        if not icon and status.StatusId ~= "CONSUME" then
            Stats:LogWarning("GetStatusIcon(): Could not find icon for " .. status.StatusId)
            icon = "unknown"
        end
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