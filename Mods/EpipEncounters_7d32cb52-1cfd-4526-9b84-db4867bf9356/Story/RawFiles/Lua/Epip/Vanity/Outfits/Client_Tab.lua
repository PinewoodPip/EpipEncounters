
local Vanity = Client.UI.Vanity
local CommonStrings = Text.CommonStrings

---@class Feature_Vanity_Outfits
local Outfits = Epip.GetFeature("Feature_Vanity_Outfits")

local TSK = {
    VanityTab = Outfits:RegisterTranslatedString({
        Handle = "he5c7af2eg96a9g4e92g8a50g5ef795e219d1",
        Text = "Outfits",
        ContextDescription = [[Vanity tab name]],
    }),
    Label_Hint = Outfits:RegisterTranslatedString({
        Handle = "h157ffd3bg5fdag4f5ag93c3gd575ef924d37",
        Text = "Save and apply outfits consisting of all your currently applied items.",
        ContextDescription = [[Hint shown at the top of the UI]],
    }),
    Label_SaveOutfit = Outfits:RegisterTranslatedString({
        Handle = "he6444a72g7e13g43d7gb58fg16746e643f90",
        Text = "Save Outfit",
        ContextDescription = [[Button label]],
    }),
    MsgBox_RemoveOutfit_Header = Outfits:RegisterTranslatedString({
        Handle = "hc6649aa4g4a9eg4bc3g97d5g2f281efe855a",
        Text = "Remove Outfit",
        ContextDescription = [[Message box header for removing saved outfits]],
    }),
    MsgBox_RemoveOutfit_Description = Outfits:RegisterTranslatedString({
        Handle = "he381be9bg9e27g4c86g883cg7f3879f704f5",
        Text = "Are you sure you want to remove this outfit (%s)?",
        ContextDescription = [[Message box for removing saved outfits]],
    }),
    MsgBox_SaveOutfit_Body = Outfits:RegisterTranslatedString({
        Handle = "h025ca76ag673eg4f3agb92agb693e964f023",
        Text = "Name your outfit!",
        ContextDescription = [[Message box for saving outfits]],
    }),
    Label_SaveWithWeapons = Outfits:RegisterTranslatedString({
        Handle = "h744534d4g7175g4bd6g814fgf6c9272d060a",
        Text = "Save with weapons",
        ContextDescription = [[Confirmation button in message box for saving outfits]],
    }),
}

---@type CharacterSheetCustomTab
local Tab = Vanity.CreateTab({
    ID = "PIP_Vanity_Outfits",
    Name = TSK.VanityTab:GetString(),
    Icon = "hotbar_icon_helm",
})
Outfits.Tab = Tab

---------------------------------------------
-- TAB FUNCTIONALITY
---------------------------------------------

function Tab:Render()
    ---@type table<string,VanityOutfit>
    local outfits = Outfits.SavedOutfits
    local categories = {}

    Vanity.RenderText("PIP_Vanity_Outfit_Header", TSK.Label_Hint:GetString())

    for _,data in pairs(outfits) do
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
    Vanity.RenderButton("SaveOutfit", TSK.Label_SaveOutfit:GetString(), true)

    for categoryID,category in pairs(categories) do
        local isOpen = Vanity.IsCategoryOpen(categoryID)

        Vanity.RenderEntry(categoryID, category.Name, true, isOpen)

        if isOpen then
            for _,outfit in ipairs(category.Outfits) do
                Vanity.RenderEntry(outfit.Name, outfit.Name, false, false, false, false, nil, true)
            end
        end
    end
end

Tab:RegisterListener(Vanity.Events.EntryClicked, function(id)
    Outfits.ApplyOutfit(nil, id)
end)

Tab:RegisterListener(Vanity.Events.ButtonPressed, function(id)
    if id == "SaveOutfit" then
        Client.UI.MessageBox.Open({
            ID = "epip_Vanity_Outfit_Save",
            Header = TSK.Label_SaveOutfit:GetString(),
            Message = TSK.MsgBox_SaveOutfit_Body:GetString(),
            Type = "Input",
            Buttons = {
                {Type = 1, Text = CommonStrings.Save:GetString(), ID = 1},
                {Type = 1, Text = TSK.Label_SaveWithWeapons:GetString(), ID = 2},
            }
        })
    end
end)

Tab:RegisterListener(Vanity.Events.EntryRemoved, function(id)
    Client.UI.MessageBox.Open({
        ID = "PIP_Vanity_RemoveOutfit",
        Header = TSK.MsgBox_RemoveOutfit_Header:GetString(),
        Message = TSK.MsgBox_RemoveOutfit_Description:Format({
            FormatArgs = {id},
        }),
        Buttons = {
            {Type = 1, Text = CommonStrings.Remove:GetString(), ID = 0},
            {Type = 1, Text = CommonStrings.Cancel:GetString(), ID = 1},
        },
        OutfitID = id,
    })
end)