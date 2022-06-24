
Ext.Osiris.RegisterListener('PROC_AMER_UI_Greatforge_DoCraft', 11, "after", function(instance, char, cont, item, level, itemType, slot, subType, handedness, value, craftOperation)
    if (craftOperation == "AddSockets") then
        
        -- local baseBoostSlots = Osi.NRD_ItemGetPermanentBoostInt(item, "RuneSlots")

        -- Ext.Print(baseBoostSlots)
        -- Ext.Print("Item " .. item .. " has " .. runeSlots .. " sockets.")

        -- Osi.NRD_ItemSetPermanentBoostInt(item, "RuneSlots", baseBoostSlots + 1)

        -- local runeSlots = GetRuneSlots(item)

        local itemObj = Ext.GetItem(item)

        itemObj.Stats.DynamicStats[2].RuneSlots = itemObj.Stats.DynamicStats[2].RuneSlots + 1

        Osi.NRD_ItemCloneBegin(item)
        if (slot == "Weapon") then
            Osi.NRD_ItemCloneSetString("DamageTypeOverwrite", itemObj.Stats.DynamicStats[1].DamageType)
        end
        local newItem = Osi.NRD_ItemClone()

        Osi.SetTag(newItem, "AMER_DELTAMODS_HANDLED") -- don't regenerate deltamods on the new item
        Osi.ItemToInventory(newItem, char, 1, 1, 0)
        Osi.PROC_AMER_GEN_UnequipAndRemoveItem(char, item);
    end
end)

function GetRuneSlots(item)
    local itemData = Ext.GetItem(item)

    local runeSlots = 0
    for i,v in pairs(itemData.Stats.DynamicStats) do
        runeSlots = runeSlots + v.RuneSlots
    end

    return runeSlots
end

function Test()
    Ext.Print("test2")
    return true
end

function ItemHasMaxSockets(char, mode)
    if mode == "AddSockets" then
        local db = Osi.DB_AMER_UI_Greatforge_BenchedItem:Get(nil, nil, nil, nil, nil, nil, nil, nil, nil)

        local itemId = db[1][3]
        local limit = 3
        local itemData = Ext.GetItem(itemId)

        if (itemData.Stats.ItemSlot == "Weapon" and not itemData.Stats.IsTwoHanded) then
            limit = 2
        end

        -- Ext.Print(itemId)

        local isMaxed = GetRuneSlots(itemId) >= limit
        if isMaxed then
            if limit == 3 then
                Osi.OpenMessageBox(char, "AMER_UI_Greatforge_AddSockets_InvalidSelection3Sockets")
            else
                Osi.OpenMessageBox(char, "AMER_UI_Greatforge_AddSockets_InvalidSelection2Sockets")
            end
        end
        return isMaxed
    end
    return false
end

Ext.Print("Loaded Epip Encounters Lua")