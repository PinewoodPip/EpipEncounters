
local Vanity = Client.UI.Vanity
local VanityFeature = Epip.GetFeature("Feature_Vanity")
local Hotbar = Client.UI.Hotbar

---@class Feature_Vanity_Transmog
local Transmog = Epip.GetFeature("Feature_Vanity_Transmog")
Transmog.keepIcon = false

---@type table<CharacterHandle, number[]>
Transmog._SkinColors = {}

Transmog._ItemSlotToEquipmentMask = {
    Helmet = 1,
    Breast = 2,
    Leggings = 4,
    Weapon = 8,
    Shield = 16,
    Ring = 32,
    Belt = 64,
    Boots = 128,
    Gloves = 256,
    Amulet = 512,
    Ring2 = 1014,
    Wings = 2048,
    Horns = 4096,
    Overhead = 8192,
}

Transmog._BlacklistedSlots = {
    [Ext.Enums.ItemSlot32.Ring] = true,
    [Ext.Enums.ItemSlot32.Ring2] = true,
    [Ext.Enums.ItemSlot32.Amulet] = true,
    [Ext.Enums.ItemSlot32.Wings] = true,
    [Ext.Enums.ItemSlot32.Horns] = true,
    [Ext.Enums.ItemSlot32.Overhead] = true,
}

---------------------------------------------
-- EVENTS / HOOKS
---------------------------------------------

---@class VanityTransmog_Event_AppearanceReapplied
---@field Character EclCharacter
---@field Item EclItem
---@field Template ItemTemplate Template whose visual was reapplied to the item.
---@type Event<VanityTransmog_Event_AppearanceReapplied>
Transmog.Events.AppearanceReapplied = Transmog:AddSubscribableEvent("AppearanceReapplied")

---@class VanityTransmog_Hook_TemplateBelongsToCategory
---@field BelongsToCategory boolean Hookable. Defaults to `false`.
---@field TemplateData VanityTemplate
---@field Category VanityCategory
---@type Event<VanityTransmog_Hook_TemplateBelongsToCategory>
Transmog.Hooks.TemplateBelongsToCategory = Transmog:AddSubscribableHook("TemplateBelongsToCategory")

---@class VanityTransmog_Hook_ShouldRenderEntry
---@field ShouldRender boolean Hookable. Defaults to `false`.
---@field TemplateGUID GUID
---@field Category VanityCategory The category of the entry.
---@field Item EclItem The currently-selected item.
---@type Event<VanityTransmog_Hook_ShouldRenderEntry>
Transmog.Hooks.ShouldRenderEntry = Transmog:AddSubscribableHook("ShouldRenderEntry")

---@class VanityTransmog_Hook_CanTransmog
---@field CanTransmog boolean Hookable. Defaults to `true`.
---@field Item EclItem
---@type Event<VanityTransmog_Hook_CanTransmog>
Transmog.Hooks.CanTransmog = Transmog:AddSubscribableHook("CanTransmog")

---------------------------------------------
-- METHODS
---------------------------------------------

function Transmog.ShouldRenderEntry(templateGUID, category, item)
    item = item or Vanity.GetCurrentItem()
    local char = Client.GetCharacter()
    local data = Vanity.TEMPLATES[templateGUID]
    local itemSlot = Item.GetItemSlot(item)

    if itemSlot == "Shield" then
        itemSlot = "Weapon"
    end

    if Transmog.BelongsToCategory(data, category) and (itemSlot == data.Slot or data.Slot == "None") then
        local gender = Game.Character.GetGender(char)
        local race = Game.Character.GetRace(char)

        -- Chestplate doesn't show non-chest items - sorry, too much stuff.
        return ((data.Tags[gender] and data.Tags[race]) or (itemSlot == "Weapon" and data.Slot == "Weapon")) and (itemSlot == data.Slot or (itemSlot ~= "Breast" and itemSlot ~= "Weapon"))
    end

    return false
end

---@param item EclItem
---@return boolean
function Transmog.ShouldKeepAppearance(item)
    local keepAppearance = false
    local char = Client.GetCharacter()

    if item and Item.IsEquipped(char, item) then
        local tag = Transmog.KEEP_APPEARANCE_TAG_PREFIX .. tostring(Item.GetEquippedSlot(item))

        keepAppearance = Client.GetCharacter():HasTag(tag)
    end

    return keepAppearance
