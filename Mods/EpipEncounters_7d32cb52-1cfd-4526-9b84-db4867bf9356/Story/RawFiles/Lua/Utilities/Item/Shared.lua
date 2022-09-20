
---@class ItemsLib
Item = {
    -- TODO
    RARITY_COLORS = {
        ARTIFACT = "a34114",
    },
}

---Returns true if the item is an Artifact by checking the AMER_UNI tag.
---@param item Item
---@return boolean
function Item.IsArtifact(item)
    return item:HasTag("AMER_UNI") and not item:HasTag("PIP_FAKE_ARTIFACT")
end

---Returns whether the item is a rune.
---@param item Item
---@return boolean
function Item.IsRune(item)
    return Stats.GetRuneDefinition(item.StatsId) ~= nil
end

---Returns whether item is a melee weapon (satisfying a MeleeWeapon requirement)
---Returns true for None-type weaponry.
---@param item Item
---@return boolean
function Item.IsMeleeWeapon(item)
    return item and item.Stats and (Data.Game.MELEE_WEAPONS[item.Stats.WeaponType] or item.Stats.WeaponType == "None")
end

---Returns the icon of the item.
---Fetching the icon is technically different per context; the server only cares about root template icon (except for the gold template). This function uses the client logic (which also checks icon override and icon from stats).
---@param item Item
---@return string
function Item.GetIcon(item)
    local icon = item.RootTemplate.Icon

    -- Gold is a special case.
    if item.RootTemplate.Id == "1c3c9c74-34a1-4685-989e-410dc080be6f" then
        local amount = item.Amount

        if amount >= 500 then
            icon = "Item_Loot_Gold_A"
        elseif amount >= 100 then
            icon = "Item_LOOT_Gold_Medium_A"
        elseif amount == 1 then
            icon = "Item_LOOT_Gold_Coin_A"
        else
            icon = "Item_LOOT_Gold_Small_A"
        end
    else
        if item.Icon ~= "" then -- GB5 Icon override
            icon = item.Icon
        elseif item.Stats then
            local statObject = Ext.Stats.Get(item.Stats.Name)
            local itemGroup = Ext.Stats.ItemGroup.GetLegacy(statObject.ItemGroup)

            if itemGroup and item.LevelGroupIndex < #itemGroup.LevelGroups then
                local levelGroup = itemGroup.LevelGroups[item.LevelGroupIndex + 1]
                local rootGroup = levelGroup.RootGroups[item.RootGroupIndex + 1]
                local nameGroupLink = rootGroup.NameGroupLinks[item.NameGroupIndex + 1]

                if nameGroupLink.ItemName ~= "" then
                    icon = nameGroupLink.ItemName
                end
            end
        end
    end

    return icon
end

---Returns whether the item has a flag.
---@param item Item
---@param flag EclItemFlags|EsvItemFlags|EclItemFlags2|EsvItemFlags2
function Item.HasFlag(item, flag)
    local hasFlag = false

    -- Search Flags
    for _,itemFlag in ipairs(item.Flags) do
        if itemFlag == flag then
            hasFlag = true
            break
        end
    end

    -- Search Flags2
    if not hasFlag then
        for _,itemFlag in ipairs(item.Flags2) do
            if itemFlag == flag then
                hasFlag = true
                break
            end
        end
    end

    return hasFlag
end

---Returns whether an item is a container.
---@param item Item
---@return boolean
function Item.IsContainer(item)
   return Item.HasUseAction(item, "OpenClose")
end

---Returns whether the item has a OnUsePeaceAction of the passed type.
---@param item Item
---@param useActionID ActionDataType
---@return boolean
function Item.HasUseAction(item, useActionID)
    local actions = item.RootTemplate.OnUsePeaceActions
    local hasAction = false

    for _,action in ipairs(actions) do
        if action.Type == useActionID then
            hasAction = true
            break
        end
   end

    return hasAction
end

---Returns whether an item has any use actions.
---@param item Item
---@return boolean
function Item.HasUseActions(item)
    return #item.RootTemplate.OnUsePeaceActions > 0
end

