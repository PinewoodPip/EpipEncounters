
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local LabelledCheckbox = Generic.GetPrefab("GenericUI_Prefab_LabelledCheckbox")
local FormEntry = Generic.GetPrefab("GenericUI_Prefab_FormHorizontalList")

---@class Feature_DebugMenu
local DebugMenu = Epip.GetFeature("DebugMenu")
DebugMenu.UI = nil ---@type GenericUI_Instance
DebugMenu.BG_SIZE = Vector.Create(1200, 800)
DebugMenu.CONTENT_SIZE = Vector.Create(1000, 800)
DebugMenu.GRID_CELL_SIZE = Vector.Create(150, 50)
DebugMenu.FORM_ENTRY_SIZE = Vector.Create(1000, 40)
DebugMenu.FORM_ENTRY_LABEL_SIZE = Vector.Create(500, 40)
DebugMenu.CHECKBOX_SIZE = Vector.Create(80, 40)
DebugMenu.DROPDOWN_SIZE = Vector.Create(250, 40)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param path string?
function DebugMenu.LoadConfig(path)
    path = path or DebugMenu.SAVE_FILENAME

    local config = Utilities.LoadJson(path)

    -- No backwards compatibility for DebugMenu configs.
    if config and config.Version == DebugMenu.SAVE_VERSION then
        for modTable,features in pairs(config.State) do
            for id,storedState in pairs(features) do
                local state = DebugMenu.GetState(modTable, id)
                local feature = state:GetFeature()

                state.Debug = storedState.Debug
                state.Enabled = storedState.Enabled
                state.LoggingLevel = storedState.LoggingLevel

                feature.Logging = state.LoggingLevel

                if not state.Enabled then -- TODO improve
                    feature:Disable("DebugMenu")
                end

                feature.IS_DEBUG = state.Debug
            end
        end
    end
end

---@param path string?
function DebugMenu.SaveConfig(path)
    local save = {State = table.deepCopy(DebugMenu.State)}
    save.Version = DebugMenu.SAVE_VERSION

    Utilities.SaveJson(path or DebugMenu.SAVE_FILENAME, save)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

GameState.Events.GamePaused:Subscribe(function (_)
    DebugMenu.SaveConfig()
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function DebugMenu._PopulateFeatureList()
    local list = DebugMenu.UI.ScrollList
    local headerFormatting = {Color = Color.BLACK} ---@type TextFormatData
    local ui = DebugMenu.UI

    local header = FormEntry.Create(ui, "Header", list, Text.Format("Feature & Source", headerFormatting), DebugMenu.FORM_ENTRY_SIZE, DebugMenu.FORM_ENTRY_LABEL_SIZE)
    -- header.Label:SetType("Center") -- TODO fix
    local debugModeHeader = TextPrefab.Create(ui, "DebugHeader", header.List, Text.Format("Debug", headerFormatting), "Center", DebugMenu.CHECKBOX_SIZE)
    TextPrefab.Create(ui, "LoggingHeader", header.List, Text.Format("Logging", headerFormatting), "Center", DebugMenu.DROPDOWN_SIZE)

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

            local checkbox = formList:AddChild(featureID .. "_Debug", "GenericUI_Element_StateButton")
            checkbox:SetType("CheckBox")
            checkbox:SetActive(feature:IsDebug())
            checkbox:SetSizeOverride(DebugMenu.CHECKBOX_SIZE)
            checkbox.Events.StateChanged:Subscribe(function (ev)
                local state = DebugMenu.GetState(mod, featureID)

                state.Debug = ev.Active

                state:GetFeature().IS_DEBUG = ev.Active
            end)

            local sourceText = TextPrefab.Create(DebugMenu.UI, featureID .. "_Source", formList.Label, sourceLabel, "Right", DebugMenu.FORM_ENTRY_LABEL_SIZE)
            sourceText:Move(0, 10)

            -- Logging dropdown
            local combo = formList:AddChild("LoggingCombo", "GenericUI_Element_ComboBox")
            combo:SetOptions({
                {ID = 0, Label = "Normal"},
                {ID = 1, Label = "Warnings"},
                {ID = 2, Label = "Errors"},
            })
            combo:SelectOption(feature.Logging)
            combo.Events.OptionSelected:Subscribe(function (ev)
                local state = DebugMenu.GetState(mod, featureID)

                state.LoggingLevel = ev.Option.ID
                state:GetFeature().Logging = state.LoggingLevel
            end)
        end
    end

    DebugMenu.UI.ScrollList:RepositionElements()
end

function DebugMenu:__Setup()
    local ui = Generic.Create("PIP_DebugMenu")
    local bg = ui:CreateElement("BG", "GenericUI_Element_TiledBackground")
    bg:SetBackground("Note", DebugMenu.BG_SIZE:unpack())
    -- bg:SetAsDraggableArea()

    local content = bg:AddChild("Content", "GenericUI_Element_ScrollList")
    content:SetSize(DebugMenu.CONTENT_SIZE:unpack())
    content:SetPositionRelativeToParent("Top", 0, 120)
    content:SetMouseWheelEnabled(true)
    content:SetElementSpacing(0)

    DebugMenu.UI = ui
    DebugMenu.UI.ScrollList = content

    DebugMenu.LoadConfig()
    DebugMenu._PopulateFeatureList()
end