
function CloneItemWithDeltaMods(item, deltamods)
    local constructor = Ext.CreateItemConstructor(item) ---@type EocItemDefinition[]
    local props = constructor[1]
    -- props.GMFolding = false
    Ext.Print(props.GenerationStatsId)
    Ext.Print(props.HasGeneratedStats)
    Ext.Dump(props.RuneBoosts)
    -- props.DeltaMods = deltamods
    -- props.DeltaMods = {}
    -- for i,v in pairs(deltamods) do
    --     -- table.insert(props.DeltaMods, v)
    --     props.DeltaMods[i] = v
    --     Ext.Dump(props.DeltaMods)
    -- end
    -- if deltamods then
    --     for i=1,#deltamods do
    --         if not TableHasValue(props.DeltaMods, deltamods[i]) then
    --             props.DeltaMods[#props.DeltaMods+1] = deltamods[i]
    --         end
    --     end
    -- end
    for i,v in pairs(props.DeltaMods) do
        props.DeltaMods[i] = ""
    end
    Ext.Dump(props.GenerationBoosts)
    Ext.Dump(props.DeltaMods)
    return constructor:Construct()
end

function GreatforgeExclude(instanceStr) -- todoooooooo
    local index = Osi.DB_AMER_UI_Greatforge_Exclude_SelectedMod:Get(tonumber(instanceStr), nil)[1][2]
    local itemGUID = Osi.DB_AMER_UI_Greatforge_BenchedItem:Get(tonumber(instanceStr), nil, nil, nil, nil, nil, nil, nil, nil)[1][3]
    local char = Osi.DB_AMER_UI_Greatforge_BenchedItem:Get(tonumber(instanceStr), nil, nil, nil, nil, nil, nil, nil, nil)[1][2]

    local deltamod = Osi.DB_PIP_UI_Greatforge_Exclude_ModsOfItem:Get(tonumber(instanceStr), index, nil)[1][3]

    local item = Ext.GetItem(itemGUID)

    -- Ext.Dump(Osi.DB_AMER_UI_Greatforge_BenchedItem:Get(tonumber(instanceStr), nil, nil, nil, nil, nil, nil, nil, nil))

    local deltamods = item:GetDeltaMods()

    local indexToRemove = -1
    for i,v in pairs(deltamods) do
        if v == deltamod then indexToRemove = i break end
    end

    if indexToRemove < 0 then Ext.PrintError("Modifier not found: " .. deltamod) return nil end

    Ext.Print("Removing " .. deltamods[indexToRemove])
    table.remove(deltamods, indexToRemove)

    item:SetDeltaMods(deltamods)
    -- local clonedItem = CloneItemWithDeltaMods(item, deltamods)
    -- newItem:SetDeltaMods(deltamods)
    -- Osi.NRD_ItemCloneBegin(clonedItem.MyGuid)
    -- newItem = Ext.GetItem(Osi.NRD_ItemClone())

    -- Osi.SetTag(newItem.MyGuid, "AMER_DELTAMODS_HANDLED") -- don't regenerate deltamods on the new item
    -- Osi.ItemToInventory(newItem.MyGuid, char, 1, 1, 0)
    -- Osi.PROC_AMER_GEN_UnequipAndRemoveItem(char, item.MyGuid);
    -- Osi.PROC_AMER_GEN_UnequipAndRemoveItem(char, clonedItem.MyGuid);

    -- CharacterAddSkill(char, "Shout_ChainPull")
end