end

---Transmogs an item to the persistent outfit of a character.
---@param char EclCharacter
---@param item EclItem Must be equipped by the character.
function Transmog.ReapplyAppearance(char, item)
    local slot = Item.GetEquippedSlot(item, char)
    local newTemplate = Transmog.activeCharacterTemplates[slot]
    if newTemplate then
        Transmog.TransmogItem(item, newTemplate)

        Transmog.Events.AppearanceReapplied:Throw({
            Character = char,
            Item = item,
            Template = newTemplate,
        })
    end
end

---Requests an override for char's weapon animations.
---@param char EclCharacter
---@param animType CharacterLib.WeaponAnimationType
function Transmog.RequestWeaponAnimationOverride(char, animType)
    Net.PostToServer(Transmog.NETMSG_SET_WEAPON_ANIMATION_OVERRIDE, {
        CharacterNetID = char.NetID,
        AnimType = animType,
    })
end

function Transmog.UpdateActiveCharacterTemplates()
    local char = Client.GetCharacter()

    for _,slot in ipairs(Data.Game.SLOTS_WITH_VISUALS) do
        local item = char:GetItemBySlot(slot)

        if item then
            item = Item.Get(item)

            Transmog.activeCharacterTemplates[slot] = Transmog.GetTransmoggedTemplate(item) or item.RootTemplate.Id
        else
            Transmog.activeCharacterTemplates[slot] = nil
        end
    end

    Transmog:DebugLog("Updated active character templates.")
end

---Returns whether an item supports being transmogged.
---@see VanityTransmog_Hook_CanTransmog
---@param item EclItem
---@return boolean
function Transmog.CanTransmogItem(item)
    return Transmog.Hooks.CanTransmog:Throw({
        CanTransmog = true,
        Item = item,
    }).CanTransmog
end

---Request an item to be transmog'd into a template.
---@param item EclItem? Defaults to current item based on the selected slot in the UI.
---@param template string
function Transmog.TransmogItem(item, template)
    item = item or Vanity.GetCurrentItem()

    if Transmog.CanTransmogItem(item) then
        Net.PostToServer("EPIPENCOUNTERS_VanityTransmog", {
            Char = Client.GetCharacter().NetID,
            Item = item.NetID,
            NewTemplate = template,
            KeepIcon = Transmog.keepIcon;
        })

        -- Set icon override.
        if not Transmog.keepIcon then
            local itemTemplate = Ext.Template.GetTemplate(template) ---@cast itemTemplate ItemTemplate

            item.Icon = itemTemplate.Icon
        else
            item.Icon = Item.GetIcon(item)
        end

        -- Refresh UI
        if Vanity.currentTab ~= nil then
            -- We track this to update the UI immediately, without needing to wait for server.
            Vanity.currentItemTemplateOverride = template
            Vanity.Refresh()
        end
    end
end

---Reverts an item's appearance to its original state.
---Will notify the server to do the same.
---@param char EclCharacter
---@param item EclItem
function Transmog.RevertAppearance(char, item)
    Net.PostToServer(Transmog.NET_MSG_REVERT_APPEARANCE, {
        CharacterNetID = char.NetID,
        ItemNetID = item.NetID,
    })
    Transmog._RevertAppearance(char, item)
end

---Reverts an item's appearance to its original state.
---@param char EclCharacter
---@param item EclItem
---@diagnostic disable-next-line: unused-local
function Transmog._RevertAppearance(char, item)
    Transmog.SetItemIcon(item, "")
end

---Sets a persistent icon override for an item.
---@param item EclItem
---@param icon icon Use empty string to clear the override.
function Transmog.SetItemIcon(item, icon)
    local char = Item.GetOwner(item) or Client.GetCharacter()
    item.Icon = icon

    Net.PostToServer(Transmog.NET_MSG_SET_ICON, {CharacterNetID = char.NetID, ItemNetID = item.NetID, Icon = icon})
    Vanity.Refresh() -- Necessary for item icon to be immediately reflected, for some reason. TODO investigate?
end

