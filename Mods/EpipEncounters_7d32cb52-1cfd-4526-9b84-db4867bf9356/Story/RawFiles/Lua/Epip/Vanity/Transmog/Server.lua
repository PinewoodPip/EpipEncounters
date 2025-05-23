
---@class Feature_Vanity
local Vanity = Epip.GetFeature("Feature_Vanity")
local Transmog = Epip.GetFeature("Feature_Vanity_Transmog")

---------------------------------------------
-- METHODS
---------------------------------------------

-- TODO move to Item
function Vanity.GetTemplateInSlot(char, slot)
    local item = Osi.CharacterGetEquippedItem(char.MyGuid, slot)
    local template = ""

    if item then
        template = Ext.GetItem(item).RootTemplate.Id
    end

    return template
end

---Sets a weapon animation override for char.
---@param char EsvCharacter
---@param animType CharacterLib.WeaponAnimationType Set to `NONE` to remove an override.
function Transmog.SetWeaponAnimationOverride(char, animType)
    Entity.RemoveTagsByPattern(char, Transmog.WEAPON_ANIMATION_OVERRIDE_TAG_PATTERN) -- Remove previous override.
    if animType ~= Character.WEAPON_ANIMATION_TYPES.NONE then
        Osiris.SetTag(char, string.format(Transmog.WEAPON_ANIMATION_OVERRIDE_TAG, animType))
    end
    Transmog:DebugLog("Set weapon animation override", char.DisplayName, table.reverseLookup(Character.WEAPON_ANIMATION_TYPES, animType))
end

---Transmogrifies an item into another template.
---@param char EsvCharacter
---@param item EsvItem
---@param newTemplate GUID
---@param dye any? TODO remove
---@param keepIcon boolean?
function Vanity.TransmogItem(char, item, newTemplate, dye, keepIcon)
    -- TODO still try to dye if template is the same
    if not newTemplate or not item or item.RootTemplate.Id == newTemplate or newTemplate == "" then return nil end

    local _, originalTemplate = Osiris.DB_PIP_Vanity_OriginalTemplate:Get(item.MyGuid, nil)
    if not originalTemplate then
        Osiris.DB_PIP_Vanity_OriginalTemplate:Set(item.MyGuid, item.RootTemplate.Id)
        Vanity:DebugLog("Saved original template of " .. item.DisplayName .. ": " .. item.RootTemplate.Id)
        Osi.SetTag(item.MyGuid, "PIP_Vanity_Transmogged")
    end

    Vanity:DebugLog("Transmogging item", item.DisplayName, "to", newTemplate)

    local template = Ext.Template.GetTemplate(newTemplate) ---@cast template ItemTemplate

    if keepIcon then
        local icon = Transmog.GetIconOverride(item)
        if icon then
            Transmog.SetItemIcon(item, icon)
        end
    else
        local icon = template.Icon

        -- Still need to set an icon override in this case
        -- as we are not transforming the item.
        Transmog.SetItemIcon(item, icon)
    end

    -- Apply new dye if specified.
    if dye then
        Item.ApplyDye(item, dye)
    end

    -- Update parameter tag
    Entity.RemoveTagsByPattern(item, Transmog.TRANSMOGGED_TAG_PATTERN)
    Osiris.SetTag(item, Transmog.TRANSMOGGED_TAG:format(newTemplate))

    -- Request to update visuals.
    -- Doing this a second time is necessary to avoid jank with the Head visual mask.
    Vanity.RefreshAppearance(char, true)
    local charHandle = char.Handle
    Timer.Start(0.05, function (_)
        Vanity.RefreshAppearance(Character.Get(charHandle), true)
    end)
end

---Sets a persistent icon override for an item.
---@param item EsvItem
---@param icon icon Use empty string to clear the override.
function Transmog.SetItemIcon(item, icon)
    Entity.RemoveTagsByPattern(item, Transmog.KEEP_ICON_PATTERN)
    if icon ~= "" then -- No need to add a tag if we're removing the icon override.
        Osiris.SetTag(item, Transmog.KEEP_ICON_TAG:format(icon))
    end
end

