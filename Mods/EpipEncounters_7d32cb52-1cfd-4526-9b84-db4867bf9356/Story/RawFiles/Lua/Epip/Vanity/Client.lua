
---@class Feature_Vanity
local Vanity = Epip.GetFeature("Feature_Vanity")
local ContextMenu = Client.UI.ContextMenu

Vanity.Outfits = {}

-- Request to transform an item into a template.
function Vanity.TransmogItem(item, newTemplate)
    Net.PostToServer("EPIPENCOUNTERS_VanityTransmog", {
        Char = Client.GetCharacter().NetID,
        Item = item.NetID,
        NewTemplate = newTemplate,
    })
end

---Requests an item to be reverted its original state, discarding all Vanity features applied to it.
---Will notify the server.
---@param char EclCharacter
---@param item EclItem
function Vanity.RevertAppearance(char, item)
    Net.PostToServer(Vanity.NETMSG_REVERT_APPEARANCE, {
        CharacterNetID = char.NetID,
        ItemNetID = item.NetID,
    })
    Vanity._RevertAppearance(char, item)
end

---Reverts an item to its original state, discarding all Vanity features applied to it.
---@param char EclCharacter
---@param item EclItem
function Vanity._RevertAppearance(char, item)
    Vanity.Events.ItemAppearanceReset:Throw({
        Character = char,
        Item = item,
    })
end

function Vanity.GenerateContextMenuElement(guid, templateData)
    return {
        type = "button",
        id = "epip_VanityTransmog_" .. guid,
        eventIDOverride = "epip_VanityTransmog",
        text = templateData.Name,
        params = {
            Template = guid,
        },
    }
end

-- Render templates of the same slot as the item being transmog'd
-- if they belong to the category.
-- Items with "None" slot (which do not hide any armor visual handled by game) can render on any item, except breastplates, so as not to bloat their menu.
Vanity:RegisterHook("ShouldRenderContextMenuEntry", function(bool, _, _, data, category, itemSlot, _)
    local char = Client.GetCharacter()

    if not bool and Vanity.BelongsToCategory(data, category) and (itemSlot == data.Slot or data.Slot == "None") then
        local gender = Game.Character.GetGender(char)
        local race = Game.Character.GetRace(char)

        -- Chestplate doesn't show non-chest items - sorry, too much stuff.
        return ((data.Tags[gender] and data.Tags[race]) or (itemSlot == "Weapon" and data.Slot == "Weapon")) and (itemSlot == data.Slot or (itemSlot ~= "Breast" and itemSlot ~= "Weapon"))
    end

    return bool
end)

-- Generate context menu entries for templates of a slot,
-- out of the templates unlocked.
function Vanity.GenerateContextMenuElements(item, category)
    category = Vanity.CATEGORIES[category]
    local entries = {}
    local itemSlot = Item.GetItemSlot(item)

    if itemSlot == "Shield" then
        itemSlot = "Weapon"
    end

    local itemSubtype = Item.GetEquipmentSubtype(item)

    for guid,data in pairs(Vanity.TEMPLATES) do
        local shouldRender = Vanity:ReturnFromHooks("ShouldRenderContextMenuEntry", false, item, guid, data, category, itemSlot, itemSubtype)

        if shouldRender then
            table.insert(entries, Vanity.GenerateContextMenuElement(guid, data))
        end
    end

    return entries
end

function Vanity.GenerateContextMenuCategories(item, slot)
    local entries = {}

    for _,id in pairs(Vanity.CATEGORY_ORDER) do
        local category = Vanity.CATEGORIES[id]

        -- Some categories have slot restrictions
        -- TODO have a more optimal way of checking if category is not empty
        if ((not category.Slots) or category.Slots[slot]) and #Vanity.GenerateContextMenuElements(item, id) > 0 then
            table.insert(entries, 
                {id = "epip_VanitySubMenu_" .. id, type = "subMenu", text = category.Name .. "...", subMenu = "epip_VanityMenu_Entries_" .. id,
            })
        end
    end

    return entries
end

