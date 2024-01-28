
local Vanity = Client.UI.Vanity

---@class Feature_Vanity_Dyes
local Dyes = Epip.GetFeature("Feature_Vanity_Dyes")
local TSK = {
    Button_RemoveDye = Dyes:RegisterTranslatedString("hbb910187g05dag4c1fgb07cg3f1c6515de8f", {
        Text = "Remove Dye",
        ContextDescription = "Button for removing item dyes",
    })
}

---@class Features.Vanity.Dyes.Tab : CharacterSheetCustomTab
local Tab = {
    Name = "Dyes",
    ID = "PIP_Vanity_Dyes",
    Icon = "hotbar_icon_dye",
    BUTTONS = {
        REMOVE = "Dye_Remove",
    },
}
Tab = Vanity.CreateTab(Tab)
Dyes.Tab = Tab

---------------------------------------------
-- TAB FUNCTIONALITY
---------------------------------------------

---@param categories VanityDyeCategory[]
function Tab:RenderCategories(categories)
    for i,category in ipairs(categories) do
        local isOpen = Vanity.IsCategoryOpen(category.ID)
        Vanity.RenderEntry(category.ID, category.Name, true, isOpen, false, false)

        if isOpen then
            local dyes = category.Dyes

            for _,dye in ipairs(dyes) do
                Vanity.RenderEntry(dye.ID, dye.Name or dye.ID, false, false, false, false, nil, category.ID == "CustomDyes", {
                    dye.Color1,
                    dye.Color2,
                    dye.Color3,
                })
            end
        end
    end
end

---@param dye VanityDye
function Tab:SetSliderColors(dye)
    Dyes.currentSliderColor = {
        Color1 = Color.Clone(dye.Color1),
        Color2 = Color.Clone(dye.Color2),
        Color3 = Color.Clone(dye.Color3),
    }

    for i=1,3,1 do
        ---@type RGBColor
        local color = "Color" .. i
        color = Dyes.currentSliderColor[color]

        Tab:SetSliderColor(i, color, true)
    end
end

---@param sliderIndex integer
---@param color RGBColor
function Tab:SetSliderColor(sliderIndex, color, forceTextUpdate)
    local menu = Vanity.GetMenu()

    menu.setSlider("Dye_" .. sliderIndex .. "_Red", color.Red)
    menu.setSlider("Dye_" .. sliderIndex .. "_Green", color.Green)
    menu.setSlider("Dye_" .. sliderIndex .. "_Blue", color.Blue)

    self:UpdateColorSliderLabel(sliderIndex, forceTextUpdate)
end

function Tab:Render()
    local item = Vanity.GetCurrentItem()

    Vanity.RenderItemDropdown()

    local categories = Dyes.Hooks.GetCategories:Return({})

    if item then
        local currentSliderColor = {
            Color1 = Color.Create(),
            Color2 = Color.Create(),
            Color3 = Color.Create(),
        }

        local currentCustomDye = Dyes.GetCurrentCustomDye(item)

        if currentCustomDye and not Dyes.lockColorSlider then
            currentSliderColor = currentCustomDye
            Dyes.currentSliderColor = currentSliderColor
        end

        Vanity.RenderText("Color1_Hint", "Custom Color (RGB)")
        -- RGB sliders
        for i=1,3,1 do
            ---@type RGBColor
            local color = "Color" .. i
            color = Dyes.currentSliderColor[color]

            -- TODO render color labels
            Vanity.RenderLabelledColor("Color_Label_" .. i, color:ToDecimal(), "", true)
            self:UpdateColorSliderLabel(i, true)

            Vanity.RenderSlider("Dye_" .. i .. "_Red", color.Red, 0, 255, Dyes.DYE_PALETTE_BITS, "Red", "Red")
            Vanity.RenderSlider("Dye_" .. i .. "_Green", color.Green, 0, 255, Dyes.DYE_PALETTE_BITS, "Green", "Green")
            Vanity.RenderSlider("Dye_" .. i .. "_Blue", color.Blue, 0, 255, Dyes.DYE_PALETTE_BITS, "Blue", "Blue")
        end

        Vanity.RenderButtonPair("Dye_Apply", "Apply Dye", true, "Dye_Save", "Save Dye", true)
        Vanity.RenderButtonPair("Dye_Import", "Import Dye", true, "Dye_Export", "Export Dye", true)
        Vanity.RenderButton(Tab.BUTTONS.REMOVE, TSK.Button_RemoveDye:GetString(), true)

        Vanity.RenderCheckbox("Dye_DefaultToItemColor", Text.Format("Lock Color Sliders", {Color = "000000"}), Dyes.lockColorSlider, true)

        self:RenderCategories(categories)
    else
        Vanity.RenderText("NoItem", "You don't have an item equipped in that slot!")
    end
end

function Tab:UpdateColorSliderLabel(index, forceTextUpdate)
    local color = Dyes.currentSliderColor["Color" .. index]
    Vanity.SetColorLabel("Color_Label_" .. index, color:ToDecimal(), Text.Format(Dyes.COLOR_NAMES[tonumber(index)], {Color = "000000"}), color:ToHex(true), forceTextUpdate)
