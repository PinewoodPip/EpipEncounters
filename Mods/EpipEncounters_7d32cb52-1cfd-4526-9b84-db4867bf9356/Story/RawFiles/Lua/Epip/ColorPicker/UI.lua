
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local LabelledSlider = Generic.GetPrefab("GenericUI_Prefab_LabelledSlider")
local ButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_Button")
local ImagePrefab = Generic.GetPrefab("GenericUI.Prefabs.Image")
local DraggingArea = Generic.GetPrefab("GenericUI_Prefab_DraggingArea")
local TEXTURES = Epip.GetFeature("Feature_GenericUITextures").TEXTURES
local Notification = Client.UI.Notification
local MsgBox = Client.UI.MessageBox
local Input = Client.Input
local CommonStrings = Text.CommonStrings
local V = Vector.Create

local ColorPicker = Epip.GetFeature("Features.ColorPicker") ---@class Features.ColorPicker

---@class Features.ColorPicker.UI : GenericUI_Instance
local UI = Generic.Create("Features.ColorPicker.UI")
ColorPicker.UI = UI
UI.PANEL_SIZE = V(700, 700)
UI.PICKER_IMAGE_SIZE = V(64, 64)
UI.SLIDER_SIZE = V(550, 50)
UI.SPECTRUM_SIZE = V(400, UI.SLIDER_SIZE[2]) -- Size of the hue spectrum preview.
UI.SETTINGS_SIZE = V(500, 50)
UI.HEADER_FONT_SIZE = 24
UI.PREVIEW_COLOR_SIZE = V(80, 80)
UI.PREVIEW_COLOR_PADDING = V(56, 56) -- Per-axe padding for the color preview.
UI.Events = {
    ColorChanged = SubscribableEvent:New("ColorChanged"), ---@type Event<{NewColor:RGBColor}>
}
UI._CurrentColor = nil ---@type RGBColor The currently-selected color.
UI._CurrentColorFloats = nil ---@type Vector3 Needs to be tracked to avoid precision loss issues when going to/from HSV to/from integer RGB.

