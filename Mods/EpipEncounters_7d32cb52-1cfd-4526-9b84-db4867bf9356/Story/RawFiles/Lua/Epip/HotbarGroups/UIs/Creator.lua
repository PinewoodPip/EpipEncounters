
local Generic = Client.UI.Generic
local Spinner = Generic.GetPrefab("GenericUI_Prefab_Spinner")
local CloseButton = Generic.GetPrefab("GenericUI_Prefab_CloseButton")

local GroupManager = Epip.GetFeature("Features.HotbarGroups") ---@cast GroupManager Features.HotbarGroups.Client
local TSK = GroupManager.TranslatedStrings

---@class Features.HotbarGroups.UI.Editor : GenericUI_Instance
---@field RowSpinner GenericUI_Prefab_Spinner
---@field ColumnSpinner GenericUI_Prefab_Spinner
---@field ConfirmButton GenericUI_Element_Button

---@param UIName string
---@param HeaderText string
---@param ButtonText string
---@return Features.HotbarGroups.UI.Editor
function GroupManager._CreateEditor(UIName, HeaderText, ButtonText)
    local ui = Generic.Create("Features.HotbarGroups.UI.Editor." .. UIName) ---@cast ui Features.HotbarGroups.UI.Editor

    local bg = ui:CreateElement("BG", "GenericUI_Element_TiledBackground")
    bg:SetBackground("RedPrompt", GroupManager.UI_WIDTH, GroupManager.UI_HEIGHT)
    local uiObject = ui:GetUI()
    uiObject.SysPanelSize = {GroupManager.UI_WIDTH, GroupManager.UI_HEIGHT}

    local closeButton = CloseButton.Create(ui, "CloseButton", bg)
    closeButton:SetPositionRelativeToParent("TopRight", -25, 25)

    -- Content
    local content = bg:AddChild("Content", "GenericUI_Element_VerticalList")
    content:SetSize(GroupManager.CONTENT_WIDTH, GroupManager.UI_HEIGHT)
    content:SetPosition(27, 60)

    local text = content:AddChild("Header", "GenericUI_Element_Text")
    text:SetText(Text.Format(HeaderText, {Color = Color.WHITE, Size = 23}))
    text:SetStroke(Color.Create(0, 0, 0), 1, 1, 1, 5)
    text:SetSize(GroupManager.CONTENT_WIDTH, 50)

    local rowSpinner = Spinner.Create(ui, "RowSpinner", content, TSK.RowsSpinner:GetString(), 1, 20, 1)
    local columnSpinner = Spinner.Create(ui, "ColumnSpinner", content, TSK.ColumnsSpinner:GetString(), 1, 20, 1)

    rowSpinner:SetCenterInLists(true)
    columnSpinner:SetCenterInLists(true)

    ui.RowSpinner = rowSpinner
    ui.ColumnSpinner = columnSpinner

    content:AddChild("Filler", "GenericUI_Element_Empty"):GetMovieClip().heightOverride = 175

    local createButton = content:AddChild("Confirm", "GenericUI_Element_Button")
    createButton:SetCenterInLists(true)
    createButton:SetType("Red")
    createButton:SetText(ButtonText, 4)
    ui.ConfirmButton = createButton

    content:SetElementSpacing(0)

    content:RepositionElements()

    ui:Hide()

    return ui
end

GameState.Events.ClientReady:Subscribe(function (ev)
    local Creator = GroupManager._CreateEditor("Creator",
    TSK.CreateGroupHeader:GetString(), TSK.CreateGroupButton:GetString())
    GroupManager.CreationUI = Creator
    Creator.ConfirmButton.Events.Pressed:Subscribe(function (_)
        GroupManager.Create(nil, Creator.RowSpinner:GetValue(), Creator.ColumnSpinner:GetValue())
        GroupManager.CreationUI:Hide()
    end)

    local Editor = GroupManager._CreateEditor("Editor",
    TSK.ResizeGroupHeader:GetString(), TSK.ResizeGroupButton:GetString())
    GroupManager.ResizeUI = Editor
    Editor.ConfirmButton.Events.Pressed:Subscribe(function (_)
        GroupManager.ResizeGroup(GroupManager._CurrentGroupGUID)
        GroupManager.ResizeUI:Hide()
    end)
end)