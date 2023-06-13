
---@class EpicEncounters_DeltaModsLib
local DeltaMods = EpicEncounters.DeltaMods

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Synchronize deltamod data on start.
GameState.Events.GameReady:Subscribe(function (_)
    local tuples = Osiris.QueryDatabase("DB_AMER_Deltamods_Mod", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)

    for _,tuple in ipairs(tuples) do
        local _, category, rarityMin, rarityMax, slot, subType, handedness, deltaModPrefix, _, _, levelMin, levelMax, modValue, decayChance = tuple:Unpack()

        local def = DeltaMods.GetGroupDefinition(category, slot, subType, deltaModPrefix)
        if not def then
            def = DeltaMods._RegisterGroupDefinition({
                Slot = slot,
                SubType = subType,
                Name = deltaModPrefix,
                Type = category,
                DecayChance = decayChance,
                MinLevel = levelMin,
                MaxLevel = levelMax,
                MinRarity = rarityMin,
                MaxRarity = rarityMax,
                Handedness = handedness,
            })
        end

        def:AddValue(tonumber(modValue))
    end

    -- Update special slots and subtypes
    local specialSlots = {}
    tuples = Osiris.QueryDatabase("DB_AMER_Deltamods_PrefixSlotValidation_Special", nil, nil)
    for _,tuple in ipairs(tuples) do
        local t1, t2 = tuple:Unpack()
        if specialSlots[t1] == nil then
            specialSlots[t1] = {}
        end

        specialSlots[t1][t2] = true
    end
    local subTypes = {}
    tuples = Osiris.QueryDatabase("DB_AMER_Deltamods_PrefixSubTypeValidation_Special", nil, nil)
    for _,tuple in ipairs(tuples) do
        local t1, t2 = tuple:Unpack()
        if subTypes[t1] == nil then
            subTypes[t1] = {}
        end

        subTypes[t1][t2] = true
    end
    local childMods = Osiris.QueryDatabase("DB_AMER_Deltamods_Prefix_Child", nil, nil)
    for _,tuple in ipairs(childMods) do
        local parent, child = tuple:Unpack()

        for _,group in pairs(DeltaMods._DeltaModGroups) do
            if group.Name == parent then
                group:AddChildMod(child)
            end
        end
    end

    DeltaMods:SetModVariable(Mod.GUIDS.EPIP_ENCOUNTERS, DeltaMods.MODVAR_DELTAMODS_DATA, DeltaMods._DeltaModGroups)
    DeltaMods:SetModVariable(Mod.GUIDS.EPIP_ENCOUNTERS, DeltaMods.MODVAR_SPECIALPREFIXSLOT, specialSlots)
    DeltaMods:SetModVariable(Mod.GUIDS.EPIP_ENCOUNTERS, DeltaMods.MODVAR_SPECIALSUBTYPE, subTypes)
end)

---------------------------------------------
-- COMMANDS
---------------------------------------------

-- Saves deltamod data to a file.
Ext.RegisterConsoleCommand("savedeltamodsdata", function ()
    IO.SaveFile("deltamods.json", DeltaMods._DeltaModGroups)
end)