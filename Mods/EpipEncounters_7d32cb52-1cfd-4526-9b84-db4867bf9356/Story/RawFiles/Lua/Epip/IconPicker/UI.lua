
local Picker = Epip.GetFeature("Feature_IconPicker")
local Generic = Client.UI.Generic
local TooltipPanelPrefab = Generic.GetPrefab("GenericUI_Prefab_TooltipPanel")
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local CloseButtonPrefab = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local LabelledDropdownPrefab = Generic.GetPrefab("GenericUI_Prefab_LabelledDropdown")
local V = Vector.Create

local UI = Generic.Create("EPIP_IconPicker")
UI.BACKGROUND_SIZE = V(530, 500)
UI.HEADER_SIZE = V(UI.BACKGROUND_SIZE[1], 50)
UI.CONTENT_SIZE = V(470, UI.BACKGROUND_SIZE[2] - 150)
UI.GRID_WIDTH = 450
UI.ICON_SIZE = V(64, 64)
UI.SETTINGS_PANEL_SIZE = V(400, UI.BACKGROUND_SIZE[2])
UI.SETTINGS_HEADER_SIZE = V(UI.SETTINGS_PANEL_SIZE[1], 50)
UI.SETTINGS_FORM_ELEMENT_SIZE = V(UI.SETTINGS_PANEL_SIZE[1] - 25, 50)
UI._Initialized = false

---------------------------------------------
-- METHODS
---------------------------------------------

---Shows the UI.
function UI.Show()
    UI._Initialize()

    UI._UpdateIcons()

    UI:SetPositionRelativeToViewport("center", "center")
    Client.UI._BaseUITable.Show(UI)
end

---Updates the list of icons.
function UI._UpdateIcons()
    local iconType = Picker:GetSettingValue(Picker.Settings.IconType)
    local grid = UI.IconGrid
    local icons = UI.GetIcons(iconType)

    grid:ClearElements()
    
    for _,icon in ipairs(icons) do
        local element = grid:AddChild(icon, "GenericUI_Element_IggyIcon")
        element:SetIcon(icon, UI.ICON_SIZE:unpack())

        -- TODO replace with mouse up
        element.Events.MouseDown:Subscribe(function (_)
            Picker.PickIcon(icon)
            Timer.Start(0.1, function (_)
                UI:Hide()
                Client.Tooltip.HideTooltip()
            end)
        end)
        element.Events.MouseOver:Subscribe(function (_)
            UI.HoveredIconLabel:SetText(icon)
        end)
        element:SetTooltip("Simple", icon)
    end

    UI.ContentScrollList:RepositionElements()
end

---Returns the icons to render.
---@param iconType Feature_IconPicker_IconType
---@return icon[]
function UI.GetIcons(iconType)
    local iconSet = Picker.GetIcons(iconType)
    local icons = {}

    for icon in iconSet:Iterator() do
        table.insert(icons, icon)
    end

    -- Sort alphabetically
    table.sort(icons, function (a, b)
        return a > b
    end)
    
    return icons
end

---Initializes the UI's elements.
function UI._Initialize()
    if not UI._Initialized then
        local bg = TooltipPanelPrefab.Create(UI, "Background", nil, UI.BACKGROUND_SIZE, Text.Format(Picker.TranslatedStrings.UI_Header:GetString(), {Size = 23}), UI.HEADER_SIZE)
        local closeButton = CloseButtonPrefab.Create(UI, "CloseButton", bg.Background)
        closeButton:SetPositionRelativeToParent("TopRight", -10, 10)

        local scrollList = bg:AddChild("IconScrollList", "GenericUI_Element_ScrollList")
        scrollList:SetFrame(UI.CONTENT_SIZE:unpack())
        scrollList:SetMouseWheelEnabled(true)
        scrollList:SetScrollbarSpacing(-10)
        scrollList:SetPositionRelativeToParent("TopLeft", 20, 80)

        local grid = scrollList:AddChild("Grid", "GenericUI_Element_Grid")
        local columnCount = math.floor(UI.GRID_WIDTH / UI.ICON_SIZE[1])
        grid:SetGridSize(columnCount, -1)

        local hoveredIconLabel = TextPrefab.Create(UI, "HoveredIconLabel", bg.Background, "", "Center", UI.HEADER_SIZE) -- TODO size
        hoveredIconLabel:SetPositionRelativeToParent("Bottom", 0, 5)

        local settingsPanel = TooltipPanelPrefab.Create(UI, "SettingsPanel", bg.Background, UI.SETTINGS_PANEL_SIZE, Text.Format(Text.CommonStrings.Filters:GetString(), {Size = 23}), UI.SETTINGS_HEADER_SIZE)
        settingsPanel.Background:SetPositionRelativeToParent("Right", UI.SETTINGS_PANEL_SIZE[1], 0)
        local settingsList = settingsPanel.Background:AddChild("SettingsList", "GenericUI_Element_VerticalList")
        settingsList:SetPositionRelativeToParent("TopLeft", 20, 100)

        UI._RenderComboBoxFromSetting(Picker.Settings.IconType, settingsList, UI.SETTINGS_FORM_ELEMENT_SIZE, function (_)
            Picker:DebugLog("Icon type changed")
            UI._UpdateIcons()
        end)

        UI.ContentScrollList = scrollList
        UI.IconGrid = grid
        UI.HoveredIconLabel = hoveredIconLabel

        UI:SetPanelSize(V(UI.BACKGROUND_SIZE[1] + UI.SETTINGS_PANEL_SIZE[1], UI.BACKGROUND_SIZE[2]))

        UI._Initialized = true
    end
end

---Renders a checkbox to the settings panel from a setting.
---TODO extract these kinds of methods into a feature
---@param setting SettingsLib_Setting_Choice
---@param parent string|GenericUI_Element
---@param size Vector2
---@param callback fun(ev:GenericUI_Element_ComboBox_Event_OptionSelected)?
function UI._RenderComboBoxFromSetting(setting, parent, size, callback)
    -- Generate combobox options from setting choices.
    local options = {}
    for _,choice in ipairs(setting.Choices) do
        table.insert(options, {
            ID = choice.ID,
            Label = choice:GetName(),
        })
    end

    local dropdown = LabelledDropdownPrefab.Create(UI, setting.ID, parent, setting:GetName(), options)
    dropdown:SetSize(size:unpack())
    dropdown:SelectOption(setting:GetValue())

    -- Set setting value and refresh UI.
    dropdown.Events.OptionSelected:Subscribe(function (ev)
        Settings.SetValue(setting.ModTable, setting.ID, ev.Option.ID)
        if callback then
            callback(ev)
        end
    end)
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register the UI as the default picker.
Picker.SetDefaultUI(UI)

Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == "EpipEncounters_Debug_Generic" then
        Picker.Open("test")
    end
end)