---Returns the current owner of the item.
---The owner will be nil if the character who owned the item died.
---@param item Item
---@return Character?
function Item.GetOwner(item)
    local ownerHandle
    local owner

    -- Unfortunate naming inconsistency
    if Ext.IsServer() then
        ownerHandle = item.OwnerHandle
    else
        ownerHandle = item.OwnerCharacterHandle
    end

    if Ext.Utils.IsValidHandle(ownerHandle) then
        owner = Character.Get(ownerHandle)
    end

    return owner
end

---Returns whether interacting with an item is legal.
---@param item Item
---@return boolean
function Item.IsLegal(item)
    local template = item.RootTemplate
    local isLegal = true
    local legalActions = { -- Having any of these actions makes the item legal to interact with.
        Sit = true,
        Lying = true,
        Ladder = true,
    }

    if not template.IsPublicDomain then
        local owner = Item.GetOwner(item) -- Owner will be nil if the character who owned the item died.

        if owner and not owner.InParty then
            isLegal = false

            -- Check for legal actions
            for _,action in ipairs(template.OnUsePeaceActions) do
                if legalActions[action.Type] then
                    isLegal = true
                    break
                end
            end
        end
    end

    return isLegal
end

---Returns true if the item is a weapon (shields don't count!)
---@param item Item
---@return boolean
function Item.IsWeapon(item)
    return item and item.Stats and item.Stats.WeaponType ~= "None" and item.Stats.WeaponType ~= "Sentinel"
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

---@param item Item
---@return integer
function Item.GetUseAPCost(item)
    local cost = 0 -- TODO is the default cost 0 or 1?

    local useActions = item.RootTemplate.OnUsePeaceActions
    for _,action in ipairs(useActions) do
        -- if action.Type == "UseSkill" then
        --     cost = Stats.Get("SkillData", action.SkillID).ActionPoints-- Pretty sure items ignore Elemental Affinity? Not 100% sure, TODO
        if action.Type == "Consume" or action.Type == "UseSkill" then -- Item object costs override skill AP costs.
            local stat = Stats.Get("Potion", item.StatsId) or Stats.Get("Object", item.StatsId)

            cost = stat.UseAPCost
        end
    end

    return cost
end

---@param char Character
---@param item Item
---@return boolean
function Item.CanUse(char, item)
    local canUse = true
    local ap, _ = Character.GetActionPoints(char)

    if item.Stats then
        canUse = canUse and Stats.MeetsRequirements(char, item.Stats.Name, true, item)
    end

    -- Item skills
    local apCost = Item.GetUseAPCost(item)
    apCost = apCost + Character.GetDynamicStat(char, "APCostBoost")

    canUse = canUse and ap >= apCost

    return canUse
end

---Returns all items in the party inventory of char matching the predicate, or all if no predicate is passed.
---@param char Character
---@param predicate? fun(item:Item):boolean
function Item.GetItemsInPartyInventory(char, predicate)
    local items = {}
    local partyCharacters = Character.GetPartyMembers(char)

    for _,partyMember in ipairs(partyCharacters) do
        local charItems = partyMember:GetInventoryItems()

        for _,guid in ipairs(charItems) do
            local item = Item.Get(guid)

            if predicate == nil or predicate(item) then
                table.insert(items, item)
            end
        end
    end

    return items
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
---@param isFlashHandle boolean?
---@return Item
function Item.Get(identifier, isFlashHandle)
    if isFlashHandle then
        identifier = Ext.UI.DoubleToHandle(identifier)
    end
    
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
    return Item.GetEquippedSlot(item, char) ~= nil
end

---Returns the slot that an item is equipped in, or nil if it is not.
---@param item Item
---@param char Character? Defaults to item's owner.
---@return EquipSlot?
function Item.GetEquippedSlot(item, char)
    local slot = Item.GetItemSlot(item)
    char = char or Ext.GetCharacter(item:GetOwnerCharacter())
    if not char then return nil end
    local isEquipped = false

    if Ext.IsClient() then
        isEquipped = char:GetItemBySlot(slot) == item.MyGuid
    else
        isEquipped = Osi.CharacterGetEquippedItem(char.MyGuid, slot) ~= NULLGUID
    end

    -- Check Ring2 slot
    if not isEquipped and slot == "Ring" then
        isEquipped = char:GetItemBySlot("Ring2") == item.MyGuid

        if isEquipped then slot = "Ring2" end
    end

    -- Check Shield slot
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