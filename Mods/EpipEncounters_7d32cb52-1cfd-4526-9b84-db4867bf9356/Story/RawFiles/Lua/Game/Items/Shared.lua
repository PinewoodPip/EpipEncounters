
---@meta Library: GameItem, ContextShared, Item

---Returns true if the item is an Artifact by checking the AMER_UNI tag.
---@param item Item
---@return boolean
function Item.IsArtifact(item)
    return item:HasTag("AMER_UNI") and not item:HasTag("PIP_FAKE_ARTIFACT")
end

---Returns whether item is a melee weapon (satisfying a MeleeWeapon requirement)
---Returns true for None-type weaponry.
---@param item Item
---@return boolean
function Item.IsMeleeWeapon(item)
    return item and item.Stats and (Data.Game.MELEE_WEAPONS[item.Stats.WeaponType] or item.Stats.WeaponType == "None")
end

---Returns whether item is a shield (satisfying a ShieldWeapon requirement)
---@param item Item
---@return boolean
function Item.IsShield(item)
    return item and item.Stats and item.Stats.ItemSlot == "Shield" -- WeaponType is Sentinel
end

---Returns whether item is a dagger (satisfying a DaggerWeapon requirement)
---@param item Item
---@return boolean
function Item.IsDagger(item)
    return item and item.Stats and item.Stats.WeaponType == "Knife"
end

---Returns whether item is a ranged weapon; bow or crossbow only!
---@param item Item
---@return boolean
function Item.IsRangedWeapon(item)
    return item and item.Stats and Data.Game.RANGED_WEAPONS[item.Stats.WeaponType]
end

---@param char Character
---@param item Item
---@return boolean
function Item.CanUse(char, item)
    local canUse = true

    if item.Stats then
        canUse = canUse and Stats.MeetsRequirements(char, item.Stats.Name, true, item)
    end

    -- Item skills
    local useActions = item.RootTemplate.OnUsePeaceActions
    for _,action in ipairs(useActions) do
        if action.Type == "UseSkill" then
            canUse = canUse and Character.CanUseSkill(char, action.SkillID, item)
        elseif action.Type == "Consume" then
            local stat = Stats.Get("Potion", item.StatsId) or Stats.Get("Object", item.StatsId)

            if stat then
                local ap, _ = Character.GetActionPoints(char)
                canUse = canUse and ap >= stat.UseAPCost
            end
        end
    end

    return canUse
end

--- Gets the amount of Loremaster necessary to identify an item.  
--- Ignores whether the item is already identified.
---@param item Item
---@return number
function Item.GetIdentifyRequirement(item)
    if not item.Stats then Utilities.LogError("Item", "Item has no stats; cannot get identify requirement.") return nil end

    local level = item.Stats.Level
    
    if level >= 18 then return 5 end
    if level >= 15 then return 4 end
    if level >= 11 then return 3 end
    if level >= 7 then return 2 end

    return 1
end

---@param identifier GUID|NetId|EntityHandle
---@return Item
function Item.Get(identifier)
    return Ext.Entity.GetItem(identifier)
end

--- Returns true if the item is an armor piece or a weapon.
---@param item Item
---@return boolean
function Item.IsEquipment(item)
    if not item.Stats then return false end

    local type = item.Stats.ItemType

    return type == "Armor" or type == "Weapon" or type == "Shield"
end

--- Returns true for dyeable items (equipment, except rings/amulet/belt).
---@param item Item
---@return boolean
function Item.IsDyeable(item)
    return item.Stats and Item.IsEquipment(item) and not (item.Stats.ItemSlot == "Belt" or item.Stats.ItemSlot == "Ring" or item.Stats.ItemSlot == "Amulet")
end

--- Alias for Item.Stats.ItemSlot
---@param item Item
---@return string
function Item.GetItemSlot(item)
    if not item.Stats then return nil end
    local slot = item.Stats.ItemSlot

    return slot
end

--- Like ItemSlot, but distinguishes armor subtypes  
--- Get subtype of item (ex. "Dagger" or "Platemail").  
--- Returns ItemSlot for items with no subtypes
---@param item Item
---@return EquipmentSubType
function Item.GetEquipmentSubtype(item)
    local itemType = Item.GetItemSlot(item)
    if not itemType then return nil end

    -- for items with no subtypes, return ItemSlot
    if not Data.Game.SLOTS_WITH_SUBTYPES[itemType] then
        return itemType
    end

    -- for artifacts, look for subtype from root template name
    if Item.IsArtifact(item) then
        local match = (item.RootTemplate.Name .. "_" .. item.RootTemplate.Id):match(Data.Patterns.ARTIFACT_ROOTTEMPLATE_SUBTYPE)

        return match
    end

    -- for randomly generated items, find subtype based on base boost
    for i,v in pairs(item.Stats.DynamicStats) do

        local boostName = v.ObjectInstanceName
        local subTypes = Data.Game.BASE_BOOST_TO_EQUIP_TYPE
        
        if subTypes[boostName] ~= nil then
            itemType = subTypes[boostName]
            break
        end
    end

    return itemType