---Toggles visibility of an equipment item's visuals while it is equipped.
---@param item EclItem? Defaults to current vanity item.
---@param visible boolean?
function Transmog.ToggleVisibility(item, visible)
    item = item or Vanity.GetCurrentItem()
    if visible == nil then visible = item:HasTag(Transmog.INVISIBLE_TAG) end

    Net.PostToServer("EPIPENCOUNTERS_Vanity_Transmog_ToggleVisibility", {
        CharacterNetID = Client.GetCharacter().NetID,
        ItemNetID = item.NetID,
        State = visible,
    })
end

---Returns whether a template belongs to a category.
---@param templateData VanityTemplate
---@param category VanityCategory | string
function Transmog.BelongsToCategory(templateData, category) -- TODO extract default logic onto a hook
    if type(category) == "string" then
        category = Vanity.CATEGORIES[category]
    end

    local matchingTagsCount = 0
    local categoryTagCount = table.getKeyCount(category.Tags)

    -- 0-tag categories work too, accepting all templates
    local belongs = matchingTagsCount == categoryTagCount

    if not belongs then
        for tag,_ in pairs(category.Tags) do
            if templateData.Tags[tag] then
                matchingTagsCount = matchingTagsCount + 1

                -- Return true if the category doesnt need all tags to match
                -- or if all tags matched
                if not category.RequireAllTags or matchingTagsCount == categoryTagCount then
                    belongs = true
                    break
                end
            end
        end
    end

    return Transmog.Hooks.TemplateBelongsToCategory:Throw({
        BelongsToCategory = belongs,
        TemplateData = templateData,
        Category = category,
    }).BelongsToCategory
end

---Get the categories that have templates suitable for this item.
---@param item EclItem
---@return table<string,VanityCategoryQuery>
function Transmog.GetCategories(item)
    local categories = {}

    for _,id in ipairs(Vanity.CATEGORY_ORDER) do
        local categoryData = Vanity.CATEGORIES[id]
        local inserted = false
        local categoryQuery = {
            Data = categoryData,
            Templates = {},
        }

        for guid,data in pairs(Vanity.TEMPLATES) do
            local shouldRender = Transmog.Hooks.ShouldRenderEntry:Throw({
                ShouldRender = false,
                TemplateGUID = guid,
                Category = categoryData,
                Item = item,
            }).ShouldRender

            if shouldRender then
                if not inserted then
                    table.insert(categories, categoryQuery)
                    inserted = true
                end
                table.insert(categoryQuery.Templates, data)
            end
        end
    end

    return categories
end

---Returns whether an item slot's masks should be applicable to the character.
---@param char EclCharacter
---@param slot ItemSlot32
---@return boolean
function Transmog._CanApplyMasks(char, slot)
    local applyMasks = slot ~= "Helmet" or char.PlayerData.HelmetOptionState

    -- Consider invisible transmogs
    local equippedItem = char:GetItemObjectBySlot(slot)
    if equippedItem then
        applyMasks = applyMasks and not Transmog.IsItemInvisible(equippedItem, char)
    end

    return applyMasks
end

---Returns the equipment and visual set masks for a character's equipped items.
---@param char EclCharacter
---@return integer, integer -- Equipment slot mask and visual set slot mask.
function Transmog._GetEquipmentMasks(char)
    local equipmentMask = 0
    local visualSetMask = 0

    -- Gather equipment masks
    for _,slot in pairs(Ext.Enums.ItemSlot32) do
        local item = char:GetItemObjectBySlot(slot)
        if item then
            local transmoggedTemplateGUID = Transmog.GetTransmoggedTemplate(item)
            local template = transmoggedTemplateGUID and Ext.Template.GetTemplate(transmoggedTemplateGUID) or item.CurrentTemplate

            if Transmog._CanApplyMasks(char, slot) then
                local templateEquipmentMask = template.Equipment.EquipmentSlots
                templateEquipmentMask = templateEquipmentMask & ~(Transmog._ItemSlotToEquipmentMask[slot]) -- An item cannot mask itself.
                equipmentMask = equipmentMask | templateEquipmentMask
            end
        end
    end

    -- Gather visual slot masks *only* from items whose equipment hasn't been masked
    for _,slot in pairs(Ext.Enums.ItemSlot32) do
        local item = char:GetItemObjectBySlot(slot)
        if item then
            local transmoggedTemplateGUID = Transmog.GetTransmoggedTemplate(item)
            local template = transmoggedTemplateGUID and Ext.Template.GetTemplate(transmoggedTemplateGUID) or item.CurrentTemplate

            if Transmog._CanApplyMasks(char, slot) and (equipmentMask & Transmog._ItemSlotToEquipmentMask[slot] == 0) then
                visualSetMask = visualSetMask | template.Equipment.VisualSetSlots
            end
        end
    end

    return equipmentMask, visualSetMask
