
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local FormEntry = Generic.GetPrefab("GenericUI_Prefab_FormHorizontalList")

---@class Feature_DebugMenu
local DebugMenu = Epip.GetFeature("DebugMenu")
DebugMenu.UI = nil ---@type GenericUI_Instance
DebugMenu.BG_SIZE = Vector.Create(1200, 1100)
DebugMenu.CONTENT_SIZE = Vector.Create(1000, 870)
DebugMenu.GRID_CELL_SIZE = Vector.Create(150, 50)
DebugMenu.FORM_ENTRY_SIZE = Vector.Create(1000, 40)
DebugMenu.FORM_ENTRY_LABEL_SIZE = Vector.Create(500, 40)
DebugMenu.CHECKBOX_SIZE = Vector.Create(80, 40)
DebugMenu.DROPDOWN_SIZE = Vector.Create(250, 40)

---------------------------------------------
-- METHODS
---------------------------------------------

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Save config when the game is paused.
GameState.Events.GamePaused:Subscribe(function (_)
    DebugMenu.SaveConfig()
end)

-- Listen for keybind to open the menu.
Client.UI.OptionsInput.Events.ActionExecuted:RegisterListener(function (action, _)
    if action == "EpipEncounters_Debug_OpenDebugMenu" then
        local ui = DebugMenu.UI

        if ui:IsVisible() then
            ui:Hide()
        else
            ui:Show()
        end
    end
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function DebugMenu._PopulateFeatureList()
    local list = DebugMenu.UI.ScrollList
    local headerFormatting = {Color = Color.BLACK} ---@type TextFormatData
    local ui = DebugMenu.UI

    -- Setup header
    local header = FormEntry.Create(ui, "Header", list, Text.Format("Feature & Source Mod", headerFormatting), DebugMenu.FORM_ENTRY_SIZE, DebugMenu.FORM_ENTRY_LABEL_SIZE)
    header.SELECTED_BG_ALPHA = 0 -- Do not highlight this entry upon hover
    -- header.Label:SetType("Center") -- TODO fix
    local debugModeHeader = TextPrefab.Create(ui, "DebugHeader", header.List, Text.Format("Debug", headerFormatting), "Center", DebugMenu.CHECKBOX_SIZE)
    TextPrefab.Create(ui, "EnabledHeader", header.List, Text.Format("Enabled", headerFormatting), "Center", DebugMenu.CHECKBOX_SIZE)
    TextPrefab.Create(ui, "LoggingHeader", header.List, Text.Format("Logging", headerFormatting), "Center", DebugMenu.DROPDOWN_SIZE)

    local divider = list:AddChild("HeaderDivider", "GenericUI_Element_Divider")
    divider:SetType("Line")
    divider:SetSize(DebugMenu.FORM_ENTRY_SIZE:unpack())

    for mod,featureTable in pairs(Epip._Features) do

        local features = {}
        for _,feature in pairs(featureTable.Features) do
            table.insert(features, feature)
        end
        table.sortByProperty(features, "MODULE_ID")

        for _,feature in pairs(features) do
            feature = feature ---@type Feature

            local featureID = feature.MODULE_ID
            local labelText = Text.Format("%s", {
                FormatArgs = {feature.MODULE_ID},
                Color = Color.BLACK,
            })
            local sourceLabel = Text.Format("(%s)", {
                FormatArgs = {mod},
                Size = 13,
                Color = Color.BLACK,
            })

            local formList = FormEntry.Create(ui, featureID, list, labelText, DebugMenu.FORM_ENTRY_SIZE, DebugMenu.FORM_ENTRY_LABEL_SIZE)

            -- "Debug" checkbox.
            local checkbox = formList:AddChild(featureID .. "_Debug", "GenericUI_Element_StateButton")
            checkbox:SetType("CheckBox")
            checkbox:SetActive(feature:IsDebug())
            checkbox:SetSizeOverride(DebugMenu.CHECKBOX_SIZE)
            checkbox.Events.StateChanged:Subscribe(function (ev)
                DebugMenu.SetDebugState(mod, featureID, ev.Active)
            end)

            -- "Enabled" checkbox.
            local enabledCheckbox = formList:AddChild("Enabled", "GenericUI_Element_StateButton")
            enabledCheckbox:SetType("CheckBox")
            enabledCheckbox:SetActive(feature:IsEnabled())
            enabledCheckbox:SetSizeOverride(DebugMenu.CHECKBOX_SIZE)
            enabledCheckbox.Events.StateChanged:Subscribe(function (ev)
                DebugMenu.SetEnabledState(mod, featureID, ev.Active)
            end)

            local sourceText = TextPrefab.Create(DebugMenu.UI, featureID .. "_Source", formList.Label, sourceLabel, "Right", DebugMenu.FORM_ENTRY_LABEL_SIZE)
            sourceText:Move(0, 10)

            -- Logging dropdown
            local combo = formList:AddChild("LoggingCombo", "GenericUI_Element_ComboBox")
            combo:SetOptions({
                {ID = 0, Label = "Normal"},
                {ID = 1, Label = "Warnings & Errors Only"},
                {ID = 2, Label = "Errors Only"},
            })
            combo:SelectOption(feature.Logging)
            combo.Events.OptionSelected:Subscribe(function (ev)
                DebugMenu.SetLoggingState(mod, featureID, ev.Option.ID)
            end)
        end
    end

    DebugMenu.UI.ScrollList:RepositionElements()
end

function DebugMenu:__Setup()
    local ui = Generic.Create("PIP_DebugMenu")
    local uiObject = ui:GetUI()
    local bg = ui:CreateElement("BG", "GenericUI_Element_TiledBackground")
    bg:SetBackground("Note", DebugMenu.BG_SIZE:unpack())
    -- bg:SetAsDraggableArea()

    local content = bg:AddChild("Content", "GenericUI_Element_ScrollList")
    content:SetSize(DebugMenu.CONTENT_SIZE:unpack())
    content:SetPositionRelativeToParent("Top", 0, 80)
    content:SetMouseWheelEnabled(true)
    content:SetElementSpacing(0)

    local closeButton = bg:AddChild("Close", "GenericUI_Element_Button")
    closeButton:SetType("Close")
    closeButton:SetPositionRelativeToParent("TopRight", -60, 60)
    closeButton.Events.Pressed:Subscribe(function (_)
        DebugMenu.UI:Hide()
    end)

    DebugMenu.UI = ui
    DebugMenu.UI.ScrollList = content

    DebugMenu._PopulateFeatureList()

    -- Set UI bounds
    uiObject.SysPanelSize = DebugMenu.BG_SIZE
    ui:ExternalInterfaceCall("registerAnchorId", "PIP_DebugMenu")
    ui:ExternalInterfaceCall("setAnchor", "center", "screen", "center")
    -- ui:SetPosition("center", "center")

    DebugMenu.UI:Hide()
end