---Reverts the appearance of an item to its original one.
---@param char EsvCharacter
---@param item EsvItem
function Transmog.RevertAppearance(char, item)
    local _,originalTemplate = Osiris.DB_PIP_Vanity_OriginalTemplate:Get(item.MyGuid, nil)
    if originalTemplate then
        local itemHandle = item.Handle
        local charHandle = char.Handle
        local charUserID = char.ReservedUserID

        Osi.ClearTag(item.MyGuid, "PIP_Vanity_Transmogged")
        Osiris.DB_PIP_Vanity_OriginalTemplate:Delete(item.MyGuid, nil)

        Entity.RemoveTagsByPattern(item, Transmog.TRANSMOGGED_TAG_PATTERN)

        Ext.OnNextTick(function()
            Ext.OnNextTick(function()
                char, item = Character.Get(charHandle), Item.Get(itemHandle)
                Net.PostToUser(charUserID, "EPIPENCOUNTERS_Vanity_SetTemplateOverride", {TemplateOverride = originalTemplate})

                Net.Broadcast(Transmog.NET_MSG_ICON_REMOVED, {
                    ItemNetID = item.NetID,
                })

                if Item.IsEquipped(char, item) then
                    Vanity.TryRefreshAppearance(char, item, true)
                end
            end)
        end)
    end
    Entity.RemoveTagsByPattern(item, Transmog.KEEP_ICON_PATTERN)
end

---Sets the persistent outfit for a character to its current templates.
---@param char EsvCharacter
---@param slots ItemSlot[]
---@param tag string
function Vanity.SetPersistentOutfit(char, slots, tag)
    Vanity:DebugLog("Persistent outfit set: " .. char.DisplayName)

    local db = Osi.DB_PIP_Vanity_PersistentOutfit:Get(char.MyGuid, nil, nil, nil, nil, nil, nil, nil)
    local currentPersistentOutfit = {
        char.MyGuid,
        "",
        "",
        "",
        "",
        "",
        "",
        "",
    }
    if #db == 1 then
        currentPersistentOutfit = db[1]
    end

    -- Update only the requested slots.
    for _,slot in ipairs(slots) do
        local index = Vanity.SLOT_TO_DB_INDEX[slot] + 1
        currentPersistentOutfit[index] = Vanity.GetTemplateInSlot(char, slot)
    end

    Osi.SetTag(char.MyGuid, tag)
    Osi.DB_PIP_Vanity_PersistentOutfit:Delete(char.MyGuid, nil, nil, nil, nil, nil, nil, nil)
    Osi.DB_PIP_Vanity_PersistentOutfit(
        currentPersistentOutfit[1],
        currentPersistentOutfit[2],
        currentPersistentOutfit[3],
        currentPersistentOutfit[4],
        currentPersistentOutfit[5],
        currentPersistentOutfit[6],
        currentPersistentOutfit[7],
        currentPersistentOutfit[8]
    )
end

---Removes a persistent outfit from a character.
function Vanity.ClearPersistentOutfit(char, slots, tag)
    Vanity:DebugLog("Persistent outfit cleared: " .. char.DisplayName)

    local db = Osi.DB_PIP_Vanity_PersistentOutfit:Get(char.MyGuid, nil, nil, nil, nil, nil, nil, nil)
    local currentPersistentOutfit = {
        char.MyGuid,
        "",
        "",
        "",
        "",
        "",
        "",
        "",
    }
    if #db == 1 then
        currentPersistentOutfit = db[1]

        -- Clear requested slots.
        for _,slot in ipairs(slots) do
            local index = Vanity.SLOT_TO_DB_INDEX[slot] + 1
            currentPersistentOutfit[index] = ""
        end

        Osi.DB_PIP_Vanity_PersistentOutfit:Delete(char.MyGuid, nil, nil, nil, nil, nil, nil, nil)
        Osi.DB_PIP_Vanity_PersistentOutfit(
            currentPersistentOutfit[1],
            currentPersistentOutfit[2],
            currentPersistentOutfit[3],
            currentPersistentOutfit[4],
            currentPersistentOutfit[5],
            currentPersistentOutfit[6],
            currentPersistentOutfit[7],
            currentPersistentOutfit[8]
        )
    end

    Osi.ClearTag(char.MyGuid, tag)
end

---Sets whether a helmet should always show hair (ie. never mask it).
---@param item EsvItem Should be a helmet.
---@param forceShow boolean
function Transmog.SetForceShowHair(item, forceShow)
    if forceShow then
        Osi.SetTag(item.MyGuid, Transmog.FORCE_SHOW_HAIR_TAG)
    else
        Osi.ClearTag(item.MyGuid, Transmog.FORCE_SHOW_HAIR_TAG)
    end
end

