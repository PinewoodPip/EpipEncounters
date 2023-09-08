
---------------------------------------------
-- Server implementation for debug cheats.
---------------------------------------------

local AutoIdentify = Epip.GetFeature("Feature_AutoIdentify")

-- Warp to AMER_Test.
Net.RegisterListener("EPIPENCOUNTERS_WARPPARTY", function(payload)
    Osi.CharacterTeleportPartiesToTrigger(payload.Trigger, "")
end)

-- Kill/Resurrect.
Net.RegisterListener("EPIP_CHEATS_KILLRESURRECT", function(payload)
    local char = Character.Get(payload.NetID)
    if Osi.CharacterIsDead(char.MyGuid) == 0 then
        Osi.CharacterDie(char.MyGuid, 0, "DoT", Data.NULLGUID)
    else
        Osi.CharacterResurrect(char.MyGuid)
    end
end)

-- Add tag.
Net.RegisterListener("EPIP_CHEATS_ADDTAG", function(payload)
    local char = Character.Get(payload.NetID)

    Osi.SetTag(char.MyGuid, payload.Tag)
end)

-- Remove tag.
Net.RegisterListener("EPIP_CHEATS_REMOVETAG", function(payload)
    local char = Character.Get(payload.NetID)

    Osi.ClearTag(char.MyGuid, payload.Tag)
end)

-- Restore HP + Armors.
Net.RegisterListener("EPIP_CHEATS_HEAL", function(payload)
    local char = Character.Get(payload.NetID)

    Osi.PROC_AMER_GEN_Heal_Percentage(char.MyGuid, 100, "All", char.MyGuid, 1, 0)
end)

-- Give AP/SP.
Net.RegisterListener("EPIP_CHEATS_GIVESP", function(payload)
    local char = Character.Get(payload.NetID)

    Osi.PROC_AMER_CharacterAddSourcePoints(char.MyGuid, 99)
    Osi.PROC_AMER_ActionPoints_Add(char.MyGuid, 99)
end)

-- Reset cooldowns.
Net.RegisterListener("EPIP_CHEATS_RESETCDS", function(payload)
    local char = Character.Get(payload.NetID)

    Osi.CharacterResetCooldowns(char.MyGuid)
end)

-- Give Flexstat spells.
Net.RegisterListener("EPIP_CHEATS_SPELL", function(payload)
    local char = Character.Get(payload.NetID)

    Osi.PROC_AMER_FlexStat_CharacterAddStat(char.MyGuid, "Spell", payload.StatsID)
end)

-- Apply status.
Net.RegisterListener("EPIP_CHEATS_ADDSTATUS", function(payload)
    local char = Character.Get(payload.NetID)

    Osi.ApplyStatus(char.MyGuid, payload.StatusID, payload.Duration, 1)
end)

-- Give numeric Flexstats
Net.RegisterListener("EPIP_CHEATS_FLEXSTAT", function(payload)
    local char = Character.Get(payload.NetID)
    local stat = payload.Stat
    local type = payload.StatType
    local amount = payload.Amount
    local tagAmount = amount

    -- remove previous tag
    for _,tag in pairs(char:GetTags()) do
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
Net.RegisterListener("EPIP_CHEATS_TELEPORTTO", function(payload)
    local char = Character.Get(payload.NetID)
    local target = Character.Get(payload.TargetGUID)

    -- Try as ITEMGUID
    if not target then
        target = Item.Get(payload.TargetGUID)
    end

    -- Try as TRIGGERGUID
    if not target then
        target = Ext.Entity.GetTrigger(payload.TargetGUID)
    end

    if target then
        Osi.PROC_AMER_TeleportTo(char.MyGuid, target.MyGuid)
    end
end)

-- Grant treasure.
Net.RegisterListener("EPIP_CHEATS_GRANTTREASURE", function(payload)
    local char = Character.Get(payload.NetID)
    local treasure = payload.Treasure
    local rolls = payload.Amount

    for i=0,rolls,1 do
        Osi.PROC_PIP_GrantTreasure(char.MyGuid, treasure)
    end
end)

-- Add SpecialLogic.
Net.RegisterListener("EPIP_CHEATS_SPECIALLOGIC", function(payload)
    local char = Character.Get(payload.NetID)

    Osi.PROC_AMER_UI_Ascension_SpecialLogic_Add(char.MyGuid, payload.SpecialLogic, payload.Amount)
end)

-- Add all artifacts.
Net.RegisterListener("EPIPENCOUNTERS_CHEATS_SPAWNARTIFACTS", function(payload)
    local char = Character.Get(payload.NetID)

    for i,tuple in pairs(Osi.DB_AMER_Artifacts:Get(nil, nil, nil, nil)) do
        local root = tuple[1] -- Other fields can be discarded

        if root ~= "AMER_UNI_Deck_94902e34-3693-460c-a7a4-81f27cfc5ec7" then
            Osi.ItemTemplateAddTo(root, char.MyGuid, 1, 1)
        end
    end
end)

-- Add all artifacts foci.
Net.RegisterListener("EPIPENCOUNTERS_CHEATS_SPAWNARTIFACTSFOCI", function(payload)
    local char = Character.Get(payload.NetID)

    AutoIdentify.SetForceEnable(true)

    for i,tuple in pairs(Osi.DB_AMER_Artifacts:Get(nil, nil, nil, nil)) do
        local root,runeRoot,slot,id = tuple[1],tuple[2],tuple[3],tuple[4]

        if root ~= "AMER_UNI_Deck_94902e34-3693-460c-a7a4-81f27cfc5ec7" then
            Osi.ItemTemplateAddTo(runeRoot, char.MyGuid, 1, 1)
        end
    end

    AutoIdentify.SetForceEnable(false)
end)

Ext.Osiris.RegisterListener("PROC_AMER_ActionPoints_Changed", 3, "after", function(char, old, new)
    if Osi.IsTagged(char, "PIP_DEBUGCHEATS_INFINITEAP") == 1 and Osi.CharacterIsPlayer(char) == 1 then
        -- Avoids an infinite loop
        if new < old then
            Osi.PROC_AMER_ActionPoints_Add(char, 99)
        end
        Osi.CharacterResetCooldowns(char)
    end
end)