end

---Returns whether an item is set to not show equipment visuals for a character.
---@param item EclItem
---@param char Character? If present, the character's helmet state will be considered.
---@return boolean
function Transmog.IsItemInvisible(item, char)
    local invisible = item and item:IsTagged(Transmog.INVISIBLE_TAG)

    -- Respect helmet visibility choice of the character
    if char then
        local equippedSlot = Item.GetEquippedSlot(item, char)
        if equippedSlot then
            invisible = invisible or (equippedSlot == "Helmet" and char.PlayerData and char.PlayerData.HelmetOptionState == false)
        end
    end

    return invisible
end

---Returns the weapon animation set override for char.
---@param char Character
---@return CharacterLib.WeaponAnimationType? -- `nil` for `NONE`.
function Transmog.GetWeaponAnimationOverride(char)
    return tonumber(Entity.GetParameterTagValue(char, Transmog.WEAPON_ANIMATION_OVERRIDE_TAG_PATTERN))
end

---Returns whether equipment can be shown for a character.
---@param char EclCharacter
---@return boolean
function Transmog._CanShowEquipment(char)
    local canShow = true

    -- Check if the character's body is present, if they're dead
    local dyingStatus = char:GetStatus("DYING") ---@cast dyingStatus EclStatusDying
    if dyingStatus then
        local deathReason = dyingStatus.DeathType
        canShow = canShow and not Character.CORPSELESS_DEATH_TYPES[deathReason]
    end

    return canShow
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Make item visuals invisible if they were set to be.
Character.Hooks.CreateEquipmentVisuals:Subscribe(function (ev)
    local request = ev.Request
    local item = ev.Item

    if item and Transmog.IsItemInvisible(item, ev.Character) then
        request.VisualResourceID = ""
        request.EquipmentSlotMask = 0
        request.VisualSetSlotMask = 0

        ev:StopPropagation()
    end
end)

-- Listen for items being equipped to run bookkeeping routines and reapply appearance.
Character.Events.ItemEquipped:Subscribe(function (ev)
    local char = ev.Character
    local item = ev.Item

    if char == Client.GetCharacter() then
        if not Vanity.IsOpen() and Transmog.ShouldKeepAppearance(item) then
            Transmog:DebugLog("Reapplying appearance.")

            Transmog.ReapplyAppearance(char, item)

            Timer.Start("", 0.4, function()
                Transmog.UpdateActiveCharacterTemplates()
            end)
        elseif Vanity.IsOpen() then
            Timer.Start("", 0.4, function()
                Transmog.UpdateActiveCharacterTemplates()

                -- TODO implement this better...
                Epip.GetFeature("Feature_Vanity_Dyes").UpdateActiveCharacterDyes()
            end)
        else
            Transmog.UpdateActiveCharacterTemplates()
        end
    end
end)

-- Listen for icon overrides being removed - since the server does not have the property that handles these, it must be done on client.
Net.RegisterListener(Transmog.NET_MSG_ICON_REMOVED, function (payload)
    local item = Item.Get(payload.ItemNetID)

    Transmog:DebugLog("Removing client icon override from", item.DisplayName)

    item.Icon = ""
end)

-- Update character templates upon game start, active character changing, and refreshing appearance.
GameState.Events.GameReady:Subscribe(function (_)
    Transmog.UpdateActiveCharacterTemplates()
end)
Utilities.Hooks.RegisterListener("Client", "ActiveCharacterChanged", function()
    Transmog.UpdateActiveCharacterTemplates()
end)
Net.RegisterListener("EPIPENCOUNTERS_Vanity_RefreshSheetAppearance", function(_)
    Transmog.UpdateActiveCharacterTemplates()
end)

