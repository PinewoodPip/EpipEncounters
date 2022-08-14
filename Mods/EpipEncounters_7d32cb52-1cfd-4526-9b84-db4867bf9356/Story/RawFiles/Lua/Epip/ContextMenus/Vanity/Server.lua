
local Vanity = Epip.Features.Vanity
Vanity:Debug()

function Vanity.RevertAppearace(char, item)
    local _,originalTemplate = Osiris.DB_PIP_Vanity_OriginalTemplate:Get(item.MyGuid, nil)

    if originalTemplate then
        Vanity.TransmogItem(char, item, originalTemplate, nil, false)
        Osi.ClearTag(item.MyGuid, "PIP_Vanity_Transmogged")
        Osiris.DB_PIP_Vanity_OriginalTemplate:Delete(item.MyGuid, nil)

        Ext.OnNextTick(function()
            Ext.OnNextTick(function()
                Net.PostToUser(char.ReservedUserID, "EPIPENCOUNTERS_Vanity_SetTemplateOverride", {TemplateOverride = originalTemplate})
            end)
        end)
    end
end

function Vanity.TransmogItem(char, item, newTemplate, dye, keepIcon)
    -- TODO still try to dye if template is the same
    if not newTemplate or not item or item.RootTemplate.Id == newTemplate or newTemplate == "" then return nil end

    local _,originalTemplate = Osiris.DB_PIP_Vanity_OriginalTemplate:Get(item.MyGuid, nil)
    if not originalTemplate then
        Osiris.DB_PIP_Vanity_OriginalTemplate:Set(item.MyGuid, item.RootTemplate.Id)
        Vanity:DebugLog("Saved original template of " .. item.DisplayName .. ": " .. item.RootTemplate.Id)
        Osi.SetTag(item.MyGuid, "PIP_Vanity_Transmogged")
    end

    Vanity:Log("Transforming item " .. item.DisplayName .. " to " .. newTemplate)

    local template = Ext.Template.GetTemplate(newTemplate)
    local _, _, _, artifactName = Osiris.DB_AMER_Artifacts:Get(template.Name .. "_" .. template.Id, nil, nil, nil)
    local oldTemplate = item.RootTemplate
    if originalTemplate then oldTemplate = Ext.Template.GetTemplate(originalTemplate) end

    local _, _, _, oldArtifactName = Osiris.DB_AMER_Artifacts:Get(oldTemplate.Name .. "_" .. oldTemplate.Id, nil, nil, nil)

    Osi.PROC_AMER_GEN_ObjectTransforming(item.RootTemplate.Name .. "_" .. item.MyGuid, template.Name .. "_" .. template.Id)

    if keepIcon then
        Osi.TransformKeepIcon(item.MyGuid, newTemplate, 0, 1, 0)
    else
        Osi.Transform(item.MyGuid, newTemplate, 0, 1, 0)
    end

    -- Apply new dye if specified.
    if dye then
        Item.ApplyDye(item, dye)
    end

    -- Remove tag when going from normal item to artifact (not if going from artifact to artifact)
    if artifactName and not oldArtifactName then
        -- Osi.ClearTag(item.MyGuid, "AMER_UNI") -- Does not work.
        Osi.SetTag(item.MyGuid, "PIP_FAKE_ARTIFACT")
    end
    
    Vanity.RefreshAppearance(char, false)
end

function Vanity.GetTemplateInSlot(char, slot)
    local item = Osi.CharacterGetEquippedItem(char.MyGuid, slot)
    local template = ""

    if item then
        template = Ext.GetItem(item).RootTemplate.Id
    end

    return template
end

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
    for i,slot in ipairs(slots) do
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

---Apply a Polymorph status to refresh visuals without needing to re-equip. Credits to Luxen for the discovery!
---@param char EsvCharacter
---@param useAlternativeStatus boolean
function Vanity.RefreshAppearance(char, useAlternativeStatus)
    local status = "PIP_Vanity_Refresh"
    local guid = char.MyGuid
    if useAlternativeStatus then status = "PIP_Vanity_Refresh_Alt" end

    Osi.ApplyStatus(guid, status, 0, 1, NULLGUID)

    Timer.Start(0.2, function()
        Net.PostToCharacter(guid, "EPIPENCOUNTERS_Vanity_RefreshSheetAppearance")
    end)
end

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
        for i,slot in ipairs(slots) do
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

---------------------------------------------
-- LISTENERS
---------------------------------------------

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

Osiris.RegisterSymbolListener("ItemEquipped", 2, "after", function(item, char)
    if Osiris.DB_IsPlayer:Get(char) then
        char = Ext.GetCharacter(char)
    
        Net.PostToCharacter(char.MyGuid, "EPIPENCOUNTERS_ItemEquipped", {
            NetID = char.NetID,
            ItemNetID = Ext.GetItem(item).NetID,
        })
    end
end)

