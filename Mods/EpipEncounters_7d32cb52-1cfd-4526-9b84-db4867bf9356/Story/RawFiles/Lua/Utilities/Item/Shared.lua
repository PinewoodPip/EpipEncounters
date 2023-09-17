
local Set = DataStructures.Get("DataStructures_Set")

---@class ItemLib : Library
Item = {
    -- TODO
    RARITY_COLORS = {
        ARTIFACT = "a34114",
    },

    ---@type DataStructures_Set<WeaponType>
    MELEE_WEAPON_TYPES = Set.Create({
        "Sword",
        "Club",
        "Knife",
        "Axe",
        "Spear",
        "Staff",
    }),

    ---@type DataStructures_Set<WeaponType>
    RANGED_WEAPON_TYPES = Set.Create({
        "Bow",
        "Crossbow",
        "Rifle",
    }),

    RUNE_SLOT_ICONS = {
        E = "Item_RuneSlot_Overlay_E", -- 1 slot, empty.
        F = "Item_RuneSlot_Overlay_F", -- 1 slot, filled.

        EE = "Item_RuneSlot_Overlay_EE", -- 2 slots, both empty.
        EF = "Item_RuneSlot_Overlay_EF", -- 2 slots, one filled.
        FF = "Item_RuneSlot_Overlay_FF", -- etc.

        EEE = "Item_RuneSlot_Overlay_EEE",
        EEF = "Item_RuneSlot_Overlay_EEF",
        EFF = "Item_RuneSlot_Overlay_EFF",
        FFF = "Item_RuneSlot_Overlay_FFF",
    },

    ITEM_SLOTS = Set.Create({
        "Helmet",
        "Breast",
        "Leggings",
        "Weapon",
        "Shield",
        "Ring",
        "Belt",
        "Boots",
        "Gloves",
        "Amulet",
        "Ring2",
        "Wings",
        "Horns",
        "Overhead",
    }),

    SHEATHED_ATTACHMENT_BONES = {
        BOW = "Dummy_Weapon_BOW",
        TWO_HANDED = "Dummy_Weapon_2H",
        OFF_HAND = "Dummy_Weapon_L_1H",
        POLEARM = "Dummy_Weapon_Pole",
        ONE_HANDED = "Dummy_Weapon_R_1H",
        SHIELD = "Dummy_Weapon_SH",
        CROSSBOW = "Dummy_Weapon_XB",
    },

    WEAPON_ATTACK_BONES = {
        Dummy_FX = true,
        Dummy_FX_01 = true,
        Dummy_FX_02 = true,
        Dummy_Attachment = true,
        Dummy_ProjectileFX = true,
    },

    RARITY_HANDLES = {
        COMMON = "h5c0f3da4g83a2g4f3fg9944gc80920bcb4df",
        UNCOMMON = "h7682e16bg7c69g4a72g8f1fg1b32519665f3",
        RARE = "heb7ba0d5g7f4cg49e9g9ce2g86cf5e5bd277",
        EPIC = "hd75b2771g8abag49b5g9b8egb608d51b9ddf",
        LEGENDARY = "h97227897g1345g4046gbb62g842dcc292db1",
        DIVINE = "h09d00ab3g7edbg4569ga4d7gf37b9b7b04cb",
        UNIQUE = "h04685fd1g024ag4641gaed6g0ffb2d0ff103",
    },

    UNIDENTIFIED_ITEM_TSKHANDLE = "hf9d034e1gf819g4c6cga36fg7afd009b5827", --- "Unidentified [1]"

    ---Does not include weapon types. See `WEAPON_TYPE_TSKHANDLES`.
    ---@type table<ItemSlot, TranslatedStringHandle>
    ITEM_SLOT_TSKHANDLES = {
        ["Helmet"] = "hd4b98ff5g33a8g44e0ga6a9gdb1ab7d70bf3",
        ["Breast"] = "hb5c52d20g6855g4929ga78ege3fe776a1f2e",
        ["Leggings"] = "he7042b52g54d7g4f46g8f69g509460dfe595",
        -- ["Weapon"] = "", -- See `WEAPON_TYPE_TSKHANDLES`
        ["Shield"] = "h77557ac7g4f6fg49bdga76cg404de43d92f5",
        ["Ring"] = "h970199f8ge650g4fa3ga0deg5995696569b6",
        ["Belt"] = "h2a76a9ecg2982g4c7bgb66fgbe707db0ac9e",
        ["Boots"] = "h9b65aab2gf4c4g4b81g96e6g1dcf7ffa8306",
        ["Gloves"] = "h185545eagdaf0g4286ga411gd50cbdcabc8b",
        ["Amulet"] = "hb9d79ca5g59afg4255g9cdbgf614b894be68",
        ["Ring2"] = "h970199f8ge650g4fa3ga0deg5995696569b6", -- Copy of Ring just in case.
        ["Wings"] = "hd716a074gd36ag4dfcgbf79g53bd390dd202",
        ["Horns"] = "hff459609g099bg4cfcg885fg87c3d9e54f59", -- "Head"
        ["Overhead"] = "hda749a3fg52c0g48d5gae3bgd522dd34f65c",
    },
    -- Handles used in item tooltips for equipment types that support both handedness types.
    ITEM_TYPE_TOOLTIP_TSKHANDLES = {
        ONE_HANDED = { -- "One-Handed X"
            ["Sword"] = "h657cfe58g240bg43c6g9129gf3a6a75d6ca4",
            ["Mace"] = "h17a906aeg8f00g4f9dga784g93b8e4ad26b2",
            ["Axe"] = "h2c89d4e0g529bg4e4agbae9ge3119ee32cc9",
        },
        TWO_HANDED = { -- "Two-Handed X"
            ["Sword"] = "h57099d1cg88ccg44f5g9ba7gc1acedf94335",
            ["Mace"] = "h7b586984gd7abg42fcg84a4ge354c937ec07",
            ["Axe"] = "h2fdeda9fgd07ag489bgab68g872500b23ea2",
        },
    },
    WEAPONS_WITH_BOTH_HANDEDNESS_TYPES = {
        ["Sword"] = true,
        ["Mace"] = true,
        ["Axe"] = true,
    },

    ---@type table<ItemLib_Rarity, icon>
    _ITEM_RARITY_ICONS = {
        Uncommon = "Item_Uncommon",
        Rare = "Item_Rare",
        Epic = "Item_Epic",
        Legendary = "Item_Legendary",
        Divine = "Item_Divine",
        Unique = "Item_Unique",
    },

    MAX_RUNE_SLOTS = 3,
}
Epip.InitializeLibrary("Item", Item)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@alias ItemLib_EquipmentType WeaponType|ArmorType
---@alias ItemLib_Rarity "Common"|"Uncommon"|"Rare"|"Epic"|"Legendary"|"Divine"|"Unique"

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns true if the item is an Artifact by checking the AMER_UNI tag.
---@param item Item
---@return boolean
function Item.IsArtifact(item)
    return item:HasTag("AMER_UNI") and not item:HasTag("PIP_FAKE_ARTIFACT")
