
---@class EpicEncounters_DeltaModsLib : Library
local DeltaMods = {
    MODVAR_DELTAMODS_DATA = "DeltaModsData",
    MODVAR_SPECIALPREFIXSLOT = "SpecialSlots",
    MODVAR_SPECIALSUBTYPE = "SpecialSubtypes",
    _DeltaModGroups = {}, ---@type EpicEncounters_DeltaModsLib_DeltaModGroupDefinition[]
}
EpicEncounters.DeltaMods = DeltaMods
Epip.InitializeLibrary("EpicEncounters_DeltaMods", DeltaMods)

---------------------------------------------
-- USER VARS
---------------------------------------------

DeltaMods:RegisterModVariable(Mod.GUIDS.EPIP_ENCOUNTERS, DeltaMods.MODVAR_DELTAMODS_DATA, {DefaultValue = {}})
DeltaMods:RegisterModVariable(Mod.GUIDS.EPIP_ENCOUNTERS, DeltaMods.MODVAR_SPECIALPREFIXSLOT, {DefaultValue = {}})
DeltaMods:RegisterModVariable(Mod.GUIDS.EPIP_ENCOUNTERS, DeltaMods.MODVAR_SPECIALSUBTYPE, {DefaultValue = {}})

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias EpicEncounters_DeltaModsLib_Handedness -1|0|1
---@alias EpicEncounters_DeltaModsLib_Slot string TODO
---@alias EpicEncounters_DeltaModsLib_DeltaModType "Normal"|"Implicit"
---@alias EpicEncounters_DeltaModsLib_EquipmentSubType string TODO

---Represents a rolled deltamod.
---@class EpicEncounters_DeltaModsLib_DeltaMod
---@field GroupDefinition EpicEncounters_DeltaModsLib_DeltaModGroupDefinition
---@field ChildModID string? `nil` in case of groups with no child modifiers.
---@field Tier integer
---@field Value integer

---@class EpicEncounters_DeltaModsLib_DeltaModGroupDefinition : Class
---@field Slot EpicEncounters_DeltaModsLib_Slot
---@field SubType EpicEncounters_DeltaModsLib_EquipmentSubType
---@field Type EpicEncounters_DeltaModsLib_DeltaModType
---@field Values number[]
---@field Name string
---@field ChildMods table<string, true>
---@field DecayChance number
---@field MinLevel integer
---@field MaxLevel integer
---@field MinRarity string TODO alias
---@field MaxRarity string TODO alias
---@field Handedness EpicEncounters_DeltaModsLib_Handedness
local Group = {}
DeltaMods:RegisterClass("EpicEncounters_DeltaModsLib_DeltaModGroupDefinition", Group)

---Creates a group.
---@param data EpicEncounters_DeltaModsLib_DeltaModGroupDefinition
---@return EpicEncounters_DeltaModsLib_DeltaModGroupDefinition
function Group.Create(data)
    data.Values = data.Values or {}
    data.ChildMods = data.ChildMods or {}

    ---@diagnostic disable-next-line: return-type-mismatch
    return Group:__Create(data)
end

---Adds a modifier value to the group.
---@param value number
function Group:AddValue(value)
    table.insert(self.Values, value)
end

---Returns whether a slot is valid for this group.
---@param slot ItemSlot
---@return boolean
function Group:IsSlotValid(slot)
    return DeltaMods._IsValidSlot(self.Slot, slot)
end

---Returns whether an equipment subtype is valid for this group.
---@param subType EpicEncounters_DeltaModsLib_EquipmentSubType
---@return boolean
function Group:IsValidSubType(subType)
    return DeltaMods._IsValidSubType(self.SubType, subType)
end

---Adds a child modifier.
---@param mod string
function Group:AddChildMod(mod)
    self.ChildMods[mod] = true
end

---Returns whether this group contains a child mod.
---@param mod string
---@return boolean
function Group:HasChildMod(mod)
    return self.ChildMods[mod] == true
end

---Returns the amount of tiers this group has for its modifiers.
---@return integer
function Group:GetTiersCount()
    return #self.Values
end

---Returns the tier for a modifier value.
---@param value number
---@return integer? --`nil` if the value is not valid for the group.
function Group:GetTierForValue(value)
    return table.reverseLookup(self.Values, value)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the definition for a group.
