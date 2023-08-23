
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local FormEntry = Generic.GetPrefab("GenericUI_Prefab_FormHorizontalList")

---@class Feature_DebugMenu
local DebugMenu = Epip.GetFeature("DebugMenu")
DebugMenu.UI = nil ---@type GenericUI_Instance
DebugMenu.BG_SIZE = Vector.Create(1600, 1100)
DebugMenu.CONTENT_SIZE = Vector.Create(1400, 870)
DebugMenu.GRID_CELL_SIZE = Vector.Create(150, 50)
DebugMenu.FORM_ENTRY_SIZE = Vector.Create(1400, 40)
DebugMenu.FORM_ENTRY_LABEL_SIZE = Vector.Create(500, 40)
DebugMenu.CHECKBOX_SIZE = Vector.Create(80, 40)
DebugMenu.DROPDOWN_SIZE = Vector.Create(250, 40)
DebugMenu.INFO_SIZE = Vector.Create(250, 40)
DebugMenu.BUTTON_SIZE = Vector.Create(250, 40)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_DebugMenu_FeatureEntry
---@field Feature Feature
---@field Source string

---------------------------------------------
-- METHODS
---------------------------------------------

---@param features Feature_DebugMenu_FeatureEntry[]
function DebugMenu._RenderFeatures(features)
    local list = DebugMenu.UI.ScrollList
    local ui = DebugMenu.UI

    for _,featureData in pairs(features) do
        local feature = featureData.Feature
        local mod = featureData.Source
        local featureID = feature:GetFeatureID()
        local state = DebugMenu.GetState(mod, featureID)
        feature = feature ---@type Feature

        local labelText = Text.Format("%s", {
            FormatArgs = {featureID},
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
            {ID = "0", Label = "Normal"},
            {ID = "1", Label = "Warnings & Errors Only"},
            {ID = "2", Label = "Errors Only"},
        })
        combo:SelectOption(tostring(feature.Logging))
        combo.Events.OptionSelected:Subscribe(function (ev)
            DebugMenu.SetLoggingState(mod, featureID, tonumber(ev.Option.ID))
        end)

        -- Testing status
        local testLabel = TextPrefab.Create(ui, featureID .. "_TestingLabel", formList.List, state:GetTestingLabel(), "Left", DebugMenu.INFO_SIZE)

        local testButton = formList:AddChild("TestButton", "GenericUI_Element_Button")
        testButton:SetType("Red")
        testButton:SetText("Run Tests", 4)
        testButton:SetEnabled(#feature._Tests > 0)
        testButton.Events.Pressed:Subscribe(function (_)
            testLabel:SetText(Text.Format("Running...", {Color = Color.BLACK}))

            state:RunTests()

            Timer.Start(state.TEST_CHECK_DELAY, function (_)
                DebugMenu:Log("Tests finished for " .. featureID)
                testLabel:SetText(state:GetTestingLabel())
            end)
        end)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Save config when the game is paused.
GameState.Events.GamePaused:Subscribe(function (_)
    DebugMenu.SaveConfig()
end)

-- Listen for keybind to open the menu.
Client.Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action.ID == "EpipEncounters_Debug_OpenDebugMenu" then
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

    list:Clear()

    -- Setup header
    local header = FormEntry.Create(ui, "Header", list, Text.Format("Feature & Source Mod", headerFormatting), DebugMenu.FORM_ENTRY_SIZE, DebugMenu.FORM_ENTRY_LABEL_SIZE)
    header.SELECTED_BG_ALPHA = 0 -- Do not highlight the header entry upon hover

    TextPrefab.Create(ui, "DebugHeader", header.List, Text.Format("Debug", headerFormatting), "Center", DebugMenu.CHECKBOX_SIZE)
    TextPrefab.Create(ui, "EnabledHeader", header.List, Text.Format("Enabled", headerFormatting), "Center", DebugMenu.CHECKBOX_SIZE)
    TextPrefab.Create(ui, "LoggingHeader", header.List, Text.Format("Logging", headerFormatting), "Center", DebugMenu.DROPDOWN_SIZE)
    TextPrefab.Create(ui, "TestStatusHeader", header.List, Text.Format("Test Status", headerFormatting), "Center", DebugMenu.INFO_SIZE)
    TextPrefab.Create(ui, "TestButtonHeader", header.List, Text.Format("Test", headerFormatting), "Center", DebugMenu.BUTTON_SIZE)

    local divider = list:AddChild("HeaderDivider", "GenericUI_Element_Divider")
    divider:SetType("Line")
    divider:SetSize(DebugMenu.FORM_ENTRY_SIZE:unpack())

    local features = {} ---@type Feature_DebugMenu_FeatureEntry[]

    -- Add actual features.
    for mod,featureTable in pairs(Epip._Features) do
        for _,feature in pairs(featureTable.Features) do
            table.insert(features, {Feature = feature, Source = mod, SORTING_KEY = feature.MODULE_ID})
        end
    end

    -- Add UI libraries.
    for id,lib in pairs(Client.UI) do
        if lib.MODULE_ID then
            table.insert(features, {Feature = lib, Source = "_Client", SORTING_KEY = "xxx_" .. id})
        end
    end
    table.sortByProperty(features, "SORTING_KEY")

    DebugMenu._RenderFeatures(features)

    DebugMenu.UI.ScrollList:RepositionElements()
end

function DebugMenu:__Setup()
    local ui = Generic.Create("PIP_DebugMenu")
    local uiObject = ui:GetUI()
    local bg = ui:CreateElement("BG", "GenericUI_Element_TiledBackground")
    bg:SetBackground("Note", DebugMenu.BG_SIZE:unpack())

    local content = bg:AddChild("Content", "GenericUI_Element_ScrollList")
    content:SetSize(DebugMenu.CONTENT_SIZE:unpack())
    content:SetPositionRelativeToParent("Top", 0, 80)
    content:SetRepositionAfterAdding(false)
    content:SetMouseWheelEnabled(true)
    content:SetElementSpacing(0)

    local closeButton = bg:AddChild("Close", "GenericUI_Element_Button")
    closeButton:SetType("Close")
    closeButton:SetPositionRelativeToParent("TopRight", -60, 60)
    closeButton.Events.Pressed:Subscribe(function (_)
        DebugMenu.SaveConfig() -- Save on close.
        DebugMenu.UI:Hide()
    end)

    DebugMenu.UI = ui
    DebugMenu.UI.ScrollList = content

    ui.Show = function()
        DebugMenu._PopulateFeatureList()
        Client.UI._BaseUITable.Show(ui)
    end

    -- Set UI bounds
    uiObject.SysPanelSize = DebugMenu.BG_SIZE
    ui:ExternalInterfaceCall("registerAnchorId", "PIP_DebugMenu")
    ui:ExternalInterfaceCall("setAnchor", "center", "screen", "center")

    DebugMenu.UI:Hide()
end