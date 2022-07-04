
local Vanity = Epip.Features.Vanity
Vanity:Debug()

function Vanity.RevertAppearace(char, item)
    local _,originalTemplate = Osiris.DB_PIP_Vanity_OriginalTemplate:Get(item.MyGuid, nil)

    if originalTemplate then
        Vanity.TransmogItem(char, item, originalTemplate)
        Osi.ClearTag(item.MyGuid, "PIP_Vanity_Transmogged")
        Osiris.DB_PIP_Vanity_OriginalTemplate:Delete(item.MyGuid, nil)

        Ext.OnNextTick(function()
            Ext.OnNextTick(function()
                Game.Net.PostToUser(char.ReservedUserID, "EPIPENCOUNTERS_Vanity_SetTemplateOverride", {TemplateOverride = originalTemplate})
            end)
        end)
    end
end

function Vanity.TransmogItem(char, item, newTemplate, dye)
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
    Osi.Transform(item.MyGuid, newTemplate, 0, 1, 0)

    -- Re-equip if necessary
    Osi.QRY_AMER_GEN_GetEquippedItemSlot(char.MyGuid, item.MyGuid)

    -- Apply new dye if specified.
    if dye then
        Game.Items.ApplyDye(item, dye)
    end

    -- Remove tag when going from normal item to artifact (not if going from artifact to artifact)
    if artifactName and not oldArtifactName then
        -- Osi.ClearTag(item.MyGuid, "AMER_UNI") -- Does not work.
        Osi.SetTag(item.MyGuid, "PIP_FAKE_ARTIFACT")
    end
    
    -- TODO add this check to the proc instead
    if Osi.DB_AMER_GEN_OUTPUT_String:Get(nil)[1][1] ~= "None" then
        Osi.PROC_PIP_ReEquipItem(char.MyGuid, item.MyGuid)
    end
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

        local slot = Game.Items.GetItemSlot(item)

        Vanity.TransmogItem(Ext.GetCharacter(char), item, outfit[1 + Vanity.SLOT_TO_DB_INDEX[slot]])
    end
end)

Osiris.RegisterSymbolListener("ItemEquipped", 2, "after", function(item, char)
    if Osiris.DB_IsPlayer:Get(char) then
        char = Ext.GetCharacter(char)
    
        Game.Net.PostToCharacter(char.MyGuid, "EPIPENCOUNTERS_ItemEquipped", {
            NetID = char.NetID,
            ItemNetID = Ext.GetItem(item).NetID,
        })
    end
end)

Game.Net.RegisterListener("EPIPENCOUNTERS_Vanity_Transmog_KeepAppearance", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)
    local tag = "PIP_Vanity_Transmog_KeepAppearance_" .. payload.Slot

    if payload.State then
        Osi.SetTag(char.MyGuid, tag)
    else
        Osi.ClearTag(char.MyGuid, tag)
    end
end)

-- TODO finish persistent outfit - there is an infinite loop issue with re-equipping.
function StopIgnoreVanity()
    Ext.Print("here")
    Vanity.ignoreItemEquips = false
end

function IgnoreVanity()
    Ext.Print("here2")
    Vanity.ignoreItemEquips = true
end

-- Transmog request.
Game.Net.RegisterListener("EPIPENCOUNTERS_VanityTransmog", function(cmd, payload)
    local char = Ext.GetCharacter(payload.Char)
    local item = Ext.GetItem(payload.Item)
    local template = payload.NewTemplate

    Vanity.TransmogItem(char, item, template)
end)

-- TODO MOVE ELSEWHERE
Game.Net.RegisterListener("EPIPENCOUNTERS_Vanity_ApplyAura", function(cmd, payload)
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
Game.Net.RegisterListener("EPIPENCOUNTERS_Vanity_RemoveAura", function(cmd, payload)
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
Game.Net.RegisterListener("EPIPENCOUNTERS_Vanity_RevertTemplate", function(cmd, payload)
    local char = Ext.GetCharacter(payload.CharNetID)
    local item = Ext.GetItem(payload.ItemNetID)

    Vanity.RevertAppearace(char, item)
end)

-- Toggling persistent outfit feature.
Game.Net.RegisterListener("EPIPENCOUNTERS_VanityPersistOutfit", function(cmd, payload)
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
Game.Net.RegisterListener("EPIPENCOUNTERS_VanityPersistWeaponry", function(cmd, payload)
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

-- Track new templates gained by players.
-- Ext.Osiris.RegisterListener("ItemTemplateAddedToCharacter", 3, "after", function(template, item, char)
    -- local item = Ext.GetItem(item)
    -- if #Osi.DB_IsPlayer:Get(char) > 0 and Game.Items.IsDyeable(item) then
    --     local slot = Game.Items.GetItemSlot(item)

    --     template = string.match(template, Data.Patterns.GUID_CAPTURE)

    --     local data = Vanity.GetTemplateData(item)

    --     Vanity.UnlockTemplate(template, data)

    --     Game.Net.Broadcast("EPIPENCOUNTERS_VanityTemplateFound", {
    --         Template = template,
    --         Data = data,
    --     })

    --     -- ParseFromFile()
    -- end
-- end)