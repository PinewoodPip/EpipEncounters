
local Generic = Client.UI.Generic
local HotbarSlot = Generic.GetPrefab("GenericUI_Prefab_HotbarSlot")
local Spinner = Generic.GetPrefab("GenericUI_Prefab_Spinner")
local CloseButton = Generic.GetPrefab("GenericUI_Prefab_CloseButton")
local ContextMenu = Client.UI.ContextMenu
local CommonStrings = Text.CommonStrings

---@class Feature_HotbarGroupManager : Feature
local GroupManager = {
    CreationUI = nil, ---@type GenericUI_Instance
    CreateRowSpinner = nil, ---@type GenericUI_Prefab_Spinner
    CreateColSpinner = nil, ---@type GenericUI_Prefab_Spinner

    ResizeUI = nil, ---@type GenericUI_Instance
    ResizeRowSpinner = nil, ---@type GenericUI_Prefab_Spinner
    ResizeColSpinner = nil, ---@type GenericUI_Prefab_Spinner

    Groups = {}, ---@type table<GUID, HotbarGroup>
    SharedGroups = {}, ---@type table<GUID, true>

    CONTENT_WIDTH = 450,
    UI_WIDTH = 500,
    UI_HEIGHT = 400,

    SAVE_FILENAME = "EpipEncounters_HotbarGroups.json",
    SAVE_VERSION = 0,

    CURRENT_GROUP_GUID = nil, ---@type string

    TranslatedStrings = {
        CreateGroupHeader = {
            Handle = "h4179a16bg43a5g40bcg88ccg7870114fb6c0",
            Text = "Create Hotbar Group",
            ContextDescription = "Hotbar group creation menu header",
        },
        CreateGroupButton = {
            Handle = "h874faf80g6c2eg4fe8gb908g60bb769b02eb",
            Text = "Create",
            ContextDescription = "Hotbar group creation menu confirm button text",
        },
        ResizeGroupHeader = {
            Handle = "h36e32b84g5373g4711g920cg8d0cedd5fcff",
            Text = "Resize Hotbar Group",
            ContextDescription = "Hotbar group resize menu header",
        },
        ResizeGroupButton = {
            Handle = "hf0192252g5d7ag429eg96a6g21be87bd88cd",
            Text = "Resize",
            ContextDescription = "Hotbar group resize menu confirm button text",
        },
        RowsSpinner = {
            Handle = "h36ba40b2ge76bg4ea9g90ecgde3d4fc01945",
            Text = "Rows",
            ContextDescription = "Hotbar group create/resize menu rows spinner label",
        },
        ColumnsSpinner = {
            Handle = "hb4ca31ecge2ecg44faga2dbg1e1c98c49d30",
            Text = "Columns",
            ContextDescription = "Hotbar group create/resize menu columns spinner label",
        },
    },
}
Epip.RegisterFeature("HotbarGroupManager", GroupManager)

---------------------------------------------
-- HOTBAR GROUP
---------------------------------------------

---@class HotbarGroupState
---@field Rows integer
---@field Columns integer
---@field SharedContents GenericUI_Prefab_HotbarSlot_Object[][]
---@field RelativePosition number[]
---@field Layer integer Layer of the UIObject.

---@class HotbarGroup
---@field UI GenericUI_Instance
---@field GUID GUID
---@field _Slots table<GenericUI_Prefab_HotbarSlot>
---@field _SlotsAllocated integer
---@field package _Rows integer
---@field package _Columns integer
---@field package _Content  GenericUI_Element_TiledBackground
---@field package _Container GenericUI_Element_Grid
---@field _DragArea GenericUI_Element_Divider
local HotbarGroup = {
    SLOT_SIZE = 58,
    SLOT_SPACING = 0,
}

---@return GenericUI_Prefab_HotbarSlot
function HotbarGroup:_AddSlot()
    local slot = HotbarSlot.Create(self.UI, self.GUID .. "_Slot_" .. self._SlotsAllocated, self._Container)
    slot:SetCanDragDrop(true)
    slot.SlotElement:SetSizeOverride(self.SLOT_SIZE, self.SLOT_SIZE)
    self._Slots[self._SlotsAllocated] = slot
    self._SlotsAllocated = self._SlotsAllocated + 1
    return slot
end

---@return number, number -- Width, height
function HotbarGroup:GetSlotAreaSize()
    local width = self._Columns * self.SLOT_SIZE + (self._Columns + 0) * self.SLOT_SPACING
    local height = self._Rows * self.SLOT_SIZE + (self._Rows + 0) * self.SLOT_SPACING

    return width, height
end

