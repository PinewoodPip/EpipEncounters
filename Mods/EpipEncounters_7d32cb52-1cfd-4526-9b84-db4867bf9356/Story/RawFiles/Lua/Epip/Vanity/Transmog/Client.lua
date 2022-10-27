
local Vanity = Client.UI.Vanity
local Hotbar = Client.UI.Hotbar

---@class Feature_Vanity_Transmog
local Transmog = Epip.GetFeature("Feature_Vanity_Transmog")
Transmog.keepIcon = false

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class EPIPENCOUNTERS_Vanity_Transmog_ToggleVisibility : Net_SimpleMessage_State, Net_SimpleMessage_Item, Net_SimpleMessage_Character

---------------------------------------------
-- EVENTS / HOOKS
---------------------------------------------

---@type VanityTransmog_Event_AppearanceReapplied
Transmog.Events.AppearanceReapplied = Transmog:AddEvent("AppearanceReapplied")

---@type VanityTransmog_Hook_TemplateBelongsToCategory
Transmog.Hooks.TemplateBelongsToCategory = Transmog:AddHook("TemplateBelongsToCategory")
---@type VanityTransmog_Hook_ShouldRenderEntry
Transmog.Hooks.ShouldRenderEntry = Transmog:AddHook("ShouldRenderEntry")
---@type VanityTransmog_Hook_CanTransmog
Transmog.Hooks.CanTransmog = Transmog:AddHook("CanTransmog")

---@class VanityTransmog_Event_AppearanceReapplied : Event
---@field RegisterListener fun(self, listener:fun(item:EclItem, template:ItemTemplate))
---@field Fire fun(self, item:EclItem, template:ItemTemplate)

---@class VanityTransmog_Hook_TemplateBelongsToCategory : Hook
---@field RegisterHook fun(self, handler:fun(belongs:boolean, templateData:VanityTemplate, category:VanityCategory))
---@field Return fun(self, belongs:boolean, templateData:VanityTemplate, category:VanityCategory)

---@class VanityTransmog_Hook_ShouldRenderEntry : Hook
---@field RegisterHook fun(self, handler:fun(render:boolean, templateGUID:GUID, category:VanityCategory, item:EclItem))
---@field Return fun(self, render:boolean, templateGUID:GUID, category:VanityCategory, item:EclItem)

---@class VanityTransmog_Hook_CanTransmog : Hook
---@field RegisterHook fun(self, handler:fun(canTransmog:boolean, item:EclItem))
---@field Return fun(self, canTransmog:boolean, item:EclItem)

---------------------------------------------
-- METHODS
---------------------------------------------

function Transmog.ShouldRenderEntry(templateGUID, category, item)
    item = item or Vanity.GetCurrentItem()
    local char = Client.GetCharacter()
    local data = Vanity.TEMPLATES[templateGUID]
    local itemSlot = Item.GetItemSlot(item)
    local itemSubtype = Item.GetEquipmentSubtype(item)

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
        local tag = Transmog.KEEP_APPEARANCE_TAG_PREFIX .. Item.GetEquippedSlot(item)

        keepAppearance = Client.GetCharacter():HasTag(tag)
    end

    return keepAppearance
end

function Transmog.ReapplyAppearance(item)
    local slot = Item.GetItemSlot(item)
    local newTemplate = Transmog.activeCharacterTemplates[slot]
    if not newTemplate then return nil end

    Transmog.TransmogItem(item, newTemplate)

    Transmog.Events.AppearanceReapplied:Fire(item, newTemplate)
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

function Transmog.CanTransmogItem(item)
    return Transmog.Hooks.CanTransmog:Return(true, item)
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
            local itemTemplate = Ext.Template.GetTemplate(template) ---@type ItemTemplate

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
function Transmog.BelongsToCategory(templateData, category)
    if type(category) == "string" then
        category = Vanity.CATEGORIES[category]
    end

    local matchingTagsCount = 0
    local categoryTagCount = 0

    for i,v in pairs(category.Tags) do
        categoryTagCount = categoryTagCount + 1
    end

    -- 0-tag categories work too, accepting all templates
    local belongs = matchingTagsCount == categoryTagCount

    if not belongs then
        for tag,bool in pairs(category.Tags) do
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

    return Transmog.Hooks.TemplateBelongsToCategory:Return(belongs, templateData, category)
end

