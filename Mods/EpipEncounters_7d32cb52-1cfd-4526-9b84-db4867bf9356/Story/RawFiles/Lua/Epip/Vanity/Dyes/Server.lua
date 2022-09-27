
---@class Feature_Vanity_Dyes
local Dyes = Epip.GetFeature("Feature_Vanity_Dyes")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_CreateDyeStat_ForPeers", function(payload)
    Net.Broadcast("EPIPENCOUNTERS_CreateDyeStat", payload)
end)

local function hex(val, minLength)
    minLength = minLength or 0
    local valStr = string.format("%x", val)

    
    while string.len(valStr) < minLength do
        valStr = "0" .. valStr
    end

    return valStr:upper()
end

Net.RegisterListener("EPIPENCOUNTERS_DyeItem", function(payload)
    local item = Item.Get(payload.ItemNetID)
    local dye = payload.Dye
    local char = Character.Get(payload.CharacterNetID)
    local color1 = dye.Color1
    local color2 = dye.Color2
    local color3 = dye.Color3
    local tag = string.format("PIP_DYE_%s%s%s_%s%s%s_%s%s%s", hex(color1.Red, 2), hex(color1.Green, 2), hex(color1.Blue, 2), hex(color2.Red, 2), hex(color2.Green, 2), hex(color2.Blue, 2), hex(color3.Red, 2), hex(color3.Green, 2), hex(color3.Blue, 2))
    
    print("Color tag: " .. tag)

    -- Clear previous dye tags
    for _,existingTag in ipairs(item:GetTags()) do
        if existingTag:match("^PIP_DYE_(%x+)_(%x+)_(%x+)$") then -- TODO use constant
            Osiris.ClearTag(item, existingTag)
        end
    end

    Osiris.SetTag(item, tag)
    
    Epip.Features.Vanity.RefreshAppearance(char, true)
end)

Net.RegisterListener("EPIPENCOUNTERS_DYE", function(payload)
    local item = Ext.GetItem(payload.Item)
    local char = Ext.GetCharacter(payload.Character)
    local dyeData = payload.DyeData
    local dye = Osi.GetItemForItemTemplateInPartyInventory(char.MyGuid, dyeData.Template)


    -- Can't craft in combat; thereby neither can we dye.
    if Osi.CombatGetIDForCharacter(char.MyGuid) ~= 0 then
        Osi.PROC_AMER_GEN_OpenQueuedMessageBox(char.MyGuid, "I shouldn't be thinking about these things while my life is at stake!")
    else
        if dye then
            -- TODO make feature
            Utilities.Hooks.FireEvent("ContextMenus_Dyes", "ItemBeingDyed", item)
            
            local deltamod = "Boost_" .. item.Stats.ItemType .. "_" .. dyeData.Deltamod
    
            Osi.ItemAddDeltaModifier(item.MyGuid, deltamod)
    
            Osi.QRY_AMER_GEN_GetEquippedItemSlot(char.MyGuid, item.MyGuid)
    
            -- TODO add this check to the proc instead
            if Osi.DB_AMER_GEN_OUTPUT_String:Get(nil)[1][1] ~= "None" then
                Osi.PROC_PIP_ReEquipItem(char.MyGuid, item.MyGuid)
            end
        else
            -- This should no longer happen, since we added this check client-side.
            Osi.PROC_AMER_GEN_OpenQueuedMessageBox(char.MyGuid, "We don't have that dye!<br>We shall shop for them at miscellaneous vendors.")
        end
    end
end)