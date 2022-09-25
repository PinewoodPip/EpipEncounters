
local Vanity = Client.UI.Vanity
local Hotbar = Client.UI.Hotbar

local Transmog = {
    favoritedTemplates = {},
    activeCharacterTemplates = {},
    KEEP_APPEARANCE_TAG_PREFIX = "PIP_Vanity_Transmog_KeepAppearance_",
    INVISIBLE_TAG = "PIP_VANITY_INVISIBLE",
    keepIcon = false,

    BLOCKED_TEMPLATES = {
        -- Captain
        ["79aee656-f5e5-4db8-9c7c-ffc7bcd8b59e"] = true,
        ["820dab86-4afe-4b17-9ccc-79e381bf59cd"] = true,
        ["a0920371-9f1f-4285-a1d0-e7dead1b7398"] = true,

        -- Contamination
        ["791205be-2432-4acb-bcdb-01a5b6bd391b"] = true,
        ["12956e00-7efe-47d9-a659-60f9fabbaaf9"] = true,
        ["ac2a6202-246c-4e90-9d11-7c55bcb6193b"] = true,
        ["fc06302c-dad9-4691-953a-5f5a19ba9881"] = true,
        ["0abd081e-3cc0-4f1d-863e-e3b34e56dfe8"] = true,
        ["88d9f9ac-96fb-4ca7-a241-c61a3f662050"] = true,
        ["b894ae2c-a2d5-46da-9050-1e50a7edec63"] = true,
        ["419de8e7-c7d5-4bce-93b1-3da03565ab70"] = true,
        ["7a3fe2b8-5881-45ba-be33-d34e8e48c852"] = true,

        -- Vulture
        ["dff85e5f-c72a-40ed-9036-5b08f8ae2b2f"] = true,
        ["99b04103-ba96-4517-86f6-50cba862220f"] = true,
        ["8a1b807d-9865-4fbd-9d98-b0904445761e"] = true,
        ["b9453748-d153-4709-9d50-2790a3fa2578"] = true,
        ["8b1bf641-28d3-4ec3-a1ab-d697c4ebfa85"] = true,
        ["698a3588-e9e7-4ffb-9c85-1056a27ac611"] = true,
        ["9db3d6b2-86c2-490c-8fbf-2a14b9ba774a"] = true,
        ["72f2197b-e366-4298-8bf4-0d99508e9f86"] = true,
        ["4476e95e-dc38-4fad-aa83-05053d7a908a"] = true,
        ["84dac3eb-65c0-4085-8521-4142c50b893d"] = true,
        ["f89552b1-2780-48c0-8836-278146ae1b51"] = true,
        ["6d9bd692-db47-4c1d-aa68-001b69bd1c5d"] = true,

        -- Devourer
        ["e3141a3f-7e33-419a-bb11-ee47b3c86e8a"] = true,
        ["64799c69-9eca-41bc-854b-3178c4192bcf"] = true,
        ["62190ebb-943e-4640-bb35-f6688418060c"] = true,
        ["327918c7-804e-42fa-9ec4-c53d711876b8"] = true,
        ["a18a346d-30eb-45b7-852b-37cbe7d20f68"] = true,
    },

    Events = {
        ---@type VanityTransmog_Event_AppearanceReapplied
        AppearanceReapplied = {},
    },
    Hooks = {
        ---@type VanityTransmog_Hook_TemplateBelongsToCategory
        TemplateBelongsToCategory = {},
        ---@type VanityTransmog_Hook_ShouldRenderEntry
        ShouldRenderEntry = {},
        ---@type VanityTransmog_Hook_CanTransmog
        CanTransmog = {},
    },
}
Epip.AddFeature("VanityTransmog", "VanityTransmog", Transmog)
Epip.Features.VanityTransmog = Transmog

---@type CharacterSheetCustomTab
local Tab = Vanity.CreateTab({
    Name = "Transmog",
    ID = "PIP_Vanity_Transmog",
    Icon = "hotbar_icon_magic",
})

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class EPIPENCOUNTERS_Vanity_Transmog_ToggleVisibility : Net_SimpleMessage_State, Net_SimpleMessage_Item, Net_SimpleMessage_Character

---------------------------------------------
-- EVENTS / HOOKS
---------------------------------------------

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

            Transmog.activeCharacterTemplates[slot] = item.RootTemplate.Id
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

    if Transmog.CanTransmogItem(item) and not Transmog.BLOCKED_TEMPLATES[template] then
        Net.PostToServer("EPIPENCOUNTERS_VanityTransmog", {
            Char = Client.GetCharacter().NetID,
            Item = item.NetID,
            NewTemplate = template,
            KeepIcon = Transmog.keepIcon;
        })
    
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
-- TAB FUNCTIONALITY
---------------------------------------------