-- Render templates of the same slot as the item being transmog'd
-- if they belong to the category.
-- Items with "None" slot (which do not hide any armor visual handled by game) can render on any item, except breastplates, so as not to bloat their menu. TODO remove breastplate restriction
Transmog.Hooks.ShouldRenderEntry:Subscribe(function (ev)
    if not ev.ShouldRender then
        ev.ShouldRender = Transmog.ShouldRenderEntry(ev.TemplateGUID, ev.Category, ev.Item)
    end
end)

Transmog.Hooks.TemplateBelongsToCategory:Subscribe(function (ev)
    if ev.Category.ID == "Favorites" then
        ev.BelongsToCategory = Transmog.favoritedTemplates[ev.TemplateData.GUID] == true
    end
end)

-- Save favorite templates.
VanityFeature.Hooks.GetSaveData:Subscribe(function (ev)
    local data = ev.SaveData ---@cast data Features.Vanity.Transmog.SaveData
    data.Favorites = Transmog.favoritedTemplates
end)

-- Load favorite templates.
VanityFeature.Events.SaveDataLoaded:Subscribe(function (ev)
    local data = ev.SaveData ---@cast data Features.Vanity.Transmog.SaveData
    if data.Version >= 3 then
        Transmog.favoritedTemplates = data.Favorites or {}
    end
end)

Client.UI.ContextMenu.RegisterElementListener("epip_OpenVanity", "buttonPressed", function(item, _)
    Vanity.SetSlot(item)
    Vanity.Setup(Vanity.currentTab or Transmog.Tab)
end)

-- Show transmog'd visuals instead of the item's real ones.
Character.Hooks.CreateEquipmentVisuals:Subscribe(function (ev)
    local characterCreation = Ext.UI.GetCharacterCreationWizard()
    local char = ev.Character

    -- Don't render visuals for character creation characters with armor toggled off.
    if characterCreation and characterCreation.CharacterHandle == char.Handle then
        for _,cust in pairs(characterCreation.CharacterCreationManager.Customizations) do
            if cust.CharacterHandle == char.Handle and cust.ArmorState == 0 then
                return
            end
        end
    end

    -- Do nothing for blacklisted slots or non-players.
    if Transmog._BlacklistedSlots[ev.Request.Slot] or not char.PlayerData or not Transmog._CanShowEquipment(char) then
        return
    end

    local equipmentSlotMask, visualSetSlotMask = Transmog._GetEquipmentMasks(char)

    -- Update skin color tracking - we cannot calculate the exact color ourselves
    if ev.Request.ApplyColors then
        Transmog._SkinColors[char.Handle] = ev.Request.Colors[1]
    end

    if ev.Item then
        local transmoggedTemplateGUID = Transmog.GetTransmoggedTemplate(ev.Item)
        local slot = ev.Request.Slot
        local template

        if transmoggedTemplateGUID then
            template = Ext.Template.GetTemplate(transmoggedTemplateGUID) ---@cast template ItemTemplate
        elseif slot ~= "Weapon" and slot ~= "Shield" then -- Render the original item anyways; this is necessary for correct behaviour when other item slots have an item with masks that has been transmogged into one with fewer masks.
            template = ev.Item.CurrentTemplate
        end

        -- Only proceed if the item is transmogged into a template that
        -- exists (ex. it won't if user removed the mod that it's from)
        if template then
            if slot == "Weapon" or slot == "Shield" then
                ev.Request.VisualResourceID = template.VisualTemplate
                ev.Request.EquipmentSlotMask = 0
                ev.Request.VisualSetSlotMask = 0

                -- Change the attachment point of weapons/offhands.
                if not char.WeaponSheathed then
                    local bone
                    local vanityData = Vanity.TEMPLATES[transmoggedTemplateGUID]

                    if vanityData then
                        -- Set bone based on vanity tags.
                        local tags = vanityData.Tags
                        local BONES = Item.SHEATHED_ATTACHMENT_BONES

                        if tags["Shield"] then
                            bone = BONES.SHIELD
                        elseif tags["Staff"] or tags["Spear"] then
                            bone = BONES.POLEARM
                        elseif tags["Bow"] then
                            bone = BONES.BOW
                        elseif tags["Crossbow"] then
                            bone = BONES.CROSSBOW
                        elseif tags["2H"] then
                            bone = BONES.TWO_HANDED
                        else
                            bone = slot == "Weapon" and BONES.ONE_HANDED or BONES.OFF_HAND
                        end

                        ev.Request.AttachmentBoneName = bone
                    else
                        Transmog:LogError("Vanity template data missing for " .. transmoggedTemplateGUID)
                    end
                end
            else
                -- If the slot is not weapon/shield, we need to fetch the correct visual from the template's Equipment.
                local equipmentClassIndex = char.CurrentTemplate.EquipmentClass + 1 -- Needs to be converted from 0-based to 1-based.

                ev.Request.VisualResourceID = template.Equipment.VisualResources[equipmentClassIndex]

                ev.Request.EquipmentSlotMask = equipmentSlotMask
                ev.Request.VisualSetSlotMask = visualSetSlotMask

                -- Hide masked slots, except in cases where a template is attempting to mask its own slot (ex. full-body replacements from Fashion Sins).
                local slotMask = Transmog._ItemSlotToEquipmentMask[slot]
                local templateSlotMask = template.Equipment.EquipmentSlots
                if slotMask and slotMask & equipmentSlotMask ~= 0 and slotMask & templateSlotMask == 0 then
                    ev.Request.VisualResourceID = ""
                    ev.Request.VisualSetSlotMask = 0
                end

                -- Apply skin color and other missing parameters to slots that the engine would normally mask
                if char.PlayerData and not ev.Request.Armor then
                    local skinColor = Transmog._SkinColors[char.Handle]
                    if skinColor then
                        ev.Request.Colors[1] = skinColor -- Second color is hair color
                    end
                    ev.Request.AllowTPose = true
                    ev.Request.ApplyColors = true
                    ev.Request.Armor = true
                    ev.Request.SomeWeaponFlag = true
                    ev.Request.AttachFlags = "Armor"
                end
            end
        end
    else
        -- Apply visual set slot mask nonetheless, to handle the case of unequipping an item that *would've* been masked by the engine, if the user hadn't transmogged the item that was masking it.
        ev.Request.VisualSetSlotMask = visualSetSlotMask
    end
end)

