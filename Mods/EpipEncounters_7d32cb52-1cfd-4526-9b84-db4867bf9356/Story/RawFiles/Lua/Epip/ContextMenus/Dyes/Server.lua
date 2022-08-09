
---------------------------------------------
-- Server scripting for dyeing from context menu.
-- Applies the deltamods directly, then re-equips
-- to update the visuals.
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_CreateDyeStat_ForPeers", function(cmd, payload)
    Net.Broadcast("EPIPENCOUNTERS_CreateDyeStat", payload)
end)

Net.RegisterListener("EPIPENCOUNTERS_DyeItem", function(cmd, payload)
    local item = Ext.GetItem(payload.NetID)
    local dyeStat = payload.DyeStat
    local char = Ext.GetCharacter(payload.CharacterNetID)

    -- Osiris.DB_PIP_Vanity_CustomDyes_DyedItem:Set(item.MyGuid, dyeStat.Name)

    Stats.Update("ItemColor", dyeStat)

    PersistentVars = PersistentVars or {}
    if not PersistentVars.Dyes then PersistentVars.Dyes = {} end

    PersistentVars.Dyes[dyeStat.Name] = dyeStat

    -- Ext.Stats.Sync(dyeStat.Name, true)
    -- Ext.Stats.SetPersistence(dyeStat.Name, true)

    local statType = item.Stats.ItemType
    local deltaModName = string.format("Boost_%s_%s", statType, dyeStat.Name)
    local boostStatName = "_" .. deltaModName
    local stat = Stats.Get(statType, boostStatName)
    Ext.Stats.SetPersistence(boostStatName, true)

    if not stat then
        stat = Ext.Stats.Create(boostStatName, statType)
    end

    stat.ItemColor = dyeStat.Name

    Stats.Update("DeltaModifier", {
        Name = deltaModName,
        MinLevel = 1,
        Frequency = 1,
        BoostType = "ItemCombo",
        ModifierType = statType,
        SlotType = "Sentinel",
        WeaponType = "Sentinel",
        Handedness = "Any",
        Boosts = {
            {
                Boost = boostStatName,
                Count = 1,
            }
        }
    })

    Osi.ItemAddDeltaModifier(item.MyGuid, deltaModName)
    
    Epip.Features.Vanity.RefreshAppearance(char, true)

    Net.Broadcast("EPIP_CACHEDYE", {
        Dye = dyeStat,
    })
end)

-- Net.RegisterListener("EPIPENCOUNTERS_Vanity_RequestDyes", function(cmd, payload)
--     local items = {}
--     local _, _, tuples = Osiris.DB_PIP_Vanity_CustomDyes_DyedItem:Get(nil, nil)

--     for i,tuple in ipairs(tuples) do
--         items[tuple[1]] = tuple[2]
--     end

--     -- Net.PostToCharacter(_C().MyGuid, "EPIPENCOUNTERS_Vanity_SetDyes", {Items = items})
--     print("----SENDING DYES")
--     Net.Broadcast("EPIPENCOUNTERS_Vanity_SetDyes", {Items = items})
-- end)

Net.RegisterListener("EPIPENCOUNTERS_DYE", function(cmd, payload)
    local item = Ext.GetItem(payload.Item)
    local char = Ext.GetCharacter(payload.Character)
    local dyeData = payload.DyeData
    local dye = Osi.GetItemForItemTemplateInPartyInventory(char.MyGuid, dyeData.Template)


    -- Can't craft in combat; thereby neither can we dye.
    if Osi.CombatGetIDForCharacter(char.MyGuid) ~= 0 then
        Osi.PROC_AMER_GEN_OpenQueuedMessageBox(char.MyGuid, "I shouldn't be thinking about these things while my life is at stake!")
    else
        if dye then
            -- TODO make feature
            Utilities.Hooks.FireEvent("ContextMenus_Dyes", "ItemBeingDyed", item)
            
            local deltamod = "Boost_" .. item.Stats.ItemType .. "_" .. dyeData.Deltamod
    
            Osi.ItemAddDeltaModifier(item.MyGuid, deltamod)
    
            Osi.QRY_AMER_GEN_GetEquippedItemSlot(char.MyGuid, item.MyGuid)
    
            -- TODO add this check to the proc instead
            if Osi.DB_AMER_GEN_OUTPUT_String:Get(nil)[1][1] ~= "None" then
                Osi.PROC_PIP_ReEquipItem(char.MyGuid, item.MyGuid)
            end
        else
            -- This should no longer happen, since we added this check client-side.
            Osi.PROC_AMER_GEN_OpenQueuedMessageBox(char.MyGuid, "We don't have that dye!<br>We shall shop for them at miscellaneous vendors.")
        end
    end
end)