
local Vanity = Client.UI.Vanity

local Outfits = {
    SavedOutfits = {},

    Events = {
        ---@type VanityOutfits_Event_OutfitSaved
        OutfitSaved = {},
        ---@type VanityOutfits_Event_OutfitApplied
        OutfitApplied = {},
    },
    Hooks = {
        ---@type VanityOutfits_Hook_GetOutfitSaveData
        GetOutfitSaveData = {},
    }
}
Epip.AddFeature("VanityOutfits", "VanityOutfits", Outfits)
Epip.Features.VanityOutfits = Outfits

---@type CharacterSheetCustomTab
local Tab = Vanity.CreateTab({
    Name = "Outfits",
    Icon = "hotbar_icon_helm",
    ID = "PIP_Vanity_Outfits",
})

---------------------------------------------
-- EVENTS / HOOKS
---------------------------------------------

---@class VanityOutfits_Event_OutfitApplied : Event
---@field RegisterListener fun(self, listener:fun(outfit:VanityOutfit, char:EclCharacter))
---@field Fire fun(self, outfit:VanityOutfit, char:EclCharacter)

---@class VanityOutfits_Event_OutfitSaved : Event
---@field RegisterListener fun(self, listener:fun(outfit:VanityOutfit))
---@field Fire fun(self, outfit:VanityOutfit)

---@class VanityOutfits_Hook_GetOutfitSaveData : Hook
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
    local outfit = Outfits.SavedOutfits[outfitID]
    char = char or Client.GetCharacter()

    if outfit then
        Game.Net.PostToServer("EPIPENCOUNTERS_Vanity_ApplyOutfit", {
            NetID = char.NetID,
            Outfit = outfit,
        })
        Outfits.Events.OutfitApplied:Fire(outfit, char)
    else
        Vanity:LogError("Outfit does not exist: " .. outfitID)
    end
end

function Tab:Render()
    ---@type table<string,VanityOutfit>
    local outfits = Outfits.SavedOutfits
    local categories = {}

    Vanity.RenderText("PIP_Vanity_Outfit_Header", "Save and apply outfits consisting of all your currently applied items.")

    for id,data in pairs(outfits) do
        local categoryID = "Other"
        local category

        if data.Race and data.Gender then
            categoryID = data.Gender .. " " .. data.Race
        end

        if not categories[categoryID] then
            categories[categoryID] = {
                Name = categoryID,
                Outfits = {},
            }
            Vanity.racialCategories[categoryID] = true
        end

        category = categories[categoryID]

        table.insert(category.Outfits, data)
    end

    -- Buttons
    Vanity.RenderButton("SaveOutfit", "Save Outfit", true)

    for categoryID,category in pairs(categories) do
        local isOpen = Vanity.IsCategoryOpen(categoryID)

        Vanity.RenderEntry(categoryID, category.Name, true, isOpen)

        if isOpen then
            for i,outfit in ipairs(category.Outfits) do
                Vanity.RenderEntry(outfit.Name, outfit.Name, false, false, false, false, nil, true)
            end
        end
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

    for slot,i in pairs(Vanity.SLOT_TO_DB_INDEX) do
        -- Default values.
        outfit.Templates[slot] = ""

        if slots[slot] then
            outfit.Templates[slot] = Vanity.GetTemplateInSlot(char, slot)
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

Client.UI.MessageBox.RegisterMessageListener("epip_Vanity_Outfit_Save", Client.UI.MessageBox.Events.InputSubmitted, function(text, buttonId, data)
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

Tab:RegisterListener(Vanity.Events.EntryClicked, function(id)
    Outfits.ApplyOutfit(nil, id)
end)

Tab:RegisterListener(Vanity.Events.ButtonPressed, function(id)
    if id == "SaveOutfit" then
        Client.UI.MessageBox.Open({
            ID = "epip_Vanity_Outfit_Save",
            Header = "Save Outfit",
            Message = "Name your outfit!",
            Type = "Input",
            Buttons = {
                {Type = 1, Text = "Save", ID = 1},
                {Type = 1, Text = "Save with weapons", ID = 2},
            }
        })
    end
end)

Vanity.Hooks.GetSaveData:RegisterHook(function (data)
    data.Outfits = Outfits.SavedOutfits

    return data
end)

Vanity.Events.SaveDataLoaded:RegisterListener(function (data)
    if data.Version >= 2 then
        Outfits.SavedOutfits = data.Outfits
    end
end)

Tab:RegisterListener(Vanity.Events.EntryRemoved, function(id)
    Client.UI.MessageBox.Open({
        ID = "PIP_Vanity_RemoveOutfit",
        Header = "Remove Outfit",
        Message = Text.Format("Are you sure you want to remove this outfit (%s)?", {
            FormatArgs = {id},
        }),
        Buttons = {
            {Type = 1, Text = "Remove", ID = 0},
            {Type = 1, Text = "Cancel", ID = 1},
        },
        OutfitID = id,
    })
end)

Client.UI.MessageBox.RegisterMessageListener("PIP_Vanity_RemoveOutfit", Client.UI.MessageBox.Events.ButtonPressed, function(buttonID, data)
    if buttonID == 0 then
        Outfits.DeleteOutfit(data.OutfitID)
    end
end)