function Vanity.BelongsToCategory(templateData, category)
    local matchingTagsCount = 0
    local categoryTagCount = table.getKeyCount(category.Tags)

    for tag,_ in pairs(category.Tags) do
        if templateData.Tags[tag] then
            matchingTagsCount = matchingTagsCount + 1

            -- Return true if the category doesnt need all tags to match
            -- or if all tags matched
            if not category.RequireAllTags or matchingTagsCount == categoryTagCount then
                return true
            end
        end
    end
    return false
end

-- Synch unlocks with other players
-- function Vanity.SendUnlocks()
--     Net.PostToServer("EPIPENCOUNTERS_VanitySynchUnlocks")
-- end

---------------------------------------------
-- LISTENERS
---------------------------------------------


---------------------------------------------
-- OUTFITS
---------------------------------------------


-- "Transmog..." submenu handler - pulls up the category selection menu.
ContextMenu.RegisterMenuHandler("epip_VanityMenu", function()
    local item = ContextMenu.item

    -- Categories
    local slot = Item.GetItemSlot(item)

    -- We cannot tell the difference between shield and weapon roots.
    if slot == "Shield" then
        slot = "Weapon"
    end

    local entries = Vanity.GenerateContextMenuCategories(item, slot)

    -- Outfits submenu
    table.insert(entries, {
        id = "epip_VanityMenu_OutfitsSubMenu",
        type = "subMenu",
        subMenu = "epip_menu_Vanity_Outfits",
        text = "Outfits...",
    })

    -- Persist checkbox
    -- table.insert(entries, {id = "epip_VanityMenu_PersistOutfit", type = "checkbox", text = "Auto-transmog Armor", checked = Client.GetCharacter():HasTag(Vanity.PERSISTENT_OUTFIT_TAG), netMsg = "EPIPENCOUNTERS_VanityPersistOutfit"})

    -- Separate persist checkbox for weapon and offhand
    -- table.insert(entries, {id = "epip_VanityMenu_PersistWeaponry", type = "checkbox", text = "Auto-transmog Weaponry", checked = Client.GetCharacter():HasTag(Vanity.PERSISTENT_WEAPONRY_TAG), netMsg = "EPIPENCOUNTERS_VanityPersistWeaponry"})

    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_VanityMenu",
            entries = entries,
        }
    })
end)

-- Outfits menu handler - shows saved outfits.
ContextMenu.RegisterMenuHandler("epip_menu_Vanity_Outfits", function()

    local entries = {}

    for id,outfit in pairs(Vanity.Outfits) do
        table.insert(entries, {
            id = "epip_Vanity_outfit_" .. id,
            type = "removable",
            text = outfit.Name,
            eventIDOverride = "epip_Vanity_Outfit",
            params = {
                Outfit = outfit,
                ID = id,
            }
        })
    end

    -- Save outfit button.
    table.insert(entries, {
        id = "epip_Vanity_Outfit_Save",
        type = "button",
        text = "Save Outfit",
    })

    ContextMenu.AddSubMenu({
        menu = {
            id = "epip_menu_Vanity_Outfits",
            entries = entries,
        }
    })
end)

function Vanity.RegisterCategoryMenuHandler(id)
    ContextMenu.RegisterMenuHandler("epip_VanityMenu_Entries_" .. id, function(entity, elementData)
        local item = ContextMenu.item
        local category = id
    
        ContextMenu.AddSubMenu({
            menu = {
                id = "epip_VanityMenu_Entries_" .. category, -- has to be the same as the submenu being requested from the element being hovered (or at least, there has to be ONE menu with that id)
                entries = Vanity.GenerateContextMenuElements(item, category),
            }
        })
    end)
end

-- Handler for category submenus - pulls up a new subcontext menu with
-- the category's available templates.
for id,data in pairs(Vanity.CATEGORIES) do
    Vanity.RegisterCategoryMenuHandler(id)
end

ContextMenu.RegisterElementListener("epip_VanityTransmog", "buttonPressed", function(item, params)
    Vanity.TransmogItem(item, params.Template)
end)

-- Handle requests from the server to revert item appearance.
Net.RegisterListener(Vanity.NETMSG_REVERT_APPEARANCE, function (payload)
    local char, item = payload:GetCharacter(), payload:GetItem()
    Vanity._RevertAppearance(char, item) -- Do not send a message back to the server.
end)