local TSK = {
    Label_Hue = ColorPicker:RegisterTranslatedString({
        Handle = "h1bd5ba3cg52f2g43d2gae8bg914ead477199",
        Text = [[Hue]],
        ContextDescription = [[Slider label. Refers to color hue.]],
    }),
    Label_ColorPicker = ColorPicker:RegisterTranslatedString({
        Handle = "h7466ab56g6ec0g45a0g9d4cgf47554dbd0c8",
        Text = [[Color Picker]],
        ContextDescription = [[Header for UI]],
    }),
    Notification_ColorCopied = ColorPicker:RegisterTranslatedString({
        Handle = "hf3ead812g1edcg46c4gb4d2gad348ea52b93",
        Text = [[Color %s copied to clipboard.]],
        ContextDescription = [[Notification when pressing the "copy" button. Param is HTML color code]],
    }),
    Notification_InvalidPaste = ColorPicker:RegisterTranslatedString({
        Handle = "h5922087ag9b79g483eg88f1g12e30819488b",
        Text = [[Invalid hex/html color in clipboard.]],
        ContextDescription = [[Notification when pressing the "paste" button with invalid clipboard contents]],
    }),
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Sets up the UI for a picking request.
---@param request Features.ColorPicker.Events.ColorRequested
function UI.Setup(request)
    UI._Initialize()

    UI.SetColor(request.DefaultColor, true)

    UI._CurrentRequest = request

    UI:GetUI().SysPanelSize = UI.PANEL_SIZE
    UI:SetPositionRelativeToViewport("center", "center")
    UI:Show()
end

---Sets the selected color.
---@param color RGBColor
---@param updateHue boolean? Whether to force-update the hue slider and gradient. Defaults to `false`.
function UI.SetColor(color, updateHue)
    local currentColor = UI._CurrentColor
    local hue, _, _ = color:ToHSV()
    local hueChanged = currentColor == nil or updateHue
    if not hueChanged then
        local oldHue, _, _ = currentColor:ToHSV()
        hueChanged = math.abs(hue - oldHue) > 0.8 -- Needs to be a high threshold due to loss when converting to & from HSV using integer RGB
    end

    UI._CurrentColor = color
    UI._CurrentColorFloats = V(color:ToFloats())
    UI.Events.ColorChanged:Throw({
        NewColor = color,
    })

    -- Only re-render the gradient if hue has changed.
    if hueChanged then
        local img = Client.Image.CreateImage(UI.PICKER_IMAGE_SIZE:unpack())
        local w, h = UI.PICKER_IMAGE_SIZE:unpack()
        for i=1,w,1 do
            for j=1,h,1 do
                local pixelSaturation, pixelValue = i / w, 1 - j / h
                img:AddPixel(Color.CreateFromHSV(hue, pixelSaturation, pixelValue))
            end
        end
        UI.GradientImage:SetImage(img)
    end

    -- Update hue slider.
    if updateHue then
        UI.HueSlider:SetValue(Ext.Round(hue))
    end
end

---Sets a text element's label to a specific color and applies appropriately-contrasting stroke.
---@param textField GenericUI_Element_Text
---@param label string
---@param color RGBColor
function UI._SetTextColorWithStroke(textField, label, color)
    local r, g, b = color:Unpack()
    textField:SetText(Text.Format(label, {
        Color = color:ToHex(),
    }))
    -- Set label stroke color to be black or white based on highest contrast
    -- Source: https://stackoverflow.com/a/3943023 (not fully W3C compliant) TODO
    local strokeColor = Color.CreateFromHex((r * 0.299 + g * 0.587 + b * 0.114) > 186 and "000000" or "ffffff")
    textField:SetStroke(strokeColor:ToDecimal(), 2, 1, 15, 20)
end

---Selects a color based on the cursor position over the gradient image.
---Expects cursor to be over the gradient.
function UI._SelectColorFromGradient()
    local gradient = UI.GradientImage
    local mc = gradient.Root:GetMovieClip()
    local mouseX, mouseY = mc.mouseX, mc.mouseY
    local w, h = gradient.Root:GetSize():unpack()
    local saturation, value = mouseY / w, 1 - mouseX / h
    saturation, value = math.clamp(saturation, 0, 1), math.clamp(value, 0, 1)
    local hue, _, _ = UI._CurrentColor:ToHSV()
    local newColor, newR, newG, newB = Color.CreateFromHSV(hue, saturation, value)
    UI.SetColor(newColor) -- Hue is altered via a slider instead.
    -- We must store the color as float, as otherwise hue loss issues occur when clicking certain parts of the gradient to pick new colors.
    UI._CurrentColorFloats = V(newR, newG, newB)
end

---Initializes the UI's static elements.
function UI._Initialize()
    if UI._Initialized then return end

    local root = UI:CreateElement("Root", "GenericUI_Element_Empty")
    local bg = UI:CreateElement("Background", "GenericUI_Element_TiledBackground", root)
    bg:SetBackground("FormattedTooltip", UI.PANEL_SIZE:unpack())
    UI.Background = bg

    -- Dragging area
    DraggingArea.Create(UI, "DraggingArea", bg, V(UI.PANEL_SIZE[1], 100))

    -- Close button
    local closeButton = CloseButtonPrefab.Create(UI, "CloseButton", bg)
    closeButton:SetPositionRelativeToParent("TopRight", -7, 10)

    local header = TextPrefab.Create(UI, "Header", bg, TSK.Label_ColorPicker, "Center", UI.PANEL_SIZE)
    header:SetPositionRelativeToParent("Top", 0, 20)
    -- Make header color match selected color
    UI.Events.ColorChanged:Subscribe(function (ev)
        UI._SetTextColorWithStroke(header, TSK.Label_ColorPicker:Format({
            Size = UI.HEADER_FONT_SIZE,
        }), ev.NewColor)
    end)

    -- TODO remove? or add preview widget to it
    local panelList = bg:AddChild("PanelList", "GenericUI_Element_HorizontalList")
    panelList:SetPosition(50, 50)
    UI.PanelList = panelList

    -- Picker panel
    local pickerContainer = panelList:AddChild("PickerContainer", "GenericUI_Element_VerticalList")
    pickerContainer:SetElementSpacing(10)
    pickerContainer:Move(0, 40)
    UI.PickerContainer = pickerContainer

    -- Create gradient image
    local img = Client.Image.CreateImage(UI.PICKER_IMAGE_SIZE:unpack())
    for _=1,UI.PICKER_IMAGE_SIZE[1],1 do
        for _=1,UI.PICKER_IMAGE_SIZE[2],1 do
            img:AddPixel(Color.CreateFromHex(Color.BLACK))
        end
    end
    local gradientHolder = UI:CreateElement("GradientContainer", "GenericUI_Element_Texture", pickerContainer)
    gradientHolder:SetTexture(TEXTURES.FRAMES.BROWN, V(272, 272))
    local gradient = ImagePrefab.Create(UI, "PickerImage", gradientHolder, img)
    gradient:SetMouseMoveEventEnabled(true)
    -- Set picked color upon clicking on the gradient.
    gradient.Root.Events.MouseDown:Subscribe(function (_)
        UI._SelectColorFromGradient()
    end)
    -- Also select colors while left-click is held down.
    -- This allows click-and-hold controls while moving the mouse across the gradient.
    gradient.Root.Events.MouseMove:Subscribe(function (_)
        if Input.IsKeyPressed("left2") then
            UI._SelectColorFromGradient()
        end
    end)
    gradient:SetPositionRelativeToParent("Center")
    UI.GradientImage = gradient

    local settingsList = bg:AddChild("SettingsList", "GenericUI_Element_VerticalList")

    -- Hue slider
    local hueSlider = LabelledSlider.Create(UI, "HueSlider", settingsList, UI.SLIDER_SIZE, TSK.Label_Hue:GetString(), 0, 360, 1)
    -- Update hue upon slider value change.
    hueSlider.Events.HandleReleased:Subscribe(function (ev)
        local newHue = ev.Value
        local currentColor = UI._CurrentColor
        local _, saturation, value = currentColor:ToHSV()
        UI.SetColor(Color.CreateFromHSV(newHue, saturation, value))
    end)
    -- Render a preview image underneath the slider so the user knows the color spectrum at quick glance.
    img = Client.Image.CreateImage(352, 16) -- Hope nobody notices 8 degrees are missing to have the texture width be multiple of 16x lmao
    for _=1,16,1 do
        for hue=1,352,1 do
            local color = Color.CreateFromHSV(hue, 1, 1)
            img:AddPixel(color)
        end
    end
    local hueSliderSpectrum = ImagePrefab.Create(UI, "HueSliderSpectrum", hueSlider.Background, img)
    hueSliderSpectrum:SetSize(hueSlider.Slider:GetWidth() - 40, 25)
    hueSliderSpectrum:SetPositionRelativeToParent("Right", -80, 0)
    hueSliderSpectrum:SetSize(hueSlider.Slider:GetWidth() - 40, 25) -- Needs to called again due to SetPositionRelativeToParent() jank related to restoring scale... bruh
    hueSlider.Background:SetChildIndex(hueSliderSpectrum.Root, 1)
    UI.HueSlider = hueSlider

    -- RGB sliders
    local redSlider = LabelledSlider.Create(UI, "RedSlider", settingsList, UI.SLIDER_SIZE, CommonStrings.Red:GetString(), 0, 255, 1)
    redSlider.Events.HandleReleased:Subscribe(function (ev)
        local newR = ev.Value
        local oldColor = UI._CurrentColor
        UI.SetColor(Color.Create(newR, oldColor.Green, oldColor.Blue), true)
    end)
    local greenSlider = LabelledSlider.Create(UI, "GreenSlider", settingsList, UI.SLIDER_SIZE, CommonStrings.Green:GetString(), 0, 255, 1)
    greenSlider.Events.HandleReleased:Subscribe(function (ev)
        local newG = ev.Value
        local oldColor = UI._CurrentColor
        UI.SetColor(Color.Create(oldColor.Red, newG, oldColor.Blue), true)
    end)
    local blueSlider = LabelledSlider.Create(UI, "BlueSlider", settingsList, UI.SLIDER_SIZE, CommonStrings.Blue:GetString(), 0, 255, 1)
    blueSlider.Events.HandleReleased:Subscribe(function (ev)
        local newB = ev.Value
        local oldColor = UI._CurrentColor
        UI.SetColor(Color.Create(oldColor.Red, oldColor.Green, newB), true)
    end)

    -- Update RGB sliders when color is changed.
    UI.Events.ColorChanged:Subscribe(function (ev)
        local r, g, b = ev.NewColor:Unpack()
        redSlider:SetValue(r)
        greenSlider:SetValue(g)
        blueSlider:SetValue(b)
    end)

    pickerContainer:RepositionElements()
    panelList:RepositionElements()
    settingsList:RepositionElements()
    settingsList:SetPositionRelativeToParent("Top", 0, pickerContainer:GetHeight() + 130) -- Padding is necessary to account for the UI header.

    UI._InitializePreviewWidget()

    -- Confirm button
    local confirmButton = ButtonPrefab.Create(UI, "ConfirmButton", bg, ButtonPrefab.STYLES.GreenMedium)
    confirmButton:SetLabel(CommonStrings.Confirm)
    confirmButton:SetPositionRelativeToParent("Bottom", 0, -23)
    -- Complete the request when the button is pressed.
    -- The UI will be hidden from a RequestCompleted listener.
    confirmButton.Events.Pressed:Subscribe(function (_)
        ColorPicker.CompleteRequest(UI._CurrentRequest.RequestID, UI._CurrentColor)
    end)

    UI._Initialized = true
end

---Initializes the color preview and copy & paste controls widget.
function UI._InitializePreviewWidget()
    if UI._Initialized then return end
    -- Preview widget
    local previewWidget = UI:CreateElement("PreviewWidget", "GenericUI_Element_VerticalList", UI.Background)
    previewWidget:SetElementSpacing(5)
    UI.PreviewWidget = previewWidget

    -- Color square preview
    local colorPreviewContainer = UI:CreateElement("ColorPreviewContainer", "GenericUI_Element_Texture", previewWidget)
    colorPreviewContainer:SetTexture(TEXTURES.FRAMES.SLOT.SILVER_HIGHLIGHTED, (UI.PREVIEW_COLOR_SIZE + UI.PREVIEW_COLOR_PADDING))
    colorPreviewContainer:SetSize((UI.PREVIEW_COLOR_SIZE + UI.PREVIEW_COLOR_PADDING):unpack())
    colorPreviewContainer:SetCenterInLists(true)
    UI.ColorPreviewContainer = colorPreviewContainer

    local colorPreview = UI:CreateElement("ColorPreview", "GenericUI_Element_Color", colorPreviewContainer)
    colorPreview:SetSize(UI.PREVIEW_COLOR_SIZE:unpack())
    colorPreview:SetPositionRelativeToParent("Center")
    UI.Events.ColorChanged:Subscribe(function (ev)
        colorPreview:SetColor(ev.NewColor)
    end)
    UI.ColorPreview = colorPreview

    -- String preview
    local previewLabel = TextPrefab.Create(UI, "RGBLabel", previewWidget, "", "Center", V(200, 30))
    previewLabel:SetCenterInLists(true)
    UI.Events.ColorChanged:Subscribe(function (ev)
        UI._SetTextColorWithStroke(previewLabel, Text.CommonStrings.Preview:GetString(), ev.NewColor)
    end)

    -- Editable html color field
    local htmlField = TextPrefab.Create(UI, "HTMLColorText", previewWidget, "", "Center", V(200, 30))
    htmlField:SetEditable(true)
    htmlField:SetRestrictedCharacters("0123456789ABCDEFabcdef") -- Hex characters.
    htmlField:SetMaxCharacters(7) -- 6 for HTML code + 1 for optional "#" prefix.
    htmlField:SetCenterInLists(true)
    htmlField.Events.TextEdited:Subscribe(function (ev)
        local text = ev.Text
        if Color.IsHexColorCode(text) then
            UI.SetColor(Color.CreateFromHex(text), true)
        end
    end)
    UI.Events.ColorChanged:Subscribe(function (ev)
        if not htmlField:IsFocused() then -- Do not reset the field while the user is typing, as this will hijack the caret position.
            htmlField:SetText(ev.NewColor:ToHex(true))
        end
    end)
    UI.HTMLColorField = htmlField

    -- Unfocus the HTML field when clicking other elements; necessary for the field's color to be updated when changing the color via sliders.
    UI.PickerContainer.Events.MouseDown:Subscribe(function (_)
        htmlField:SetFocused(false)
    end)

    -- Copy & paste buttons
    local buttonBar = UI:CreateElement("CopyPasteButtonList", "GenericUI_Element_HorizontalList", previewWidget)
    buttonBar:SetCenterInLists(true)
    local copyButton = ButtonPrefab.Create(UI, "CopyButton", buttonBar, ButtonPrefab.STYLES.Blue) -- TODO import small textures?
    copyButton:SetLabel(CommonStrings.Copy)
    copyButton.Events.Pressed:Subscribe(function (_)
        local hexColor = UI._CurrentColor:ToHex(true)
        Client.CopyToClipboard(hexColor)
        Notification.ShowNotification(TSK.Notification_ColorCopied:Format(hexColor))
    end)
    local pasteButton = ButtonPrefab.Create(UI, "PasteButton", buttonBar, ButtonPrefab.STYLES.Blue) -- TODO import small textures?
    pasteButton:SetLabel(CommonStrings.Paste)
    pasteButton.Events.Pressed:Subscribe(function (_)
        MsgBox.RequestClipboardText("Features.ColorPicker.Paste")
    end)
    MsgBox.Events.ClipboardTextRequestComplete:RegisterListener(function (id, text)
        if id == "Features.ColorPicker.Paste" then
            text = text:gsub("#", ""):sub(1, 6)
            htmlField:SetFocused(false)
            if Color.IsHexColorCode(text) then
                local newColor = Color.CreateFromHex(text)
                UI.SetColor(newColor, true)
            else
                Notification.ShowNotification(TSK.Notification_InvalidPaste:GetString())
            end
        end
    end)

    buttonBar:RepositionElements()

    previewWidget:RepositionElements()
    previewWidget:SetPositionRelativeToParent("TopRight", -40, 100) -- TODO parent this and gradient to a horizontal list?
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Hide the UI if the request is cancelled or completed for any reason.
local TryHide = function (_)
    UI:TryHide()
end
ColorPicker.Events.RequestCancelled:Subscribe(TryHide)
ColorPicker.Events.ColorPicked:Subscribe(TryHide)

-- Open the UI to handle requests.
ColorPicker.Events.ColorRequested:Subscribe(function (ev)
    UI.Setup(ev)
end, {StringID = "DefaultImplementation"})

-- Show Color Picker on session load in debug mode.
GameState.Events.ClientReady:Subscribe(function (_)
    UI.Setup({RequestID = "Debug", DefaultColor = Color.CreateFromRGB(255, 100, 100)})
end, {EnabledFunctor = function ()
    return ColorPicker:IsDebug()
end})
