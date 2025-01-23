
local Vanity = Client.UI.Vanity
local VanityFeature = Epip.GetFeature("Feature_Vanity")
local ColorPicker = Epip.GetFeature("Features.ColorPicker")

---@class Feature_Vanity_Dyes
local Dyes = Epip.GetFeature("Feature_Vanity_Dyes")
local TSK = {
    VanityTab = Dyes:RegisterTranslatedString({
        Handle = "h51316fa0g86f3g49a1g99f4g30bd703db792",
        Text = "Dyes",
        ContextDescription = [[Vanity tab name]],
    }),
    Label_CustomDye = Dyes:RegisterTranslatedString({
        Handle = "hfe2cdebcg8b7ag4648gb5efg912f86758ff4",
        Text = "Custom Color (RGB)",
        ContextDescription = [[Label in UI; "RGB" refers to "Red, green, blue"]],
    }),
    Button_ApplyDye = Dyes:RegisterTranslatedString({
        Handle = "h97fd1347g2a02g4221g8b95g4d7111b1aeee",
        Text = "Apply Dye",
        ContextDescription = [[Button label]],
    }),
    Button_ImportDye = Dyes:RegisterTranslatedString({
        Handle = "h2ee9689egad84g43ddg949egbac1d1d0ed6e",
        Text = "Import Dye",
        ContextDescription = [[Button label]],
    }),
    Button_ExportDye = Dyes:RegisterTranslatedString({
        Handle = "h3427b3a5gcda2g43fdgb888g093b23202fe0",
        Text = "Export Dye",
        ContextDescription = [[Button label]],
    }),
    Label_RemoveDye = Dyes:RegisterTranslatedString("hbb910187g05dag4c1fgb07cg3f1c6515de8f", {
        Text = "Remove Dye",
        ContextDescription = "Button for removing item dyes",
    }),
    Checkbox_LockColorSlides = Dyes:RegisterTranslatedString({
        Handle = "h598b8807gfcedg41e7gb839g3d8f252fa9bf",
        Text = "Lock Color Sliders",
        ContextDescription = [[Checkbox for preventing RGB sliders from being set automatically]],
    }),
    Label_SaveDye = Dyes:RegisterTranslatedString({
        Handle = "hc597a867g6292g4c8dgb9a0gf6adb8e76729",
        Text = "Save Dye",
        ContextDescription = [[Button label]],
    }),
    MsgBox_SaveDye_Body = Dyes:RegisterTranslatedString({
        Handle = "he363c0b9g91fbg48a3ga1cbgbc7a759eb832",
        Text = "Enter a name for this dye!",
        ContextDescription = [[Message box body for saving dyes]],
    }),
    MsgBox_DyeExported_Title = Dyes:RegisterTranslatedString({
        Handle = "h0844733egaca8g4b92g967ag9be4b8ec5041",
        Text = "Dye Exported",
        ContextDescription = [[Message box header when copying dyes to clipboard]],
    }),
    MsgBox_DyeExported_Body = Dyes:RegisterTranslatedString({
        Handle = "he980829dgb88eg4804g9c76gba9032eb01e5",
        Text = "Copied dye colors to clipboard.",
        ContextDescription = [[Message box body when copying dyes to clipboard]],
    }),
    MsgBox_RemoveDye_Body = Dyes:RegisterTranslatedString({
        Handle = "h92e8b290g5e1fg4e2aga497g8d782364617a",
        Text = "Are you sure you want to remove this dye (%s)?",
        ContextDescription = [[Message box for removing favorited/saved dyes; param is name of the custom dye to remove]],
    }),
}

---@class Features.Vanity.Dyes.Tab : CharacterSheetCustomTab
local Tab = {
    ID = "PIP_Vanity_Dyes",
    Name = TSK.VanityTab:GetString(),
    Icon = "hotbar_icon_dye",
    BUTTONS = {
        REMOVE = "Dye_Remove",
    },
}
Tab = Vanity.CreateTab(Tab) ---@cast Tab Features.Vanity.Dyes.Tab
Dyes.Tab = Tab

---------------------------------------------
-- TAB FUNCTIONALITY
---------------------------------------------

---@param categories VanityDyeCategory[]
function Tab:RenderCategories(categories)
    for _,category in ipairs(categories) do
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
    Vanity.RenderItemDropdown()

    local item = Vanity.GetCurrentItem()
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

        Vanity.RenderText("Color1_Hint", TSK.Label_CustomDye:GetString())
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

        Vanity.RenderButtonPair("Dye_Apply", TSK.Button_ApplyDye:GetString(), true, "Dye_Save", TSK.Label_SaveDye:GetString(), true)
        Vanity.RenderButtonPair("Dye_Import", TSK.Button_ImportDye:GetString(), true, "Dye_Export", TSK.Button_ExportDye:GetString(), true)
        Vanity.RenderButton(Tab.BUTTONS.REMOVE, TSK.Label_RemoveDye:GetString(), true)

        Vanity.RenderCheckbox("Dye_DefaultToItemColor", TSK.Checkbox_LockColorSlides:Format({Color = "000000"}), Dyes.lockColorSlider, true)

        -- Render categories
        local categories = Dyes.Hooks.GetCategories:Throw({
            Categories = {},
        }).Categories
        self:RenderCategories(categories)
    else
        Vanity.RenderText("NoItem", VanityFeature.TranslatedStrings.Label_NoItemEquipped:GetString())
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
            Header = TSK.Label_SaveDye:GetString(),
            Type = "Input",
            Message = TSK.MsgBox_SaveDye_Body:GetString(),
            Buttons = {{Text = Text.CommonStrings.Accept:GetString(), Type = 1, ID = 0}},
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

        -- Needs a timer to not interfere with the actual copy-to-clipboard operation.
        Timer.Start(0.2, function()
            Client.UI.MessageBox.Open({
                Header = TSK.MsgBox_DyeExported_Title:GetString(),
                Message = TSK.MsgBox_DyeExported_Body:GetString(),
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
        Header = TSK.Label_RemoveDye:GetString(),
        Message = TSK.MsgBox_RemoveDye_Body:Format({
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

-- Bring up the Color Picker when clicking on the color previews.
Tab:RegisterListener(Vanity.Events.ColorPressed, function(id)
    if id:find("Color_Label_") then
        local colorIndex = tonumber(id:sub(-1))
        ColorPicker.Request("Features.Vanity.Dyes.UI.Color." .. colorIndex, Dyes.currentSliderColor["Color" .. colorIndex])
    end
end)
ColorPicker.Events.ColorPicked:Subscribe(function (ev)
    if ev.RequestID:find("Features.Vanity.Dyes.UI.Color.", nil, true) then
        local colorIndex = tonumber(ev.RequestID:sub(-1))
        Dyes.currentSliderColor["Color" .. colorIndex] = ev.Color
        Tab:SetSliderColor(colorIndex, ev.Color, true)
    end
end)