---@param type EpicEncounters_DeltaModsLib_DeltaModType
---@param slot ItemSlot
---@param subType EpicEncounters_DeltaModsLib_EquipmentSubType
---@param name string
---@return EpicEncounters_DeltaModsLib_DeltaModGroupDefinition?
function DeltaMods.GetGroupDefinition(type, slot, subType, name)
    local def = nil

    for _,definition in ipairs(DeltaMods._DeltaModGroups) do
        if DeltaMods._IsDataValidForGroup(definition, type, slot, subType, name) then
            def = definition
            break
        end
    end

    -- Search definitions in modvars
    if def == nil and Ext.IsClient() then
        local vars = DeltaMods:GetModVariable(Mod.GUIDS.EPIP_ENCOUNTERS, DeltaMods.MODVAR_DELTAMODS_DATA)

        for _,definition in ipairs(vars) do
            if DeltaMods._IsDataValidForGroup(definition, type, slot, subType, name) then
                def = DeltaMods._RegisterGroupDefinition(definition)

                break
            end
        end
    end

    return def
end

---Returns the child mod ID for a deltamod within a group.
---@param deltaMod string
---@param group EpicEncounters_DeltaModsLib_DeltaModGroupDefinition
---@return string? `nil` if no child mods match.
function DeltaMods._GetChildModID(deltaMod, group)
    local childModName = nil

    for childMod,_ in pairs(group.ChildMods) do
        if deltaMod:match(childMod) then -- TOOD this isn't fool-proof. We should reconstruct the full name ourselves and compare that.
            childModName = childMod
            break
        end
    end

    return childModName
end

---Registers a deltamod group.
---@param data EpicEncounters_DeltaModsLib_DeltaModGroupDefinition
---@return EpicEncounters_DeltaModsLib_DeltaModGroupDefinition
function DeltaMods._RegisterGroupDefinition(data)
    local def = Group.Create(data)

    table.insert(DeltaMods._DeltaModGroups, def)

    return def
end

---Returns the group definition for a specific deltamod.
---@param item Item
---@param deltaMod string
---@return EpicEncounters_DeltaModsLib_DeltaModGroupDefinition, integer --Definition, level.
function DeltaMods.GetGroupDefinitionForMod(item, deltaMod)
    local itemSlot = Item.GetItemSlot(item)
    local subType = Item.GetEquipmentSubtype(item)
    local pattern = "^Boost_(%a+)_(.+)_(%d+)$"
    local _, name, level = deltaMod:match(pattern)

    local def = DeltaMods.GetGroupDefinition("Normal", itemSlot, subType, name) or DeltaMods.GetGroupDefinition("Implicit", itemSlot, subType, name)

    return def, tonumber(level)
end

---Returns whether an item slot is valid for a deltamod slot requirement.
---@param slot EpicEncounters_DeltaModsLib_Slot
---@param itemSlot ItemSlot
---@return boolean
function DeltaMods._IsValidSlot(slot, itemSlot)
    local vars = DeltaMods:GetModVariable(Mod.GUIDS.EPIP_ENCOUNTERS, DeltaMods.MODVAR_SPECIALPREFIXSLOT)

    return slot == itemSlot or (vars[slot] ~= nil and vars[slot][itemSlot] == true)
end

---Returns whether an item subtype is valid for a deltamod subtype requirement.
---@param subType EpicEncounters_DeltaModsLib_EquipmentSubType
---@param itemSubType string TODO
---@return boolean
function DeltaMods._IsValidSubType(subType, itemSubType)
    local vars = DeltaMods:GetModVariable(Mod.GUIDS.EPIP_ENCOUNTERS, DeltaMods.MODVAR_SPECIALSUBTYPE)
    local SUBTYPE_CONVERSION = {
        Leather = "Light",
        Robe = "Mage",
        Plate = "Heavy",
    }
    itemSubType = SUBTYPE_CONVERSION[itemSubType] or itemSubType

    return subType == "" or subType == itemSubType or (vars[subType] ~= nil and vars[subType][itemSubType] == true)
end

---Returns whether a set of data matches that of a modifier group.
---@param group EpicEncounters_DeltaModsLib_DeltaModGroupDefinition
---@param type EpicEncounters_DeltaModsLib_DeltaModType
---@param slot EpicEncounters_DeltaModsLib_Slot
---@param subType EpicEncounters_DeltaModsLib_EquipmentSubType
---@param name string
---@return boolean
function DeltaMods._IsDataValidForGroup(group, type, slot, subType, name)
    local isValid = group.Name == name or group.ChildMods[name] == true
    isValid = isValid and DeltaMods._IsValidSlot(group.Slot, slot) and DeltaMods._IsValidSubType(group.SubType, subType) and group.Type == type

    return isValid
end