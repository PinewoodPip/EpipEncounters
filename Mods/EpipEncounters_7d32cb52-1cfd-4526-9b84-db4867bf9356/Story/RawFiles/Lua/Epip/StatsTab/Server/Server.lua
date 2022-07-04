
---------------------------------------------
-- Server-side scripting for our custom stats tab stats.
---------------------------------------------

---@type EpipStats
local EpipStats = Epip.Features.StatsTab

function EpipStats.GetCelestialRestoration(char)
    return Osiris.QRY_AMER_KeywordStat_Celestial_GetHeal(char.MyGuid)
end

function EpipStats.GetExtendedStat(char, type, param1, param2, param3)
    local _, _, _, _, _, amount = Osiris.DB_AMER_ExtendedStat_AddedStat(char.MyGuid, type, param1, param2, param3, nil)

    amount = amount or 0
    
    return amount
end

function EpipStats.GetCurrentReactionCharges(char, reaction)
    local guid, reaction, amount = Osiris.DB_AMER_Reaction_FreeCount_Remaining(char.MyGuid, reaction, nil)

    amount = amount or 0

    return amount
end

-- Refresh the tagged stats for all ascension stats, for all characters.
function EpipStats.RecalculateNodeStats()
    -- Char, UI, Cluster, Node, SubNode
    local db = Osiris.DatabaseQuery("DB_AMER_UI_ElementChain_Node_ChildNode_StateData", false, nil, "AMER_UI_Ascension", nil, nil, nil)

    for i,entry in pairs(db) do
        local charGUID, _, cluster, node, subNode = table.unpack(entry)
        local char = Ext.GetCharacter(charGUID)
        local stat = cluster .. "_" .. node .. "." .. subNode

        if EpipStats.STATS[stat] then
            EpipStats.UpdateTaggedStat(char, stat, 1)
        end
    end
end

function PerformFullStatsUpdate()
    EpipStats.RecalculateNodeStats()

    for i,entry in pairs(Osi.DB_IsPlayer:Get(nil)) do
        UpdateCustomStatsForCharacter(entry[1])
    end
end

-- Called from Osisirs. Sends events for each stat registered.
function UpdateCustomStatsForCharacter(char)
    EpipStats:Log("Updating stats of " .. char)
    char = Ext.GetCharacter(char)

    for id,data in pairs(EpipStats.STATS) do
        Utilities.Hooks.FireEvent("Epip_StatsTab", "UpdateStat", char, id, data)
        Utilities.Hooks.FireEvent("Epip_StatsTab", "UpdateStat_" .. id, char, data)
    end

    Game.Net.PostToUser(char, "EPIPENCOUNTERS_RefreshStatsTab")
end

-- Update the tag storing a stat's value for a char.
function EpipStats.UpdateTaggedStat(char, stat, newValue)

    -- TODO allow decimals
    newValue = Ext.Utils.Round(newValue, 2)

    -- remove previous tag
    for i,tag in pairs(char:GetTags()) do

        local statInTag,oldAmount = tag:match(EpipStats.STAT_VALUE_TAG)
        if statInTag == stat then
            Osi.ClearTag(char.MyGuid, tag)
            break
        end
    end

    EpipStats:DebugLog("Tag updated: " .. stat)

    -- Tags are not added for values of 0.
    if newValue ~= 0 then
        Osi.SetTag(char.MyGuid, EpipStats.STAT_VALUE_TAG_PREFIX .. stat .. "_" .. RemoveTrailingZeros(newValue))
    end
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Allocating nodes
Ext.Osiris.RegisterListener("PROC_AMER_UI_Ascension_NodeAllocated", 3, "after", function (char, cluster, node)
    local statID = string.format("%s_%s", cluster, node)

    -- Only add a tag for relevant stats, so as to reduce bloat
    if EpipStats.STATS[statID] then
        EpipStats.UpdateTaggedStat(Ext.GetCharacter(char), statID, 1)
    else
        Game.Net.PostToCharacter(char, "EPIPENCOUNTERS_RefreshStatsTab")
    end
end)

-- De-allocating nodes
Ext.Osiris.RegisterListener("PROC_AMER_UI_Ascension_NodeDeallocated", 3, "after", function (char, cluster, node)
    local statID = string.format("%s_%s", cluster, node)

    -- Only add a tag for relevant stats, so as to reduce bloat
    if EpipStats.STATS[statID] then
        EpipStats.UpdateTaggedStat(Ext.GetCharacter(char), statID, 0)
    else
        Game.Net.PostToCharacter(char, "EPIPENCOUNTERS_RefreshStatsTab")
    end
end)

-- Requested update from client
Game.Net.RegisterListener("EPIPENCOUNTERS_UpdateCustomStats", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)
    UpdateCustomStatsForCharacter(char.MyGuid)
end)

function EpipStats.RegisterListener(event, handler)
    Utilities.Hooks.RegisterListener("Epip_StatsTab", event, handler)
end

-- Listen for this event to update stats. A generic event is also available.
function EpipStats.RegisterStatUpdateListener(stat, handler)
    EpipStats.RegisterListener("UpdateStat_" .. stat, handler)
end