end

---Returns whether an item is of Unique rarity.
---Returns `true` for Artifact items.
---@param item Item
---@return boolean
function Item.IsUnique(item)
    return item.Rarity == "Unique"
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
    return item and item.Stats and (Item.MELEE_WEAPON_TYPES:Contains(item.Stats.WeaponType) or item.Stats.WeaponType == "None")
end

---Returns the handedness of a weapon item.
---@param item Item
---@return ("One-Handed"|"Two-Handed")? -- `nil` if the item has no handedness.
function Item.GetHandedness(item)
    local handedness = nil ---@type ("One-Handed"|"Two-Handed")?
    if item.Stats then
        handedness = item.Stats.IsTwoHanded and "Two-Handed" or "One-Handed"
    end
    return handedness
end

---Returns the display name of the item.
---Considers overrides and identification status.
---Does not append item amount.
---@param item Item
---@return string
function Item.GetDisplayName(item)
    -- This uses a transcript of ecl::Item::GetDisplayName, but also includes cases that are handled elsewhere in UI, such as showing "Unidentified X". The intention is to be consistent with how names are displayed in UIs.
    local name = item.DisplayName
    local template = item.RootTemplate ---@cast template ItemTemplate
    ---@diagnostic disable-next-line: param-type-mismatch
    local templateDisplayName = Text.GetTranslatedString(template.DisplayName, "")

    if item.Known or templateDisplayName == "" then
        local customDisplayName = item.CustomDisplayName
        if Ext.IsServer() and customDisplayName ~= "" then
            name = item.CustomDisplayName
        elseif Ext.IsClient() and customDisplayName and customDisplayName.Handle.ReferenceString ~= "" then
            name = Text.GetTranslatedString(customDisplayName.Handle.Handle) -- Not sure if translating these is actually ever necessary.
        else
            if templateDisplayName ~= "" then -- A bit confusing considering the first if check, but not unused.
                name = templateDisplayName
            else
                if item.Stats then
                    if not Item.IsIdentified(item) then -- "Unidentified X". Deviation for engine method.
                        local itemTypeHandle = Item.ITEM_SLOT_TSKHANDLES[Item.GetItemSlot(item)] or "Item" -- TODO! Map weapons
                        name = Text.FormatLarianTranslatedString(Item.UNIDENTIFIED_ITEM_TSKHANDLE, Text.GetTranslatedString(itemTypeHandle))
                    else
                        local statsName = Text.GetTranslatedString(item.Stats.DisplayName.Handle.Handle, "")
                        if statsName ~= "" then
                            name = statsName
                        end
                    end
                    goto End
                end
                if item.StatsId ~= "" then
                    local nameFromStatsId = Text.GetTranslatedString(item.StatsId)
                    name = nameFromStatsId ~= "" and nameFromStatsId or name
                end
            end
        end
    end

    ::End::
    return name
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
        if Ext.IsClient() and item.Icon ~= "" then -- GB5 Icon override
            icon = item.Icon
        elseif item.Stats then
            local statObject = Ext.Stats.Get(item.Stats.Name)
            local itemGroup = Ext.Stats.ItemGroup.GetLegacy(statObject.ItemGroup)

            if itemGroup and item.Stats.LevelGroupIndex < #itemGroup.LevelGroups then
                local levelGroup = itemGroup.LevelGroups[item.Stats.LevelGroupIndex + 1]
                local rootGroup = levelGroup.RootGroups[item.Stats.RootGroupIndex + 1]
                local nameGroupLink = rootGroup.NameGroupLinks[item.Stats.NameGroupIndex + 1]

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

