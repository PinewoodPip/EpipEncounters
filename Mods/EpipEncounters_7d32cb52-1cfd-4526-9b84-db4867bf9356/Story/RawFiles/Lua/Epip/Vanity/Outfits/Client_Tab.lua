
local Vanity = Client.UI.Vanity

---@class Feature_Vanity_Outfits
local Outfits = Epip.GetFeature("Feature_Vanity_Outfits")

---@type CharacterSheetCustomTab
local Tab = Vanity.CreateTab({
    Name = "Outfits",
    Icon = "hotbar_icon_helm",
    ID = "PIP_Vanity_Outfits",
})
Outfits.Tab = Tab

---------------------------------------------
-- TAB FUNCTIONALITY
---------------------------------------------

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