---Refreshes the equipment visuals of a character.
---If the extender fork is not installed, this is done by applying a Polymorph status. Credits to Luxen for the discovery!
---@param char EsvCharacter
---@param useAlternativeStatus boolean?
---@param useStatus boolean? -- Defaults to `false`. If `true`, a polymorph status will be used to refresh the visuals.
function Vanity.RefreshAppearance(char, useAlternativeStatus, useStatus) -- TODO move
    local charGUID, charNetID = char.MyGuid, char.NetID

    -- Use polymorph status to refresh visuals for legacy v60 versions where RefreshEquipmentVisuals() was not available. That function is client-only, so we need to check for a different one to determine the extender build.
    if Ext.IO.IsFile == nil or useStatus then
        local status = useAlternativeStatus and "PIP_Vanity_Refresh_Alt" or "PIP_Vanity_Refresh"
        Osi.ApplyStatus(charGUID, status, 0, 1, NULLGUID)
    end

    -- Request to update visuals.
    Timer.Start(0.2, function()
        Net.PostToCharacter(charGUID, "EPIPENCOUNTERS_Vanity_RefreshSheetAppearance")
    end)
    Timer.StartTickTimer(2, function ()
        Net.Broadcast(Vanity.NETMSG_REFRESH_VISUALS, {
            CharacterNetID = charNetID,
        })
    end)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for transmog requests.
Net.RegisterListener("EPIPENCOUNTERS_VanityTransmog", function(payload)
    local char = Ext.GetCharacter(payload.Char)
    local item = Ext.GetItem(payload.Item)
    local template = payload.NewTemplate
    local keepIcon = payload.KeepIcon == true

    Vanity.TransmogItem(char, item, template, nil, keepIcon)
end)

-- Listen for equip swaps, apply new visuals.
Ext.Osiris.RegisterListener("ItemEquipped", 2, "after", function(item, char)
    local outfit = Osi.DB_PIP_Vanity_PersistentOutfit:Get(char, nil, nil, nil, nil, nil, nil, nil)[1]

    if outfit and not Vanity.ignoreItemEquips then
        item = Ext.GetItem(item)
        Vanity:DebugLog("Transmogging equipped item to persistent outfit: " .. item.DisplayName)

        local slot = Item.GetItemSlot(item)

        Vanity.TransmogItem(Ext.GetCharacter(char), item, outfit[1 + Vanity.SLOT_TO_DB_INDEX[slot]])
    end
end)

-- Refresh visuals when an item is unequipped.
-- Necessary to handle the case of unequipping an item that the engine would've masked -
-- doing so will not cause the body visuals of that region to be updated otherwise.
Osiris.RegisterSymbolListener("ItemUnequipped", 2, "after", function (itemGUID, charGUID)
    if not Osi.ObjectExists(charGUID) then return end
    local char = Character.Get(charGUID)
    if char and Character.IsPlayer(char) then
        Vanity.TryRefreshAppearance(char, Item.Get(itemGUID), true)
    end
end)

-- Listen for "keep appearance" being toggled for a character's item slot.
Net.RegisterListener("EPIPENCOUNTERS_Vanity_Transmog_KeepAppearance", function(payload)
    local char = Ext.GetCharacter(payload.NetID)
    local tag = "PIP_Vanity_Transmog_KeepAppearance_" .. payload.Slot

    if payload.State then
        Osi.SetTag(char.MyGuid, tag)
    else
        Osi.ClearTag(char.MyGuid, tag)
    end
end)

-- Listen for requests to revert item appearance.
Net.RegisterListener(Transmog.NET_MSG_REVERT_APPEARANCE, function(payload)
    local char, item = payload:GetCharacter(), payload:GetItem()
    Transmog.RevertAppearance(char, item)
end)

-- Listen for requests to set an icon override (separate from transmog).
Net.RegisterListener(Transmog.NET_MSG_SET_ICON, function(payload)
    local char, item = payload:GetCharacter(), payload:GetItem()

    Transmog.SetItemIcon(item, payload.Icon)
    Vanity.TryRefreshAppearance(char, item, true)
end)

-- Listen for toggling persistent outfit feature.
Net.RegisterListener("EPIPENCOUNTERS_VanityPersistOutfit", function(payload)
    local char = Ext.GetCharacter(payload.ClientCharacterNetID)
    local enable = payload.State

    local slots = {"Helmet", "Breast", "Gloves", "Leggings", "Boots"}
    if enable then
        Vanity.SetPersistentOutfit(char, slots, Vanity.PERSISTENT_OUTFIT_TAG)
    else
        Vanity.ClearPersistentOutfit(char, slots, Vanity.PERSISTENT_OUTFIT_TAG)
    end
end)

-- Toggling persistent outfit feature, for weapons
Net.RegisterListener("EPIPENCOUNTERS_VanityPersistWeaponry", function(payload)
    local char = Ext.GetCharacter(payload.ClientCharacterNetID)
    local enable = payload.State

    local slots = {"Weapon", "Shield"}
    if enable then
        Vanity.SetPersistentOutfit(char, slots, Vanity.PERSISTENT_WEAPONRY_TAG)
    else
        Vanity.ClearPersistentOutfit(char, slots, Vanity.PERSISTENT_WEAPONRY_TAG)
    end
end)

