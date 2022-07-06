
---------------------------------------------
-- Server implementation for debug cheats.
---------------------------------------------

-- Warp to AMER_Test.
Game.Net.RegisterListener("EPIPENCOUNTERS_WARPPARTY", function(cmd, payload)
    CharacterTeleportPartiesToTrigger(payload.Trigger, "")
end)

-- Kill/Resurrect.
Game.Net.RegisterListener("EPIP_CHEATS_KILLRESURRECT", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    if Osi.CharacterIsDead(char.MyGuid) == 0 then
        Osi.CharacterDie(char.MyGuid, 0, "DoT", Data.NULLGUID)
    else
        Osi.CharacterResurrect(char.MyGuid)
    end
end)

-- Add tag.
Game.Net.RegisterListener("EPIP_CHEATS_ADDTAG", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    print(payload.Tag)
    SetTag(char.MyGuid, payload.Tag)
end)

-- Remove tag.
Game.Net.RegisterListener("EPIP_CHEATS_REMOVETAG", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    ClearTag(char.MyGuid, payload.Tag)
end)

-- Restore HP + Armors.
Game.Net.RegisterListener("EPIP_CHEATS_HEAL", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    Osi.PROC_AMER_GEN_Heal_Percentage(char.MyGuid, 100, "All", char.MyGuid, 1, 0)
end)

-- Give AP/SP.
Game.Net.RegisterListener("EPIP_CHEATS_GIVESP", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    Osi.PROC_AMER_CharacterAddSourcePoints(char.MyGuid, 99)
    Osi.PROC_AMER_ActionPoints_Add(char.MyGuid, 99)
end)

-- Reset cooldowns.
Game.Net.RegisterListener("EPIP_CHEATS_RESETCDS", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    Osi.CharacterResetCooldowns(char.MyGuid)
end)

-- Give Flexstat spells.
Game.Net.RegisterListener("EPIP_CHEATS_SPELL", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    Osi.PROC_AMER_FlexStat_CharacterAddStat(char.MyGuid, "Spell", payload.StatsID)
end)

-- Give numeric Flexstats
Game.Net.RegisterListener("EPIP_CHEATS_FLEXSTAT", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)
    
    local stat = payload.Stat
    local type = payload.StatType
    local amount = payload.Amount

    local tagAmount = amount

    -- remove previous tag
    for i,tag in pairs(char:GetTags()) do

        local statInTag,oldAmount = tag:match("PIP_CHEATEDSTATS_(.*)_(-?[0-9]*)$")
        if statInTag == stat then
            tagAmount = tagAmount + tonumber(oldAmount)
            Osi.ClearTag(char.MyGuid, tag)
            break
        end
    end

    Osi.PROC_AMER_FlexStat_CharacterAddStat(char.MyGuid, type, stat, amount)
    Osi.SetTag(char.MyGuid, "PIP_CHEATEDSTATS_" .. stat .. "_" .. Text.RemoveTrailingZeros(tagAmount))
end)

-- Teleport to object.
Game.Net.RegisterListener("EPIP_CHEATS_TELEPORTTO", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)
    local target = Ext.GetCharacter(payload.TargetGUID)

    -- Try as ITEMGUID
    if not target then
        target = Ext.GetItem(payload.TargetGUID)
    end

    -- Try as TRIGGERGUID
    if not target then
        target = Ext.GetTrigger(payload.TargetGUID)
    end

    if target then
        Osi.PROC_AMER_TeleportTo(char.MyGuid, target.MyGuid)
    end
end)

-- Grant treasure.
Game.Net.RegisterListener("EPIP_CHEATS_GRANTTREASURE", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)
    local treasure = payload.Treasure
    local rolls = payload.Amount

    for i=0,rolls,1 do
        Osi.PROC_PIP_GrantTreasure(char.MyGuid, treasure)
    end
end)

-- Add SpecialLogic.
Game.Net.RegisterListener("EPIP_CHEATS_SPECIALLOGIC", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    Osi.PROC_AMER_UI_Ascension_SpecialLogic_Add(char.MyGuid, payload.SpecialLogic, payload.Amount)
end)

-- Add all artifacts.
Game.Net.RegisterListener("EPIPENCOUNTERS_CHEATS_SPAWNARTIFACTS", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    for i,tuple in pairs(Osi.DB_AMER_Artifacts:Get(nil, nil, nil, nil)) do
        local root,runeRoot,slot,id = tuple[1],tuple[2],tuple[3],tuple[4]

        if root ~= "AMER_UNI_Deck_94902e34-3693-460c-a7a4-81f27cfc5ec7" then
            Osi.ItemTemplateAddTo(root, char.MyGuid, 1, 1)
        end
    end
end)

-- Add all artifacts foci.
Game.Net.RegisterListener("EPIPENCOUNTERS_CHEATS_SPAWNARTIFACTSFOCI", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    Epip.Features.AutoIdentify.SetForceEnable(true)
    
    for i,tuple in pairs(Osi.DB_AMER_Artifacts:Get(nil, nil, nil, nil)) do
        local root,runeRoot,slot,id = tuple[1],tuple[2],tuple[3],tuple[4]

        if root ~= "AMER_UNI_Deck_94902e34-3693-460c-a7a4-81f27cfc5ec7" then
            Osi.ItemTemplateAddTo(runeRoot, char.MyGuid, 1, 1)
        end
    end

    Epip.Features.AutoIdentify.SetForceEnable(false)
end)

-- Add item template.
Game.Net.RegisterListener("EPIP_CHEATS_ITEMTEMPLATE", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)
    local template = payload.TemplateGUID
    
    Osi.ItemTemplateAddTo(template, char.MyGuid, tonumber(payload.Amount), 1)
end)

-- Godmode/Pipmode: Infinite AP, resets cooldowns, RESISTDEATH.
Game.Net.RegisterListener("EPIP_CHEATS_INFINITEAP", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)
    
    if not char:HasTag("PIP_DEBUGCHEATS_INFINITEAP") then
        Osi.SetTag(char.MyGuid, "PIP_DEBUGCHEATS_INFINITEAP")
        Osi.PROC_AMER_FlexStat_CharacterAddStat_BinaryStat(char.MyGuid, "RESISTDEATH", 1)
    else
        Osi.ClearTag(char.MyGuid, "PIP_DEBUGCHEATS_INFINITEAP")
        Osi.PROC_AMER_FlexStat_CharacterAddStat_BinaryStat(char.MyGuid, "RESISTDEATH", -1)
    end
end)

Ext.Osiris.RegisterListener("PROC_AMER_ActionPoints_Changed", 3, "after", function(char, old, new)

    if Osi.IsTagged(char, "PIP_DEBUGCHEATS_INFINITEAP") == 1 then
        -- Avoids an infinite loop
        if new < old then
            Osi.PROC_AMER_ActionPoints_Add(char, 99)
        end
        Osi.CharacterResetCooldowns(char)
    end
end)

-- Teleport to cursor.
Game.Net.RegisterListener("EPIPENCOUNTERS_CHEATS_TeleportChar", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)
    local pos = payload.Position
    local teleportParty = payload.TeleportParty

    if teleportParty then
        local _,tuples = Osiris.DB_IsPlayer:Get(nil)

        for i,tuple in ipairs(tuples) do
            local player = tuple[1]

            TeleportToPosition(player, pos[1], pos[2], pos[3], "", 1)
        end
    else
        TeleportToPosition(char.MyGuid, pos[1], pos[2], pos[3], "", 0)
    end

end)