-- Set Icon overrides for items upon loading in.
GameState.Events.GameReady:Subscribe(function (_)
    Transmog:DebugLog("Finding icon overrides...")

    -- Set icon overrides for items in player character inventories.
    local chars = Client.UI.PlayerInfo.GetCharacters()
    for _,char in ipairs(chars) do
        local items = char:GetInventoryItems()

        for _,itemGUID in ipairs(items) do
            local item = Item.Get(itemGUID)

            if Item.IsEquipment(item) then
                local icon = Transmog.GetIconOverride(item)

                if icon then
                    Transmog:DebugLog("Found icon override for", item.DisplayName)

                    item.Icon = icon
                end
            end
        end
    end
end)

-- Request visuals to be updated when the helmet visual is toggled.
Client.UI.CharacterSheet.Events.HelmetToggled:Subscribe(function (_)
    Vanity.RefreshAppearance(true)
end)

-- Clear icon override when appearance is reset.
VanityFeature.Events.ItemAppearanceReset:Subscribe(function (ev)
    Transmog._RevertAppearance(ev.Character, ev.Item)
end)

-- Apply weapon animation set overrides; requires the fork.
if Transmog._SupportsWeaponAnimationOverrides() then
    Ext.Events.GetCharacterWeaponAnimationSetType:Subscribe(function(ev)
        local stats = ev.Character ---@type CDivinityStats_Character
        local char = stats.Character ---@cast char Character
        if char.IsPlayer then -- Only do this for players.
            local override = Transmog.GetWeaponAnimationOverride(char)
            if override then
                ev.AnimationSetType = override
            end
        end
    end)
end

---------------------------------------------
-- HOTBAR ACTION
---------------------------------------------

Hotbar.RegisterAction("EpipVanity", {Name = "Vanity", Icon = Hotbar.ACTION_ICONS.HAT})
Hotbar.RegisterActionListener("EpipVanity", "ActionUsed", function(_)
    Vanity.SetSlot("Breast")
    Vanity.Setup(Transmog.Tab)
end)
Hotbar.RegisterActionHook("EpipVanity", "IsActionEnabled", function(enabled, _, _, _)
    if enabled then
        enabled = not Client.IsInCombat()
    end
    return enabled
end)