---Returns the use actions of an item, optionally filtered by type.
---@param item Item|ItemTemplate
---@param actionType ActionDataType
---@return IActionData[]
function Item.GetUseActions(item, actionType)
    local template
    if GetExtType(item) == "ItemTemplate" then -- Template overload.
        template = item
    else
        template = item.RootTemplate
    end
    local allActions = template.OnUsePeaceActions
    local actions = {}

    for _,action in ipairs(allActions) do
        if not actionType or action.Type == actionType then
            table.insert(actions, action)
        end
   end

   return actions
end

---Returns the current owner of the item.
---This refers to the character that has legal ownership of the item; player characters will trigger crimes by attempting most interactions with owned items.
---This character might be a player.
---The owner will be `nil` if the character who owned the item died, except for player-owned items.
---@param item Item
---@return Character?
function Item.GetOwner(item) -- TODO is this for red items?
    local ownerHandle = item.OwnerCharacterHandle
    local owner
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
    return item and item.Stats and Item.RANGED_WEAPON_TYPES:Contains(item.Stats.WeaponType)
end

---Returns whether item is a skillbook.
---@param item Item
---@return boolean
function Item.IsSkillbook(item)
    return Item.HasUseAction(item, "SkillBook")
end

---Returns the base AP cost of using an item, independent of the character.
---@param item Item
---@return integer
function Item.GetUseAPCost(item)
    local cost = 0 -- TODO is the default cost 0 or 1?

    local useActions = item.RootTemplate.OnUsePeaceActions
    for _,action in ipairs(useActions) do
        -- if action.Type == "UseSkill" then
        --     cost = Stats.Get("SkillData", action.SkillID).ActionPoints-- Pretty sure items ignore Elemental Affinity? Not 100% sure, TODO
        if action.Type == "Consume" or action.Type == "UseSkill" then -- Item object costs override skill AP costs.
            local stat = Stats.Get("StatsLib_StatsEntry_Potion", item.StatsId) or Stats.Get("StatsLib_StatsEntry_Object", item.StatsId)

            cost = stat.UseAPCost
        end
    end

    return cost
end

---Returns whether char meets the requirements to use an item.
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

    -- Grenade skills gain a reduction from Ambidextrous talent
    -- TODO there is possibly another esv::Item::GetUseType() return value
    -- that works for this; identify it.
    local stat = Stats.Get("Object", item.StatsId)
    if stat then
        -- Engine code looks as though only one is ever considered; TODO check IActionDataSet::GetActionWithId()
        local action = Item.GetUseActions(item, "UseSkill")[1] ---@cast action UseSkillActionData

        if action then
            local skill = Stats.Get("StatsLib_StatsEntry_SkillData", action.SkillID)

            if skill then
                if skill.ProjectileType ~= "Arrow" and char.Stats.TALENT_Ambidextrous then
                    apCost = apCost - 1
                end
            end
        end
    end

    canUse = canUse and ap >= apCost

    return canUse
end

