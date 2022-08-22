
local Generic = Client.UI.Generic
local TextPrefab = Generic.GetPrefab("GenericUI_Prefab_Text")
local LabelledCheckbox = Generic.GetPrefab("GenericUI_Prefab_LabelledCheckbox")

---@class Feature_DebugMenu
local DebugMenu = Epip.GetFeature("DebugMenu")
DebugMenu.UI = nil ---@type GenericUI_Instance
DebugMenu.BG_SIZE = Vector.Create(1200, 800)
DebugMenu.CONTENT_SIZE = Vector.Create(1000, 800)
DebugMenu.TEXT_SIZING = Vector.Create(400, 30)
DebugMenu.GRID_CELL_SIZE = Vector.Create(150, 50)
DebugMenu.TEXT_GRID_CELL_SIZE = Vector.Create(400, 50)

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
                state.ShutUp = storedState.ShutUp

                if state.ShutUp then
                    feature:ShutUp()
                end

                if not state.Enabled then
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
    local grid = DebugMenu.UI.Grid
    local headerFormatting = {Color = Color.BLACK, Size = 25} ---@type TextFormatData

    TextPrefab.Create(DebugMenu.UI, "Header_Feature", grid, Text.Format("Feature", headerFormatting), "Center", DebugMenu.TEXT_GRID_CELL_SIZE)
    TextPrefab.Create(DebugMenu.UI, "Header_Debug", grid, Text.Format("Debug", headerFormatting), "Center", DebugMenu.GRID_CELL_SIZE)

    for mod,featureTable in pairs(Epip._Features) do

        local features = {}
        for _,feature in pairs(featureTable.Features) do
            table.insert(features, feature)
        end
        table.sortByProperty(features, "MODULE_ID")

        for i,feature in pairs(features) do
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

            local text = TextPrefab.Create(DebugMenu.UI, "FeatureName_" .. i, grid, labelText, "Left", DebugMenu.TEXT_GRID_CELL_SIZE)

            local checkbox = grid:AddChild(featureID .. "_Debug", "GenericUI_Element_StateButton")
            checkbox:SetType("CheckBox")
            checkbox:SetActive(feature:IsDebug())
            checkbox:SetSizeOverride(DebugMenu.GRID_CELL_SIZE)
            checkbox.Events.StateChanged:Subscribe(function (ev)
                local state = DebugMenu.GetState(mod, featureID)

                state.Debug = ev.Active

                state:GetFeature().IS_DEBUG = ev.Active
            end)

            local sourceText = TextPrefab.Create(DebugMenu.UI, featureID .. "_Source", text:GetMainElement(), sourceLabel, "Right", DebugMenu.TEXT_GRID_CELL_SIZE)
            sourceText:Move(0, 10)
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

    -- Grid
    local grid = content:AddChild("Grid", "GenericUI_Element_Grid")
    grid:SetGridSize(2, 999)

    DebugMenu.UI = ui
    DebugMenu.UI.Grid = grid
    DebugMenu.UI.ScrollList = content

    DebugMenu.LoadConfig()
    DebugMenu._PopulateFeatureList()
end