---@return GenericUI_Prefab_HotbarSlot
function HotbarGroup:_GetSlot(index)
    return self._Slots[index]
end

---@return GenericUI_Prefab_HotbarSlot
function HotbarGroup:GetSlot(row, column)
    return self._Slots[(row - 1) * self._Columns + column - 1]
end

---@param newRows integer
---@param newColumns integer
function HotbarGroup:Resize(newRows, newColumns)
    for _=self._Rows * self._Columns + 1,newRows * newColumns,1 do
        self:_AddSlot()
    end

    local oldSlotObjects = {}
    local oldRows, oldCols = self._Rows, self._Columns
    for i=1,self._Rows,1 do
        oldSlotObjects[i] = {}
        for j=1,self._Columns,1 do
            oldSlotObjects[i][j] = self:GetSlot(i, j).Object
        end
    end

    self._Rows = newRows
    self._Columns = newColumns

    for i=1,math.max(newRows,oldRows),1 do
        for j=1,math.max(newColumns,oldCols),1 do
            if i <= oldRows and j <= oldCols then
                self:GetSlot(i, j):SetObject(oldSlotObjects[i][j])
            else
                self:GetSlot(i, j):Clear()
            end
        end
    end

    local width, height = self:GetSlotAreaSize()

    self._Content:SetBackground("Black", width, height)

    self._Container:SetGridSize(newColumns, newRows)
    self._Container:RepositionElements()
    self._Container:SetSizeOverride(width, height)

    -- Dragging area/handle
    local mcWidth, mcHeight = width, height
    local EXTRA_WIDTH = 15 * 2
    -- Show the handle on the longest side of the slot group
    if width < height then
        self._DragArea:SetRotation(90)
        self._DragArea:SetSize(mcHeight + EXTRA_WIDTH)
        self._DragArea:SetPosition(0, -EXTRA_WIDTH/2)
    else
        self._DragArea:SetRotation(0)
        self._DragArea:SetSize(mcWidth + EXTRA_WIDTH)
        self._DragArea:SetPosition(-EXTRA_WIDTH/2, -25)
    end
end

---@param id string
---@param rows integer
---@param columns integer
function HotbarGroup:_Init(id, rows, columns)
    self._Slots = {}
    self._Rows = 0
    self._Columns = 0
    self._SlotsAllocated = 0

    self.GUID = id
    self.UI = Generic.Create("HotbarGroup_" .. self.GUID)

    local content = self.UI:CreateElement("ContentContainer" .. self.GUID, "GenericUI_Element_TiledBackground")
    content:SetAlpha(0)
    self._Content = content
    self._Content:SetPosition(25, 25)

    local container = content:AddChild("container" .. self.GUID, "GenericUI_Element_Grid")
    container:SetElementSpacing(HotbarGroup.SLOT_SPACING - 4, HotbarGroup.SLOT_SPACING)
    container:SetPosition(3, 3)
    container:SetRepositionAfterAdding(false)
    container:SetGridSize(self._Columns, self._Rows)
    self._Container = container
    self._Container:SetPosition(3, 3)

    local dragArea = content:AddChild("DragArea", "GenericUI_Element_Divider")
    dragArea:SetAsDraggableArea()
    dragArea:SetType("Border")
    dragArea.Tooltip = "Click and hold to drag."
    self._DragArea = dragArea

    self:Resize(rows, columns)

    self.UI:Show()
end

---------------------------------------------
-- METHODS
---------------------------------------------

function GroupManager.ShowCreateUI()
    local ui = GroupManager.CreationUI

    ui:ExternalInterfaceCall("setPosition", "center", "screen", "center")
    ui:Show()
end

---@param guid string
function GroupManager.ShowResizeUI(guid)
    GroupManager.CURRENT_GROUP_GUID = guid

    local group = nil
    if type(guid) == "string" then group = GroupManager.Groups[guid] end

    if group then
        GroupManager.ResizeRowSpinner:SetValue(group._Rows)
        GroupManager.ResizeColSpinner:SetValue(group._Columns)
    end

    local ui = GroupManager.ResizeUI

    ui:ExternalInterfaceCall("setPosition", "center", "screen", "center")
    ui:Show()
end

---@param id string
---@return HotbarGroup
function GroupManager.Create(id, rows, columns)
    ---@type HotbarGroup
    local group = {
    }
    Inherit(group, HotbarGroup)

    id = id or Text.GenerateGUID()

    group:_Init(id, rows, columns)

    local width, height = group:GetSlotAreaSize()
    local uiObject = group.UI:GetUI()
    
    uiObject.SysPanelSize = {width, height}
    uiObject.Left = width

    uiObject:ExternalInterfaceCall("setPosition", "center", "screen", "center")

    local container = group._Container
    container.Events.RightClick:Subscribe(function (e)
        local x, y = Client.GetMousePosition()
        ContextMenu.RequestMenu(x, y, "HotbarGroup", nil, group.GUID)
    end)

    GroupManager.Groups[group.GUID] = group
    GroupManager.SharedGroups[group.GUID] = true

    return group