-- Listen for requests to disable elemental damage visual effects.
Net.RegisterListener("EPIPENCOUNTERS_Vanity_Transmog_ToggleWeaponOverlayEffects", function(payload)
    local item = Item.Get(payload.ItemNetID)
    local hasTag = item:HasTag("DISABLE_WEAPON_EFFECTS")

    if hasTag then
        Osi.ClearTag(item.MyGuid, "DISABLE_WEAPON_EFFECTS")
    else
        Osi.SetTag(item.MyGuid, "DISABLE_WEAPON_EFFECTS")
    end
end)

-- Listen for equipment visibility being toggled.
Net.RegisterListener("EPIPENCOUNTERS_Vanity_Transmog_ToggleVisibility", function (payload)
    local item = Item.Get(payload.ItemNetID)
    local char = Character.Get(payload.CharacterNetID)

    if payload.State then
        Osiris.ClearTag(item, "PIP_VANITY_INVISIBLE")
    else
        Osiris.SetTag(item, "PIP_VANITY_INVISIBLE")
    end

    -- Refresh visuals using the polymorph status.
    -- RefreshVisuals() does not work for this; it appears there may be additional equipment visual system flags we cannot set to cause body parts to update properly.
    Vanity.RefreshAppearance(char, true, true)
end)

-- Handle requests for toggling hair masking for helmets.
Net.RegisterListener(Transmog.NETMSG_SET_FORCE_SHOW_HAIR, function (payload)
    local item = payload:GetItem()
    Transmog.SetForceShowHair(item, payload.ShowHair)
end)

-- Listen for requests to refresh visuals.
Net.RegisterListener("EPIPENCOUNTERS_Vanity_RefreshAppearance", function (payload)
    local char = Character.Get(payload.CharacterNetID)

    Vanity.RefreshAppearance(char, payload.UseAltStatus)
end)

-- Handle requests to set weapon animation overrides.
Net.RegisterListener(Transmog.NETMSG_SET_WEAPON_ANIMATION_OVERRIDE, function (payload)
    local char = payload:GetCharacter()
    Transmog.SetWeaponAnimationOverride(char, payload.AnimType)
    -- Update the animation and unsheathe to preview it
    Osiris.CharacterSetFightMode(char, false, true) -- Toggle is necessary in case character was already unsheathed.
    Osiris.CharacterSetFightMode(char, true, true)
end)

-- TODO better handling - this can break with multiple people equipping stuff at once
Utilities.Hooks.RegisterListener("ContextMenus_Dyes", "ItemBeingDyed", function(item)
    Vanity.ignoreItemEquips = true
end)

-- Create statuses for refreshing visuals.
Ext.Events.SessionLoaded:Subscribe(function (ev)
    local stat, stat2 = Stats.Get("StatusData", "PIP_Vanity_Refresh"), Stats.Get("StatusData", "PIP_Vanity_Refresh_Alt")
    if not stat then
        stat = Ext.Stats.Create("PIP_Vanity_Refresh", "StatusData")
    end
    if not stat2 then
        stat2 = Ext.Stats.Create("PIP_Vanity_Refresh_Alt", "StatusData")
    end

    -- Gather all racial skills to preserve them during the polymorph.
    -- Otherwise refreshing visuals this way would remove them temporarily, resetting their cooldown (and possibly also hotbar position) upon transforming back.
    -- Previous approach restored skill cooldowns after refreshing, however this caused visual flickers on the hotbar.
    local races = Ext.Stats.GetCharacterCreation().RacePresets
    local racialSkills = {} ---@type skill[]
    for _,race in ipairs(races) do
        local skillSet = Ext.Stats.SkillSet.GetLegacy(race.SkillSet)
        if skillSet then
            for _,skillID in ipairs(skillSet.Skills) do
                table.insert(racialSkills, skillID)
            end
        end
    end

    stat.StatusType = "POLYMORPHED"
    stat2.StatusType = "POLYMORPHED"
    stat.PolymorphResult = ""
    stat2.PolymorphResult = "820f165e-62f5-4de4-a739-6274cfac1c8e" -- Used for dyes. Causes flickering but is necessary for the item color to update.
    stat.DisableInteractions = "No"
    stat2.DisableInteractions = "No"
    stat2.RetainSkills = Text.Join(racialSkills, ";")

    if Ext.IsServer() then -- TODO redundant?
        Ext.Stats.Sync("PIP_Vanity_Refresh", false)
        Ext.Stats.Sync("PIP_Vanity_Refresh_Alt", false)
    end
end)

-- Clear transmog when appearance is reset.
Vanity.Events.ItemAppearanceReset:Subscribe(function (ev)
    Transmog.RevertAppearance(ev.Character, ev.Item)
end)