Net.RegisterListener("EPIPENCOUNTERS_Vanity_Transmog_KeepAppearance", function(payload)
    local char = Ext.GetCharacter(payload.NetID)
    local tag = "PIP_Vanity_Transmog_KeepAppearance_" .. payload.Slot

    if payload.State then
        Osi.SetTag(char.MyGuid, tag)
    else
        Osi.ClearTag(char.MyGuid, tag)
    end
end)

Net.RegisterListener("EPIPENCOUNTERS_Vanity_RefreshAppearance", function (payload)
    local char = Character.Get(payload.CharacterNetID)

    Vanity.RefreshAppearance(char, payload.UseAltStatus)
end)

Net.RegisterListener("EPIPENCOUNTERS_Vanity_Transmog_ToggleWeaponOverlayEffects", function(payload)
    local item = Item.Get(payload.ItemNetID)
    local hasTag = item:HasTag("DISABLE_WEAPON_EFFECTS")

    if hasTag then
        Osi.ClearTag(item.MyGuid, "DISABLE_WEAPON_EFFECTS")
    else
        Osi.SetTag(item.MyGuid, "DISABLE_WEAPON_EFFECTS")
    end
end)

-- Transmog request.
Net.RegisterListener("EPIPENCOUNTERS_VanityTransmog", function(payload)
    local char = Ext.GetCharacter(payload.Char)
    local item = Ext.GetItem(payload.Item)
    local template = payload.NewTemplate
    local keepIcon = payload.KeepIcon == true

    Vanity.TransmogItem(char, item, template, nil, keepIcon)
end)

-- TODO MOVE ELSEWHERE
Net.RegisterListener("EPIPENCOUNTERS_Vanity_ApplyAura", function(payload)
    local char = Ext.GetCharacter(payload.NetID)
    local aura = payload.Aura ---@type VanityAura

    Osi.PROC_LoopEffect(aura.Effect, char.MyGuid, "PIP_VanityAura", "__ANY__", "")
    -- local handle = Osiris.DB_PlayLoopEffectHandleResult:Get(nil)
    local _, handle = Osiris.DB_LoopEffect:Get(char.MyGuid, nil, "PIP_VanityAura", "__ANY__", aura.Effect, nil)


    print("Handle:", handle)

    Osi.DB_PIP_Vanity_AppliedAura(char.MyGuid, aura.Effect, handle)
    _D(Osi.DB_PIP_Vanity_AppliedAura:Get(char.MyGuid, aura.Effect, nil))

    
    -- Osiris.DB_PIP_Vanity_AppliedAura:Set(char.MyGuid, aura.Effect, handle)
end)
Net.RegisterListener("EPIPENCOUNTERS_Vanity_RemoveAura", function(payload)
    local char = Ext.GetCharacter(payload.NetID)
    local _, _, _, tuples = Osiris.DB_PIP_Vanity_AppliedAura:Get(char.MyGuid, nil, nil)

    if tuples then
        for i,tuple in ipairs(tuples) do
            local handle = tuple[3]
            print("Stopping effect:", handle)
            Osi.ProcStopLoopEffect(handle)
        end
    end

    Osiris.DB_PIP_Vanity_AppliedAura:Delete(char.MyGuid, nil, nil)
end)

-- Revert appearance.
Net.RegisterListener("EPIPENCOUNTERS_Vanity_RevertTemplate", function(payload)
    local char = Ext.GetCharacter(payload.CharNetID)
    local item = Ext.GetItem(payload.ItemNetID)

    Vanity.RevertAppearace(char, item)
end)

-- Toggling persistent outfit feature.
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

-- TODO better handling - this can break with multiple people equipping stuff at once
Utilities.Hooks.RegisterListener("ContextMenus_Dyes", "ItemBeingDyed", function(item)
    Vanity.ignoreItemEquips = true
end)

Ext.Events.SessionLoaded:Subscribe(function (ev)
    local stat, stat2 = Stats.Get("StatusData", "PIP_Vanity_Refresh"), Stats.Get("StatusData", "PIP_Vanity_Refresh_Alt")
    if not stat then
        stat = Ext.Stats.Create("PIP_Vanity_Refresh", "StatusData")
    end
    if not stat2 then
        stat2 = Ext.Stats.Create("PIP_Vanity_Refresh_Alt", "StatusData")
    end
    
    stat.StatusType = "POLYMORPHED"
    stat2.StatusType = "POLYMORPHED"
    stat.PolymorphResult = ""
    stat2.PolymorphResult = "820f165e-62f5-4de4-a739-6274cfac1c8e" -- Used for dyes. Causes flickering but is necessary for the item color to update.
    stat.DisableInteractions = "No"
    stat2.DisableInteractions = "No"

    if Ext.IsServer() then
        Ext.Stats.Sync("PIP_Vanity_Refresh", false)
        Ext.Stats.Sync("PIP_Vanity_Refresh_Alt", false)
    end
end)