end

function GroupManager.ResizeGroup(guid)
    ---@type HotbarGroup
    local group = nil
    if type(guid) == "string" then group = GroupManager.Groups[guid] end

    if group then
        group:Resize(GroupManager.ResizeRowSpinner:GetValue(), GroupManager.ResizeColSpinner:GetValue())
    else
        GroupManager:LogError("Tried to resize group that doesn't exist")
    end
end

---@param group HotbarGroup|GUID
function GroupManager.DeleteGroup(group)
    if type(group) == "string" then group = GroupManager.Groups[group] end

    if group then
        -- TODO truly delete
        -- Ext.UI.Destroy(group.UI.Name)
        group.UI:Hide()

        GroupManager.Groups[group.GUID] = nil
    else
        GroupManager:LogError("Tried to delete group that doesn't exist")
    end
end

---@param group HotbarGroup
---@return HotbarGroupState
function GroupManager.GetGroupState(group)
    ---@type HotbarGroupState
    local state = {
        Rows = group._Rows,
        Columns = group._Columns,
    }

    -- Store position relative to viewport edges
    local uiObject = group.UI:GetUI()
    local viewport = Ext.UI.GetViewportSize()
    state.RelativePosition = uiObject:GetPosition()
    state.RelativePosition[1] = state.RelativePosition[1] / viewport[1]
    state.RelativePosition[2] = state.RelativePosition[2] / viewport[2]

    state.Layer = uiObject.Layer

    if GroupManager.SharedGroups[group.GUID] == true then
        state.SharedContents = {}

        for i=1,state.Rows,1 do
            local row = {}

            state.SharedContents[i] = row

            for z=1,state.Columns,1 do
                local slot = table.deepCopy(group:GetSlot(i, z).Object) ---@type GenericUI_Prefab_HotbarSlot_Object
                if slot.ItemHandle then slot.ItemHandle = nil end

                table.insert(row, slot)
            end
        end
    end

    return state
end

---@param path string?
function GroupManager.SaveData(path)
    path = path or GroupManager.SAVE_FILENAME
    local save = {
        Version = GroupManager.SAVE_VERSION,
        Groups = {},
    }

    for guid,group in pairs(GroupManager.Groups) do
        save.Groups[guid] = GroupManager.GetGroupState(group)
    end

    IO.SaveFile(path, save)
end

---@param path string?
function GroupManager.LoadData(path)
    path = path or GroupManager.SAVE_FILENAME
    local save = IO.LoadFile(path) ---@type {Groups: table<GUID, HotbarGroupState>, Version:integer}

    if save and save.Version == 0 then
        local groups = save.Groups

        for guid,data in pairs(groups) do
            local group = GroupManager.Create(guid, data.Rows, data.Columns)

            -- Load shared contents
            if data.SharedContents then
                for i=1,data.Rows,1 do
                    for z=1,data.Columns,1 do
                        local slotData = data.SharedContents[i][z]
                        local slot = group:GetSlot(i, z)

                        slot:SetObject(slotData)
                    end
                end
            end

            -- Set position
            local position = data.RelativePosition
            local viewport = Ext.UI.GetViewportSize()

            if GameState.GetState() == "Running" then
                Timer.Start(0.1, function ()
                    group.UI:GetUI():SetPosition(Ext.Round(position[1] * viewport[1]), Ext.Round(position[2] * viewport[2]))
                end)
            else
                GameState.Events.GameReady:Subscribe(function (e)
                    group.UI:GetUI():SetPosition(Ext.Round(position[1] * viewport[1]), Ext.Round(position[2] * viewport[2]))
                end, {Once = true})
            end
            
            -- Set layer
            group.UI:GetUI().Layer = data.Layer
        end
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Client.UI.ContextMenu.RegisterElementListener("hotBarRow_CreateGroup", "buttonPressed", function(_)
    GroupManager.ShowCreateUI()
end)

Client.UI.Hotbar:RegisterListener("SaveDataSaved", function()
    GroupManager.SaveData()
end)