---Returns all items in the party inventory of char matching the predicate, or all if no predicate is passed.
---@param char Character
---@param predicate (fun(item:Item):boolean)?
---@param recursive boolean? Defaults to `false`.
function Item.GetItemsInPartyInventory(char, predicate, recursive)
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

    -- Recrusive search is performed afterwards.
    if recursive then
        local len = #items
        local i = 1
        while i <= len do
            local item = items[i]
            if Item.IsContainer(item) then
                local contents = item:GetInventoryItems()
                for _,guid in ipairs(contents) do
                    items[len+1] = Item.Get(guid)
                    len = len + 1
                end
            end
            i = i + 1
        end
    end

    return items
end

---Returns whether an item is identified.
---@param item Item
---@return boolean
function Item.IsIdentified(item)
    if not item.Stats then return true end

    -- Following code is a CDivinityStats_Item::NeedsIdentification() transcript, but with return values flipped to match our name (IsIdentified)
    -- GlobalSwitches.AutoIdentifyItems is checked at beginning but is is editor-only - and not accessible
    local globalSwitches = Ext.Utils.GetGlobalSwitches()
    local needsIdentification = item.ItemType ~= "Undefined" and item.Stats.IsIdentified == 0

    if globalSwitches.GameMode == 1 then -- GM mode?
        return not needsIdentification
    end

    ---@diagnostic disable-next-line: assign-type-mismatch
    local stat = item.StatsFromName ---@type StatsLib_StatsEntry_Weapon|StatsLib_StatsEntry_Armor
    if stat.NeedsIdentification == "No" then
        local rarity = item.Stats.Rarity
        if rarity == "Common" or rarity == "Uncommon" or rarity == "Unique" then
            needsIdentification = false
        end
    end

    return not needsIdentification
end

--- Gets the amount of Loremaster necessary to identify an item.  
--- Ignores whether the item is already identified.
---@param item Item
---@return number
function Item.GetIdentifyRequirement(item)
    if not item.Stats then
        Item:Error("GetIdentifyRequirement", "Item has no stats; cannot get identify requirement.")
    end

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
---@return ItemSlot? --Nil if the item has no stats.
function Item.GetItemSlot(item)
    local slot = item.Stats and item.Stats.ItemSlot or nil

    return slot
end

---@param char Character
---@param slot ItemSlot
---@return Item?
function Item.GetEquippedItem(char, slot)
    local item

    if Ext.IsClient() then
        item = char:GetItemBySlot(slot)
    else
        item = Osiris.CharacterGetEquippedItem(char, slot)
    end

    item = item and Item.Get(item)

    return item
end

---Returns the subtype of item (ex. "Knife" or "Platemail").  
---Returns ItemSlot for items with no subtypes.
---@param item Item
---@return ItemLib_EquipmentType|ItemSlot
function Item.GetEquipmentSubtype(item)
    local itemType = Item.GetItemSlot(item) -- Defaults to item slot

    if Item.IsWeapon(item) then
        itemType = tostring(item.Stats.WeaponType)
    elseif Item.IsEquipment(item) then
        itemType = Stats.Get("StatsLib_StatsEntry_Armor", item.StatsId).ArmorType
    end

    return itemType
end

---Applies a dye to the item.
---@deprecated
---@param item Item
---@param dye Dye
---@return boolean False if item is already dyed with the same dye, or if dye is ``nil``.
function Item.ApplyDye(item, dye)
    local oldDye, _ = Item.GetCurrentDye(item)
    local applied = false

    if oldDye ~= dye and dye then
        local deltamod = "Boost_" .. item.Stats.ItemType .. "_" .. Data.Game.DYES[dye].Deltamod

        Osi.ItemAddDeltaModifier(item.MyGuid, deltamod)

        applied = true
    end

    return applied
end

---Returns the ID and data for the most recently-applied dye deltamod on the item.
---@param item Item
---@return string,Dye The dye ID and data table.
function Item.GetCurrentDye(item)
    local pattern = ".*_(Dye_.*)$"
    local dye = nil

    for _,mod in ipairs(item:GetDeltaMods()) do
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

    for _,v in pairs(item.Stats.DynamicStats) do

        local boostName = v.ObjectInstanceName

        if boostName ~= "" then
            table.insert(boosts, boostName)
        end
    end

    return boosts
end

