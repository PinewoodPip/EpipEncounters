
---------------------------------------------
-- Server-side scripting for our custom stats tab stats.
---------------------------------------------

---@class Feature_CustomStats
local EpipStats = Epip.GetFeature("Feature_CustomStats")

function EpipStats.GetCelestialRestoration(char)
    return Osiris.QRY_AMER_KeywordStat_Celestial_GetHeal(char.MyGuid)
end

---Queries the amount of an ExtendedStat.
---@param char EsvCharacter
---@param type string
---@param param1 string?
---@param param2 string?
---@param param3 string?
---@return integer --Defaults to 0 for absent stats.
function EpipStats.GetExtendedStat(char, type, param1, param2, param3)
    return Osiris.GetFirstFactOrEmpty("DB_AMER_ExtendedStat_AddedStat", char.MyGuid, type, param1, param2, param3, nil)[6] or 0
end

---Queries the amount of remaining free reaction charges.
---@param char EsvCharacter
---@param reaction string
---@return integer --Defaults to 0 for absent stats.
function EpipStats.GetCurrentReactionCharges(char, reaction)
    return Osiris.GetFirstFactOrEmpty("DB_AMER_Reaction_FreeCount_Remaining", char.MyGuid, reaction, nil)[3] or 0
end

---Refreshes the tracked stats for all ascension stats, for all characters.
function EpipStats.RecalculateNodeStats()
    -- Params: Char, UI, Cluster, Node, SubNode
    local tuples = Osiris.QueryDatabase("DB_AMER_UI_ElementChain_Node_ChildNode_StateData", nil, "AMER_UI_Ascension", nil, nil, nil)
    for _,entry in pairs(tuples) do
        local charGUID, _, cluster, node, subNode = table.unpack(entry)
        local char = Ext.GetCharacter(charGUID)
        local stat = cluster .. "_" .. node .. "." .. subNode

        if EpipStats.STATS[stat] then
            EpipStats.UpdateUserVarStat(char, stat, 1)
        end
    end
end

function PerformFullStatsUpdate()
    EpipStats.RecalculateNodeStats()

    for _,entry in pairs(Osi.DB_IsPlayer:Get(nil)) do
        UpdateCustomStatsForCharacter(entry[1])
    end
end

-- Called from Osisirs. Sends events for each stat registered.
function UpdateCustomStatsForCharacter(charGUID)
    EpipStats:Log("Updating stats of " .. charGUID)
    local char = Character.Get(charGUID)

    for id,data in pairs(EpipStats.STATS) do
        Utilities.Hooks.FireEvent("Epip_StatsTab", "UpdateStat", char, id, data)
        Utilities.Hooks.FireEvent("Epip_StatsTab", "UpdateStat_" .. id, char, data)
    end

    Net.PostToUser(char.UserID, "EPIPENCOUNTERS_RefreshStatsTab")
end

-- Update the tag storing a stat's value for a char.
function EpipStats.UpdateUserVarStat(char, stat, newValue)
    EpipStats:DebugLog("User var stat updated: " .. stat)

    local stats = EpipStats:GetUserVariable(char, EpipStats.USERVAR_STATS)
    stats[stat] = newValue
    EpipStats:SetUserVariable(char, EpipStats.USERVAR_STATS, stats)
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Allocating nodes
Ext.Osiris.RegisterListener("PROC_AMER_UI_Ascension_NodeAllocated", 3, "after", function (char, cluster, node)
    local statID = string.format("%s_%s", cluster, node)

    -- Only add a tag for relevant stats, so as to reduce bloat
    if EpipStats.STATS[statID] then
        EpipStats.UpdateUserVarStat(Character.Get(char), statID, 1)
    else
        Net.PostToCharacter(char, "EPIPENCOUNTERS_RefreshStatsTab")
    end
end)

-- De-allocating nodes
Ext.Osiris.RegisterListener("PROC_AMER_UI_Ascension_NodeDeallocated", 3, "after", function (char, cluster, node)
    local statID = string.format("%s_%s", cluster, node)

    -- Only add a tag for relevant stats, so as to reduce bloat
    if EpipStats.STATS[statID] then
        EpipStats.UpdateUserVarStat(Character.Get(char), statID, 0)
    else
        Net.PostToCharacter(char, "EPIPENCOUNTERS_RefreshStatsTab")
    end
end)

-- Requested update from client
Net.RegisterListener("EPIPENCOUNTERS_UpdateCustomStats", function(payload)
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