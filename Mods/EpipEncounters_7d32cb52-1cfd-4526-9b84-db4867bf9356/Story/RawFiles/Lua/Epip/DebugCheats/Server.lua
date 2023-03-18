
---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to toggle talents.
Net.RegisterListener("EPIPENCOUNTERS_Cheats_AddTalent", function(payload)
    local active = payload.State
    local talent = payload.Params.ID
    local char = Character.Get(payload.NetID)

    if active then
        Osi.CharacterAddTalent(char.MyGuid, talent)
    else
        Osi.CharacterRemoveTalent(char.MyGuid, talent)
    end
end)

-- Listen for requests to toggle Godmode/Pipmode: 
-- Infinite AP, resets cooldowns, RESISTDEATH.
Net.RegisterListener("EPIP_CHEATS_INFINITEAP", function(payload)
    local char = Ext.GetCharacter(payload.NetID)
    
    if not char:HasTag("PIP_DEBUGCHEATS_INFINITEAP") then
        Osi.SetTag(char.MyGuid, "PIP_DEBUGCHEATS_INFINITEAP")
        Osi.PROC_AMER_FlexStat_CharacterAddStat_BinaryStat(char.MyGuid, "RESISTDEATH", 1)
    else
        Osi.ClearTag(char.MyGuid, "PIP_DEBUGCHEATS_INFINITEAP")
        Osi.PROC_AMER_FlexStat_CharacterAddStat_BinaryStat(char.MyGuid, "RESISTDEATH", -1)
    end
end)