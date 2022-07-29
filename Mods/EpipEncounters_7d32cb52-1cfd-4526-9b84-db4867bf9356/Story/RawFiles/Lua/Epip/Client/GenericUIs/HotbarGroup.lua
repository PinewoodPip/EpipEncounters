
local Generic = Client.UI.Generic
local HotbarSlot = Generic.PREFABS.HotbarSlot ---@type GenericUI_Prefab_HotbarSlot

local GroupManager = {
    UI = nil, ---@type GenericUI_Instance
    Groups = {}, ---@type table<string, HotbarGroup>

    nextID = 0,

    CONTENT_WIDTH = 450,
    UI_WIDTH = 500,
    UI_HEIGHT = 600,
}
Epip.AddFeature("HotbarGroupManager", "HotbarGroupManager", GroupManager)

function GroupManager.Setup()
    local ui = GroupManager.UI

    ui:ExternalInterfaceCall("setPosition", "center", "screen", "center")
    ui:Show()
end

---------------------------------------------
-- HOTBAR GROUP
---------------------------------------------

---@class HotbarGroup
local HotbarGroup = {
    UI = nil, ---@type GenericUI_Instance
    ROWS = 3,
    COLUMNS = 3,
    SLOT_SIZE = 50,
    SLOT_SPACING = 0,

    ELEMENT_ROWS = {

    }
}

---@return number, number -- Width, height
function HotbarGroup:GetSlotAreaSize()
    local width = self.COLUMNS * self.SLOT_SIZE + (self.COLUMNS - 1) * self.SLOT_SPACING
    local height = self.ROWS * self.SLOT_SIZE + (self.ROWS - 1) * self.SLOT_SPACING

    return width, height
end

function HotbarGroup:_Init()
    local content = self.UI:CreateElement("ContentContainer", "TiledBackground")
    content:SetAlpha(0)
    content:SetBackground(1, self:GetSlotAreaSize())

    local container = content:AddChild("container", "VerticalList")
    container:SetElementSpacing(HotbarGroup.SLOT_SPACING - 4)
    container:SetPosition(3, 3)

    for i=1,self.ROWS,1 do
        local row = container:AddChild("Row_" .. i, "HorizontalList")
        row:SetElementSpacing(HotbarGroup.SLOT_SPACING)

        HotbarGroup.ELEMENT_ROWS[i] = {}

        for z=1,self.COLUMNS,1 do
            local slot = HotbarSlot.Create(self.UI, "Row_" .. i .. "_Slot_" .. z, row)

            HotbarGroup.ELEMENT_ROWS[i][z] = slot
        end
    end

    local dragArea = container:AddChild("DragArea", "Button")
    dragArea:SetEnabled(false)
    dragArea:SetText(Text.Format("Click here to drag", {Color = Color.COLORS.WHITE}))
    dragArea:SetAsDraggableArea()
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param id string
---@return HotbarGroup
function GroupManager.Create(id, rows, columns)
    ---@type HotbarGroup
    local group = {
        ROWS = rows,
        COLUMNS = columns,
    }
    Inherit(group, HotbarGroup)

    group.UI = Generic.Create(id)

    group:_Init()

    return group
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.ContextMenu.RegisterElementListener("hotBarRow_CreateGroup", "buttonPressed", function(_)
    GroupManager.Setup()
end)

---------------------------------------------
-- SETUP
---------------------------------------------

function GroupManager:__Setup()
    local ui = Generic.Create("PIP_HotbarGroup") ---@type GenericUI_Instance
    GroupManager.UI = ui

    local bg = ui:CreateElement("BG", "TiledBackground")
    bg:SetBackground(0, GroupManager.UI_WIDTH, GroupManager.UI_HEIGHT)
    local uiObject = ui:GetUI()
    uiObject.SysPanelSize = {GroupManager.UI_WIDTH, GroupManager.UI_HEIGHT}

    -- Content
    local content = bg:AddChild("Content", "VerticalList")
    content:SetSize(GroupManager.CONTENT_WIDTH, 600)
    content:SetPosition(27, 60)

    local text = content:AddChild("Header", "Text")
    text:SetText(Text.Format("Create Hotbar Group", {Color = Color.COLORS.WHITE, Size = 23}))
    text:SetStroke(Color.Create(0, 0, 0), 1, 1, 1, 5)
    text:SetType(1)
    text:SetSize(GroupManager.CONTENT_WIDTH, 50)

    local rowSpinner = Generic.PREFABS.Spinner.Create(ui, "RowSpinner", content, "Rows", 1, 20, 1)
    local columnSpinner = Generic.PREFABS.Spinner.Create(ui, "ColumnSpinner", content, "Columns", 1, 20, 1)

    rowSpinner:GetMainElement():SetCenterInLists(true)
    columnSpinner:GetMainElement():SetCenterInLists(true)

    content:AddChild("Filler", "Empty"):GetMovieClip().heightOverride = 300

    local createButton = content:AddChild("Confirm", "Button")
    createButton.Events.Pressed:Subscribe(function(_)
        GroupManager.Create(tostring(GroupManager.nextID), rowSpinner:GetValue(), columnSpinner:GetValue())
        GroupManager.nextID = GroupManager.nextID + 1
        GroupManager.UI:Hide()
    end)
    createButton:SetCenterInLists(true)
    createButton:SetType(1)
    createButton:SetText("Create", 4)

    content:SetElementSpacing(0)

    content:RepositionElements()

    ui:Hide()
end

---------------------------------------------
-- TESTS
---------------------------------------------

-- Ext.Events.SessionLoaded:Subscribe(function (e)
--     if Epip.IsDeveloperMode(true) then
--         local group = GroupManager.Create("test")
--     end
-- end)