---Get the categories that have templates suitable for this item.
---@param item EclItem
---@return table<string,VanityCategoryQuery>
function Transmog.GetCategories(item)
    -- Categories
    local slot = Item.GetItemSlot(item)
    local categories = {}

    for i,id in ipairs(Vanity.CATEGORY_ORDER) do
        local categoryData = Vanity.CATEGORIES[id]
        local inserted = false
        local categoryQuery = {
            Data = categoryData,
            Templates = {},
        }

        for guid,data in pairs(Vanity.TEMPLATES) do
            -- local shouldRender = Vanity:ReturnFromHooks("ShouldRenderTemplateEntry", false, guid, categoryData, item)
            local shouldRender = Transmog.Hooks.ShouldRenderEntry:Return(false, guid, categoryData, item)

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

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Make item visuals invisible if they were set to be.
Character.Hooks.CreateEquipmentVisuals:Subscribe(function (ev)
    local request = ev.Request
    local item = ev.Item

    if item and item:IsTagged(Transmog.INVISIBLE_TAG) then
        request.VisualResourceID = ""
        request.EquipmentSlotMask = 0
        request.VisualSetSlotMask = 0
        
        ev:StopPropagation()
    end
end)

Net.RegisterListener("EPIPENCOUNTERS_ItemEquipped", function(payload)
    local char = Character.Get(payload.NetID)
    local item = Item.Get(payload.ItemNetID)

    if char == Client.GetCharacter() then
        if not Vanity.IsOpen() and Transmog.ShouldKeepAppearance(item) then
            Transmog:DebugLog("Reapplying appearance.")

            Transmog.ReapplyAppearance(item)

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

GameState.Events.GameReady:Subscribe(function (e)
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
Transmog.Hooks.ShouldRenderEntry:RegisterHook(function (render, templateGUID, category, item)
    if not render then
        render = Transmog.ShouldRenderEntry(templateGUID, category, item)
    end
    
    return render
end)

Transmog.Hooks.TemplateBelongsToCategory:RegisterHook(function (belongs, templateData, category)
    if category.ID == "Favorites" then
        belongs = Transmog.favoritedTemplates[templateData.GUID] == true
    end

    return belongs
end)

Vanity.Hooks.GetSaveData:RegisterHook(function (data)
    data.Favorites = Transmog.favoritedTemplates

    return data
end)

Vanity.Events.SaveDataLoaded:RegisterListener(function (data)
    if data.Version >= 3 then
        Transmog.favoritedTemplates = data.Favorites
    end
end)

Client.UI.ContextMenu.RegisterElementListener("epip_OpenVanity", "buttonPressed", function(item, _)
    Vanity.SetSlot(item)
    Vanity.Setup(Vanity.currentTab or Transmog.Tab)
end)

-- Show transmog'd visuals instead of the item's real ones.
Character.Hooks.CreateEquipmentVisuals:Subscribe(function (ev)
    if ev.Item then
        local char = ev.Character
        local transmoggedTemplate = Transmog.GetTransmoggedTemplate(ev.Item)
        local slot = ev.Request.Slot

        if transmoggedTemplate then
            local template = Ext.Template.GetTemplate(transmoggedTemplate) ---@type ItemTemplate

            if slot == "Weapon" or slot == "Shield" then
                ev.Request.VisualResourceID = template.VisualTemplate
                ev.Request.EquipmentSlotMask = 0
                ev.Request.VisualSetSlotMask = 0

                -- Change the attachment point of weapons/offhands.
                if not char.WeaponSheathed then
                    local bone
                    local vanityData = Vanity.TEMPLATES[transmoggedTemplate]

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
                        Transmog:LogError("Vanity template data missing for " .. transmoggedTemplate)
                    end
                end
            else
                -- If the slot is not weapon/shield, we need to fetch the correct visual from the template's Equipment.
                local equipmentClassIndex = Character.EQUIPMENT_VISUAL_CLASS.NONE
                local gender = Character.IsMale(char) and "MALE" or "FEMALE"
                local race = Character.GetRace(char):upper()
                local isUndead = Character.IsUndead(char) and "UNDEAD_" or ""

                equipmentClassIndex = Character.EQUIPMENT_VISUAL_CLASS[string.format("%s%s_%s", isUndead, race, gender)]

                ev.Request.VisualResourceID = template.Equipment.VisualResources[equipmentClassIndex]
                ev.Request.EquipmentSlotMask = template.Equipment.EquipmentSlots
                ev.Request.VisualSetSlotMask = template.Equipment.VisualSetSlots
            end
        end
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