end

--- Applies a dye to the item.
---@param item Item
---@param dye Dye
---@return boolean False if item is already dyed with the same dye, or if dye is ``nil``.
function Item.ApplyDye(item, dye)
    local oldDye,data = Item.GetCurrentDye(item)
    local applied = false

    if oldDye ~= dye and dye then
        local deltamod = "Boost_" .. item.Stats.ItemType .. "_" .. Data.Game.DYES[dye].Deltamod
    
        Osi.ItemAddDeltaModifier(item.MyGuid, deltamod)

        applied = true
    end

    return applied
end

--- Returns the ID and data for the most recently-applied dye deltamod on the item.
---@param item Item
---@return string,Dye The dye ID and data table.
function Item.GetCurrentDye(item)
    local pattern = ".*_(Dye_.*)$"
    local dye = nil

    for i,mod in ipairs(item:GetDeltaMods()) do
        dye = mod:match(pattern) or dye
    end

    local dyeData = nil
    local dyeID = nil
    for id,data in pairs(Data.Game.DYES) do
        if data.Deltamod == dye then
            dyeData = data
            dyeID = id
        end
    end

    return dyeID,dyeData
end

---Returns a list of the named boosts on the item.
---@param item Item
---@return string[]
function Item.GetNamedBoosts(item)
    local boosts = {}

    for i,v in pairs(item.Stats.DynamicStats) do

        local boostName = v.ObjectInstanceName

        if boostName ~= "" then
            table.insert(boosts, boostName)
        end
    end

    return boosts
end

--- Returns true if item is equipped by char. Assumes the item cannot be equipped into an unintended slot. Rings and weapons are checked for both slots.
---@param char Character
---@param item Item
---@return boolean
function Item.IsEquipped(char, item)
    return Item.GetEquippedSlot(item) ~= nil
end

---Returns the slot that an item is equipped in, or nil if it is not.
---@param item Item
---@return EquipSlot?
function Item.GetEquippedSlot(item)
    local slot = Item.GetItemSlot(item)
    local char = Ext.GetCharacter(item:GetOwnerCharacter())
    if not char then return nil end
    
    local isEquipped = char:GetItemBySlot(slot) == item.MyGuid

    -- Check Ring2 slot
    if not isEquipped and slot == "Ring" then
        isEquipped = char:GetItemBySlot("Ring2") == item.MyGuid

        if isEquipped then slot = "Ring2" end
    end

    if not isEquipped and slot == "Weapon" then
        isEquipped = char:GetItemBySlot("Shield") == item.MyGuid

        if isEquipped then slot = "Shield" end
    end

    if not isEquipped then slot = nil end

    return slot
end

--- Count the items in an entity's inventory that match a predicate function.  
--- Predicate is passed ``Item`` and should return true for items to be counted.
---@param entity Entity
---@param predicate fun(item: EsvItem)
---@return number
function Item.CountItemsInInventory(entity, predicate)
    local count = 0
    local items = Item.GetItemsInInventory(entity, predicate)

    -- Factor in stacked items.
    for _,item in pairs(items) do
        count = count + item.Amount
    end

    return count
end

---------------------------------------------
-- REGION Runes.
---------------------------------------------

--- Gets the stats object of the rune inserted at rune index ``index`` on item.
---@param item Item
---@param index number
---@return StatItem
function Item.GetRune(item, index)
    if index < 0 or index > 2 then
        Ext.PrintError("Cannot fetch runes with out-of-range index: " .. index)
        return nil
    end

    local slottedObject = item.Stats.DynamicStats[index + 3].BoostName
    
    if slottedObject == "" then
        return nil
    end

    return Ext.Stats.Get(slottedObject)
end

--- Returns a list of runes on the item.
---@param item Item
---@return table<number, StatItem> Empty slots are nil.
function Item.GetRunes(item)
    return {
        [0] = Item.GetRune(item, 0),
        [1] = Item.GetRune(item, 1),
        [2] = Item.GetRune(item, 2),
    }
end

--- Returns true if item has any runes slotted.
---@param item Item
---@return boolean
function Item.HasRunes(item)
    -- Item has runes if GetRunes() is not empty; but we cannot check the length as it's not a proper list
    for i,stat in pairs(Item.GetRunes(item)) do
        return true
    end
    return false
end

---------------------------------------------
-- REGION Querying items in inventories.
---------------------------------------------

--- Returns a list of the items in the entity's inventory that match an optional predicate function.  
--- Predicate is passed the EclItem/EsvItem and should return true for items to be included.
---@param entity Entity
---@param predicate fun(item: Item)
---@return Item[]
function Item.GetItemsInInventory(entity, predicate)
    local items = {}

    for i,guid in pairs(entity:GetInventoryItems()) do
        local item = Ext.GetItem(guid)

        if predicate == nil or predicate(item) then
            table.insert(items, item)
        end
    end

    return items
end