-- Listen for requests to create the context menu.
ContextMenu.RegisterMenuHandler("HotbarGroup", function(char, guid)
    local contextMenu = {
        {id = "HotbarGroup_Layer", type = "stat", text = CommonStrings.Layer:GetString(), value = 1, params = {GUID = guid}},
        {id = "HotbarGroup_Resize", type = "button", text = CommonStrings.Resize:GetString(), params = {GUID = guid}},
        {id = "HotbarGroup_Delete", type = "button", text = CommonStrings.Delete:GetString(), params = {GUID = guid}},
    }

    Client.UI.ContextMenu.Setup({
        menu = {
            id = "main",
            entries = contextMenu,
        }
    })

    Client.UI.ContextMenu.Open()
end)

-- Format layer within context menu.
ContextMenu.RegisterStatDisplayHook("HotbarGroup_Layer", function(_, _, params)
    local group = GroupManager.Groups[params.GUID]
    return group.UI:GetUI().Layer
end)

-- Listen for the layer being changed from the context menu.
ContextMenu.RegisterElementListener("HotbarGroup_Layer", "statButtonPressed", function(_, params, change)
    local group = GroupManager.Groups[params.GUID]
    group.UI:GetUI().Layer = group.UI:GetUI().Layer + change
end)

-- Listen for requests to resize a group from the context menu.
ContextMenu.RegisterElementListener("HotbarGroup_Resize", "buttonPressed", function(_, params)
    GroupManager.ShowResizeUI(params.GUID)
end)

-- Listen for requests to delete a group from the context menu.
ContextMenu.RegisterElementListener("HotbarGroup_Delete", "buttonPressed", function(_, params)
    GroupManager.DeleteGroup(params.GUID)
end)

---------------------------------------------
-- SETUP
---------------------------------------------

---@param UIName string
---@param HeaderText string
---@param ButtonText string
---@return GenericUI_Instance, GenericUI_Prefab_Spinner, GenericUI_Prefab_Spinner, GenericUI_Element_Button
function GroupManager:__SetupUI(UIName, HeaderText, ButtonText)
    local ui = Generic.Create("PIP_HotbarGroup_" .. UIName) ---@type GenericUI_Instance

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

    local rowSpinner = Spinner.Create(ui, "RowSpinner", content, GroupManager.TranslatedStrings.RowsSpinner:GetString(), 1, 20, 1)
    local columnSpinner = Spinner.Create(ui, "ColumnSpinner", content, GroupManager.TranslatedStrings.ColumnsSpinner:GetString(), 1, 20, 1)

    rowSpinner:GetMainElement():SetCenterInLists(true)
    columnSpinner:GetMainElement():SetCenterInLists(true)

    content:AddChild("Filler", "GenericUI_Element_Empty"):GetMovieClip().heightOverride = 175

    local createButton = content:AddChild("Confirm", "GenericUI_Element_Button")
    createButton:SetCenterInLists(true)
    createButton:SetType("Red")
    createButton:SetText(ButtonText, 4)

    content:SetElementSpacing(0)

    content:RepositionElements()

    ui:Hide()

    return ui, rowSpinner, columnSpinner, createButton
end

function GroupManager:__Setup()
    local ui, rowSpinner, columnSpinner, promptButton = GroupManager:__SetupUI("CreateGroup",
        GroupManager.TranslatedStrings.CreateGroupHeader:GetString(), GroupManager.TranslatedStrings.CreateGroupButton:GetString())
    GroupManager.CreationUI = ui
    GroupManager.CreateRowSpinner = rowSpinner
    GroupManager.CreateColSpinner = columnSpinner
    promptButton.Events.Pressed:Subscribe(function(_)
        GroupManager.Create(nil, GroupManager.CreateRowSpinner:GetValue(), GroupManager.CreateColSpinner:GetValue())
        GroupManager.CreationUI:Hide()
    end)

    ui, rowSpinner, columnSpinner, promptButton = GroupManager:__SetupUI("ResizeGroup",
        GroupManager.TranslatedStrings.ResizeGroupHeader:GetString(), GroupManager.TranslatedStrings.ResizeGroupButton:GetString())
    GroupManager.ResizeUI = ui
    GroupManager.ResizeRowSpinner = rowSpinner
    GroupManager.ResizeColSpinner = columnSpinner
    promptButton.Events.Pressed:Subscribe(function(_)
        GroupManager.ResizeGroup(GroupManager.CURRENT_GROUP_GUID)
        GroupManager.ResizeUI:Hide()
    end)

    GroupManager.LoadData()
end

---------------------------------------------
-- TESTS
---------------------------------------------

-- Ext.Events.SessionLoaded:Subscribe(function (e)
--     if Epip.IsDeveloperMode(true) then
--         local group = GroupManager.Create("test")
--     end
-- end)