end

Tab:RegisterListener(Vanity.Events.ButtonPressed, function(id)
    if id == "Dye_Apply" then
        Dyes.ApplyGenericDyeFromSliders()
    elseif id == "Dye_Save" then
        Client.UI.MessageBox.Open({
            ID = "PIP_Vanity_SaveDye",
            Header = "Save Dye",
            Type = "Input",
            Message = "Enter a name for this dye!",
            Buttons = {{Text = "Accept", Type = 1, ID = 0}},
        })
    elseif id == "Dye_Export" then
        local export = Text.Format("%s-%s-%s", {
            FormatArgs = {
                "#" .. Dyes.currentSliderColor.Color1:ToHex(),
                "#" .. Dyes.currentSliderColor.Color2:ToHex(),
                "#" .. Dyes.currentSliderColor.Color3:ToHex(),
            }
        })

        export = string.gsub(export, "<font>", "")
        export = string.gsub(export, "</font>", "")

        Client.UI.MessageBox.CopyToClipboard(export)

        Timer.Start("", 0.2, function()
            Client.UI.MessageBox.Open({
                Header = "Dye Exported",
                Message = "Copied dye colors to clipboard."
            })
        end)
    elseif id == "Dye_Import" then
        Client.UI.MessageBox.RequestClipboardText("PIP_Vanity_Dyes_Import")
    elseif id == Tab.BUTTONS.REMOVE then
        Dyes.RemoveDye(Client.GetCharacter(), Vanity.GetCurrentItem())
    end
end)

Tab:RegisterListener(Vanity.Events.CheckboxPressed, function(id, state)
    if id == "Dye_DefaultToItemColor" then
        Dyes.lockColorSlider = state
    end
end)

-- Listen for RGB sliders.
Tab:RegisterListener(Vanity.Events.SliderHandleReleased, function (id, value)
    local colorIndex,channel = id:match("^Dye_(%d)_(%a*)$")
    local color = Dyes.currentSliderColor["Color" .. colorIndex]

    color[channel] = value

    Tab:UpdateColorSliderLabel(colorIndex, true)
end)

-- Listen for copy buttons.
Tab:RegisterListener(Vanity.Events.CopyPressed, function(id, text)
    Client.UI.MessageBox.CopyToClipboard(text)
end)

Tab:RegisterListener(Vanity.Events.PastePressed, function(id)
    local colorIndex = string.gsub(id, "Color_Label_", "")

    Dyes.colorPasteIndex = colorIndex
    Client.UI.MessageBox.RequestClipboardText("PIP_DyePaste")
end)

Client.UI.MessageBox.Events.ClipboardTextRequestComplete:RegisterListener(function (id, text)
    if id == "PIP_DyePaste" then
        local colorIndex = Dyes.colorPasteIndex
        local color = Color.CreateFromHex(text)

        if color then
            Dyes.currentSliderColor["Color" .. colorIndex] = color

            Tab:SetSliderColor(colorIndex, color, true)
        end

        Dyes.colorPasteIndex = nil
    elseif id == "PIP_Vanity_Dyes_Import" then
        text = text:gsub("#", "")

        -- Goddamnnit the UI restricts characters way too much, wanted to use commas instead
        local values = Text.Split(text, "-")

        if #values == 3 then
            Dyes.currentSliderColor.Color1 = Color.CreateFromHex(values[1])
            Dyes.currentSliderColor.Color2 = Color.CreateFromHex(values[2])
            Dyes.currentSliderColor.Color3 = Color.CreateFromHex(values[3])

            Tab:SetSliderColors(Dyes.currentSliderColor)
        end
    end
end)

Tab:RegisterListener(Vanity.Events.EntryClicked, function(id)
    Dyes.UseDye(id)
end)

-- Listen for color codes being entered.
Tab:RegisterListener(Vanity.Events.InputChanged, function(id, text)
    text = string.gsub(text, "#", "")
    local colorIndex = string.gsub(id, "Color_Label_", "")

    if string.len(text) == 6 then
        local color = Color.CreateFromHex(text)
        
        Dyes.currentSliderColor["Color" .. colorIndex] = color

        Tab:SetSliderColor(colorIndex, color, false)
    end
end)

-- Listen for dyes being removed.
Tab:RegisterListener(Vanity.Events.EntryRemoved, function(id)
    Client.UI.MessageBox.Open({
        ID = "PIP_Vanity_RemoveDye",
        Header = "Remove Dye",
        Message = Text.Format("Are you sure you want to remove this dye (%s)?", {
            FormatArgs = {id},
        }),
        Buttons = {
            {Type = 1, Text = "Remove", ID = 0},
            {Type = 1, Text = "Cancel", ID = 1},
        },
        DyeID = id,
    })
end)

Client.UI.MessageBox.RegisterMessageListener("PIP_Vanity_RemoveDye", Client.UI.MessageBox.Events.ButtonPressed, function(buttonID, data)
    if buttonID == 0 then
        Dyes.DeleteCustomDye(data.DyeID)
    end
end)