function Tab:Render()
    -- Only clear template override if the item changed
    -- TODO revise
    -- if item ~= Vanity.currentItem then
    --     Vanity.currentItemTemplateOverride = nil
    -- end
    local item = Vanity.GetCurrentItem()

    Vanity.RenderItemDropdown()

    -- Unfortunately, TransformKeepIcon is not persistent - thus this option is not very useful.
    -- Vanity.RenderCheckbox("Vanity_KeepIcon", Text.Format("Keep Icon", {Color = Color.BLACK}), Transmog.keepIcon, true)

    -- Don't show the visibility option for helms,
    -- as they already have one in the vanilla UI.
    if Item.GetItemSlot(item) ~= "Helmet" then
        Vanity.RenderCheckbox("Vanity_MakeInvisible", Text.Format("Visible", {Color = Color.BLACK}), not item:HasTag(Transmog.INVISIBLE_TAG), true)
    end

    if item then
        local canTransmog = Transmog.CanTransmogItem(item)

        -- Can toggle weapon overlay effects regardless of whether the item can be transmogged.
        if Item.IsWeapon(item) then
            Vanity.RenderCheckbox("Vanity_OverlayEffects", Text.Format("Elemental Effects", {Color = Color.BLACK}), not item:HasTag("DISABLE_WEAPON_EFFECTS"), true)
        end

        if canTransmog then
            local categories = Transmog.GetCategories(item)

            -- TODO fix disabled button item:HasTag("PIP_Vanity_Transmogged")
            -- if item:HasTag("PIP_Vanity_Transmogged") or (Vanity.currentItemTemplateOverride and item.RootTemplate.Id ~= Vanity.currentItemTemplateOverride) then
            -- end

            Vanity.RenderCheckbox("Vanity_KeepAppearance", Text.Format("Lock Appearance", {Color = "000000"}), Transmog.ShouldKeepAppearance(item), true)

            Vanity.RenderButton("RevertTemplate", "Revert Appearance", true)

            for i,data in ipairs(categories) do
                -- Render category collapse button
                local categoryID = data.Data.ID
                local isOpen = Vanity.IsCategoryOpen(categoryID)
                Vanity.RenderEntry(categoryID, data.Data.Name, true, isOpen)

                if isOpen then
                    for _,templateData in ipairs(data.Templates) do
                        local icon = nil
                        local isEquipped = Vanity.IsTemplateEquipped(templateData.GUID)

                        if isEquipped then
                            icon = "hotbar_icon_charsheet"
                        end

                        Vanity.RenderEntry(templateData.GUID, templateData.Name, false, isEquipped, true, Transmog.favoritedTemplates[templateData.GUID], icon)
                    end
                end
            end
        else
            Vanity.RenderText("InvalidItem", "This item is too brittle to transmog.")
        end
    else
        Vanity.RenderText("NoItem", "You don't have an item equipped in that slot!")
    end
end

Tab:RegisterListener(Vanity.Events.EntryFavoriteToggled, function(id, active)
    if active then
        Transmog.favoritedTemplates[id] = active
    else
        Transmog.favoritedTemplates[id] = nil
    end

    Vanity.Refresh()
end)

Tab:RegisterListener(Vanity.Events.ButtonPressed, function(id)
    if id == "RevertTemplate" then
        Net.PostToServer("EPIPENCOUNTERS_Vanity_RevertTemplate", {
            CharNetID = Client.GetCharacter().NetID,
            ItemNetID = Vanity.GetCurrentItem().NetID,
        })
    end
end)

Tab:RegisterListener(Vanity.Events.CheckboxPressed, function(id, state)
    if id == "Vanity_KeepAppearance" then
        Net.PostToServer("EPIPENCOUNTERS_Vanity_Transmog_KeepAppearance", {
            NetID = Client.GetCharacter().NetID,
            Slot = Vanity.currentSlot,
            State = state,
        })
        
        Transmog.UpdateActiveCharacterTemplates()
    elseif id == "Vanity_KeepIcon" then
        Transmog.keepIcon = state
    elseif id == "Vanity_MakeInvisible" then
        Transmog.ToggleVisibility()
    elseif id == "Vanity_OverlayEffects" then
        Net.PostToServer("EPIPENCOUNTERS_Vanity_Transmog_ToggleWeaponOverlayEffects", {
            ItemNetID = Vanity.GetCurrentItem().NetID,
        })

        Timer.Start(0.4, function()
            Vanity.RefreshAppearance(true)
        end)
    end
end)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Make item visuals invisible if they were set to be.
Ext.Events.CreateEquipmentVisualsRequest:Subscribe(function(ev)
    ev = ev ---@type EclLuaCreateEquipmentVisualsRequestEvent
    local request = ev.Params
    local char = ev.Character
    local item

    if char then
        local itemGUID = char:GetItemBySlot(request.Slot)

        if itemGUID then
            item = Item.Get(itemGUID)
        end

        if item and item:IsTagged(Transmog.INVISIBLE_TAG) then
            request.VisualResourceID = ""
            request.EquipmentSlotMask = 0 -- Might be unnecessary?
            request.VisualSetSlotMask = 0
        end
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
                Epip.Features.VanityDyes.UpdateActiveCharacterDyes()
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

Transmog.Hooks.CanTransmog:RegisterHook(function (canTransmog, item)
    if Transmog.BLOCKED_TEMPLATES[item.RootTemplate.Id] then
        canTransmog = false
    end

    return canTransmog
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

Client.UI.ContextMenu.RegisterElementListener("epip_OpenVanity", "buttonPressed", function(item, params)
    Vanity.SetSlot(item)
    Vanity.Setup(Vanity.currentTab or Tab)
end)

Tab:RegisterListener(Vanity.Events.EntryClicked, function(id)
    Transmog.TransmogItem(nil, id)
end)

---------------------------------------------
-- HOTBAR ACTION
---------------------------------------------

Hotbar.RegisterAction("EpipVanity", {Name = "Vanity", Icon = Hotbar.ACTION_ICONS.HAT})
Hotbar.RegisterActionListener("EpipVanity", "ActionUsed", function(_)
    Vanity.SetSlot("Breast")
    Vanity.Setup(Tab)
end)
Hotbar.RegisterActionHook("EpipVanity", "IsActionEnabled", function(enabled, _, _, _)
    if enabled then
        enabled = not Client.IsInCombat()
    end
    return enabled
end)