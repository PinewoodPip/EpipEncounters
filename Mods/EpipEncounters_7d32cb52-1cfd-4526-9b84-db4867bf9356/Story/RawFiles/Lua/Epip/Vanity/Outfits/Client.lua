
local Vanity = Client.UI.Vanity
local Transmog = Epip.GetFeature("Feature_Vanity_Transmog")

---@class Feature_Vanity_Outfits
local Outfits = Epip.GetFeature("Feature_Vanity_Outfits")

---------------------------------------------
-- EVENTS / HOOKS
---------------------------------------------
---@type VanityOutfits_Event_OutfitSaved
Outfits.Events.OutfitSaved = Outfits:AddEvent("OutfitSaved")
---@type VanityOutfits_Event_OutfitApplied
Outfits.Events.OutfitApplied = Outfits:AddEvent("OutfitApplied")

---@type VanityOutfits_Hook_GetOutfitSaveData
Outfits.Hooks.GetOutfitSaveData = Outfits:AddHook("GetOutfitSaveData")

---@class VanityOutfits_Event_OutfitApplied : Event
---@field RegisterListener fun(self, listener:fun(outfit:VanityOutfit, char:EclCharacter))
---@field Fire fun(self, outfit:VanityOutfit, char:EclCharacter)

---@class VanityOutfits_Event_OutfitSaved : Event
---@field RegisterListener fun(self, listener:fun(outfit:VanityOutfit))
---@field Fire fun(self, outfit:VanityOutfit)

---@class VanityOutfits_Hook_GetOutfitSaveData : LegacyHook
---@field RegisterHook fun(self, handler:fun(data:VanityOutfit, char:EclCharacter))
---@field Return fun(self, data:VanityOutfit, char:EclCharacter)

---------------------------------------------
-- METHODS
---------------------------------------------

---Delete a saved outfit.
---@param id string
function Outfits.DeleteOutfit(id)
    Outfits.SavedOutfits[id] = nil
    Vanity.Refresh()
    Vanity.SaveData()
end

---Request an outfit to be applied to a character.
---The outfit must exist on the client this is called from.
---@param char? EclCharacter
---@param outfitID string
function Outfits.ApplyOutfit(char, outfitID)
    ---@type VanityOutfit
    local outfit = Outfits.SavedOutfits[outfitID]
    char = char or Client.GetCharacter()

    if outfit then
        for slot,template in pairs(outfit.Templates) do
            local item = char:GetItemBySlot(slot)

            if item and template ~= "" then
                item = Item.Get(item)
                Epip.GetFeature("Feature_Vanity_Transmog").TransmogItem(item, template)
            end
        end
        Outfits.Events.OutfitApplied:Fire(outfit, char)
    else
        Vanity:LogError("Outfit does not exist: " .. outfitID)
    end
end

function Outfits.SaveCurrentOutfit(name, slots)
    local char = Client.GetCharacter()

    Outfits.SavedOutfits[name] = {
        Name = name,
        Race = Game.Character.GetRace(Client.GetCharacter()),
        Gender = Game.Character.GetGender(Client.GetCharacter()),
        Templates = {},
    }

    local outfit = Outfits.SavedOutfits[name]

    for slot,_ in pairs(Vanity.SLOT_TO_DB_INDEX) do
        -- Default values.
        outfit.Templates[slot] = ""

        if slots[slot] then
            local itemGUID = char:GetItemBySlot(slot)
            local item = itemGUID and Item.Get(itemGUID)

            if item then
                outfit.Templates[slot] = Transmog.GetTransmoggedTemplate(item) or Vanity.GetTemplateInSlot(char, slot)
            end
        end
    end

    outfit = Outfits.Hooks.GetOutfitSaveData:Return(outfit, char)

    Outfits.Events.OutfitSaved:Fire(outfit)
    Vanity.Refresh()
    Vanity.SaveData()
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.MessageBox.RegisterMessageListener("PIP_Vanity_RemoveOutfit", Client.UI.MessageBox.Events.ButtonPressed, function(buttonID, data)
    if buttonID == 0 then
        Outfits.DeleteOutfit(data.OutfitID)
    end
end)

Client.UI.MessageBox.RegisterMessageListener("epip_Vanity_Outfit_Save", Client.UI.MessageBox.Events.InputSubmitted, function(text, buttonId, _)
    local slots = {
        Helmet = true,
        Breast = true,
        Gloves = true,
        Leggings = true,
        Boots = true,
    }

    -- Add weapon slots.
    if buttonId == 2 then
        slots.Weapon = true
        slots.Shield = true
    end

    Outfits.SaveCurrentOutfit(text, slots)
end)

Vanity.Hooks.GetSaveData:RegisterHook(function (data)
    data.Outfits = Outfits.SavedOutfits

    return data
end)

Vanity.Events.SaveDataLoaded:RegisterListener(function (data)
    if data.Version >= 2 then
        Outfits.SavedOutfits = data.Outfits or {}
    end
end)