--- Returns true if item is equipped by char. Assumes the item cannot be equipped into an unintended slot. Rings and weapons are checked for both slots.
---@overload fun(item:Item):boolean
---@param char Character
---@param item Item
---@return boolean
function Item.IsEquipped(char, item)
    local isEquipped = false

    if item == nil then -- Item-only overload.
        item = char ---@type Item

        local inventoryHandle = Ext.IsClient() and item.InventoryParentHandle or item.ParentInventoryHandle
        local inventory = Ext.Entity.GetInventory(inventoryHandle) ---@type EclInventory

        if inventory then
            for i=1,inventory.EquipmentSlots,1 do -- TODO verify if this property really is the amount of inventory slots
                isEquipped = inventory.ItemsBySlot[i] == item.Handle

                if isEquipped then
                    break
                end
            end
        end
    else
        isEquipped = Item.GetEquippedSlot(item, char) ~= nil
    end

    return isEquipped
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

---Returns the items contained within a container item, optionally filtered by predicate.
---@param container Item
---@param predicate (fun(item:Item):boolean)? The predicate should return `true` for items to be included. If `nil`, all items will be included.
---@return Item[]
function Item.GetContainedItems(container, predicate)
    local items = container:GetInventoryItems() ---@cast items Item[]
    for i,item in ipairs(items) do -- Change from GUID to Item class
        items[i] = Item.Get(item)
    end

    if predicate then
        items = table.filter(items, predicate)
    end

    return items
end

---------------------------------------------
-- REGION Runes.
---------------------------------------------

---Gets the stats object of the rune inserted at rune index ``index`` on item.
---@param item Item
---@param index integer **0-based.**
---@return StatItem? --`nil` if no rune is inserted at the index.
function Item.GetRune(item, index)
    if index < 0 or index > 2 then
        Item:Error("GetRune", "Cannot fetch runes with out-of-range index: " .. index)
        return
    end

    local slottedObject = item.Stats.DynamicStats[index + 3].BoostName
    if slottedObject == "" then
        return nil
    end

    return Ext.Stats.Get(slottedObject)
end

--- Returns a list of runes on the item.
---@param item Item
---@return table<number, StatItem> --Empty slots are nil.
function Item.GetRunes(item)
    return {
        [0] = Item.GetRune(item, 0),
        [1] = Item.GetRune(item, 1),
        [2] = Item.GetRune(item, 2),
    }
end

---Returns the amount of rune slots an item has.
---@param item Item
---@return integer
function Item.GetRuneSlots(item)
    local runeSlots = 0
    for _,v in pairs(item.Stats.DynamicStats) do
        runeSlots = runeSlots + v.RuneSlots
    end

    -- Game only supports a certain amount of slots.
    return math.min(runeSlots, Item.MAX_RUNE_SLOTS)
end

---Returns the icon displaying the state of item's rune slots.
---@param item Item
---@return icon? --`nil` if the item has no rune slots.
function Item.GetRuneSlotsIcon(item)
    local runes = Item.GetRunes(item)
    local slots = Item.GetRuneSlots(item)
    local filledSlots = 0
    local icon = nil
    local key = ""

    for _,_ in pairs(runes) do
        filledSlots = filledSlots + 1
    end

    for _=1,slots-filledSlots,1 do
        key = key .. "E"
    end
    for _=1,filledSlots,1 do
        key = key .. "F"
    end

    icon = Item.RUNE_SLOT_ICONS[key]

    return icon
end

--- Returns true if item has any runes slotted.
---@param item Item
---@return boolean
function Item.HasRunes(item)
    return not table.isempty(Item.GetRunes(item))
end

---Returns the level of an item.
---@param item Item
---@return integer? --`nil` if the item has no stats.
function Item.GetLevel(item)
    return item.Stats and item.Stats.Level or nil
end

---Returns the name of a rarity.
---@param rarity Item|ItemLib_Rarity
function Item.GetRarityName(rarity)
    if Entity.IsItem(rarity) then -- Item overload.
        rarity = rarity.Stats.Rarity
    end

    return Text.GetTranslatedString(Item.RARITY_HANDLES[rarity:upper()])
end

---Returns the icon frame for a rarity, if any.
---@param rarity ItemLib_Rarity|EclItem
---@return icon? --Not all rarities have icons.
function Item.GetRarityIcon(rarity)
    ---Item overload.
    if type(rarity) ~= "string" then
        local item = rarity

        rarity = item.Stats and item.Stats.Rarity or ""
    end
    return Item._ITEM_RARITY_ICONS[rarity]
end

---Returns whether an item is marked as wares.
---@param item Item
---@return boolean
function Item.IsMarkedAsWares(item)
    return item.Flags["DontAddToBottomBar"]
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

    for _,guid in pairs(entity:GetInventoryItems()) do
        local item = Item.Get(guid)

        if predicate == nil or predicate(item) then
            table.insert(items, item)
        end
    end

    return items
end