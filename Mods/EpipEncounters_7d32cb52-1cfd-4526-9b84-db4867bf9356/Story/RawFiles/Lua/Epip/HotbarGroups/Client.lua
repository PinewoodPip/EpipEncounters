
local ContextMenu = Client.UI.ContextMenu
local CommonStrings = Text.CommonStrings

---@class Features.HotbarGroups.Client : Features.HotbarGroups
---@field CreationUI Features.HotbarGroups.UI.Editor
---@field ResizeUI Features.HotbarGroups.UI.Editor
local GroupManager = Epip.GetFeature("Features.HotbarGroups")

GroupManager.Groups = {} ---@type table<GUID, Features.HotbarGroups.UI.Group>
GroupManager.SharedGroups = {} ---@type table<GUID, true>

GroupManager.CONTENT_WIDTH = 450
GroupManager.UI_WIDTH = 500
GroupManager.UI_HEIGHT = 400
GroupManager._CurrentGroupGUID = nil ---@type GUID? ID of the currently-selected group, for purposes such as resizing.
GroupManager._SetupCompleted = false

---------------------------------------------
-- HOTBAR GROUP
---------------------------------------------

---@class HotbarGroupState
---@field Rows integer
---@field Columns integer
---@field SharedContents GenericUI_Prefab_HotbarSlot_Object[][]
---@field RelativePosition number[]
---@field Layer integer Layer of the UIObject.

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
    local editor = GroupManager.ResizeUI
    local group = GroupManager.GetGroup(guid)
    local rows, columns = group:GetSize()
    local ui = GroupManager.ResizeUI

    editor.RowSpinner:SetValue(rows)
    editor.ColumnSpinner:SetValue(columns)

    GroupManager._CurrentGroupGUID = guid

    ui:ExternalInterfaceCall("setPosition", "center", "screen", "center")
    ui:Show()
end

---Creates a hotbar group.
---@param id string? Defaults to random GUID.
---@return Features.HotbarGroups.UI.Group
function GroupManager.Create(id, rows, columns)
    local HotbarGroup = GroupManager:GetClass("Features.HotbarGroups.UI.Group")
    local group = HotbarGroup.___Create(id or Text.GenerateGUID(), rows, columns)
    local width, height = group:GetSlotAreaSize()
    local uiObject = group.UI:GetUI()

    uiObject.SysPanelSize = {width, height}
    uiObject.Left = width

    uiObject:ExternalInterfaceCall("setPosition", "center", "screen", "center")

    local container = group:GetGrid()
    container.Events.RightClick:Subscribe(function (_)
        local x, y = Client.GetMousePosition()
        ContextMenu.RequestMenu(x, y, "HotbarGroup", nil, group.GUID)
    end)

    GroupManager.Groups[group.GUID] = group
    GroupManager.SharedGroups[group.GUID] = true

    return group
end

---Returns the UI for a group.
---@param guid GUID
---@return Features.HotbarGroups.UI.Group
function GroupManager.GetGroup(guid)
    return GroupManager.Groups[guid]
end

function GroupManager.ResizeGroup(guid)
    local editor = GroupManager.ResizeUI
    local group = GroupManager.GetGroup(guid)

    if group then
        group:Resize(editor.RowSpinner:GetValue(), editor.ColumnSpinner:GetValue())
    else
        GroupManager:LogError("Tried to resize group that doesn't exist")
    end
end

---@param group Features.HotbarGroups.UI.Group|GUID
function GroupManager.DeleteGroup(group)
    if type(group) == "string" then -- GUID overload.
        group = GroupManager.GetGroup(group)
    end

    if group then
        -- TODO truly delete
        -- Ext.UI.Destroy(group.UI.Name)
        group.UI:Hide()

        GroupManager.Groups[group.GUID] = nil
    else
        GroupManager:Error("Tried to delete group that doesn't exist")
    end
end

---@param group Features.HotbarGroups.UI.Group
---@return HotbarGroupState
function GroupManager.GetGroupState(group)
    local rows, columns = group:GetSize()
    ---@type HotbarGroupState
    local state = {
        Rows = rows,
        Columns = columns,
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

---Restores groups from saved data.
---@param path string? Defaults to `SAVE_FILENAME`
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
            local setPosFunc = function ()
                group.UI:GetUI():SetPosition(Ext.Round(position[1] * viewport[1]), Ext.Round(position[2] * viewport[2]))
            end
            if GameState.GetState() == "Running" then -- Set position immediately if we're initializing after a lua reset
                Timer.Start(0.1, function ()
                    setPosFunc()
                end)
            else -- Otherwise wait for GameReady
                GameState.Events.GameReady:Subscribe(function (_)
                    setPosFunc()
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

-- Listen for requests to open the creation UI from the context menu.
Client.UI.ContextMenu.RegisterElementListener("hotBarRow_CreateGroup", "buttonPressed", function(_)
    GroupManager.ShowCreateUI()
end)

-- Save groups whenever hotbar data is saved.
Client.UI.Hotbar:RegisterListener("SaveDataSaved", function()
    -- Don't save data before Setup() finishes; during lua resets this occurs before loading the saved data first
    -- TODO find a better time to save groups
    if GroupManager._SetupCompleted then
        GroupManager.SaveData()
    end
end)

-- Listen for requests to create the context menu.
ContextMenu.RegisterMenuHandler("HotbarGroup", function(_, guid)
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
    local group = GroupManager.GetGroup(params.GUID)
    return group.UI:GetUI().Layer
end)

-- Listen for the layer being changed from the context menu.
ContextMenu.RegisterElementListener("HotbarGroup_Layer", "statButtonPressed", function(_, params, change)
    local group = GroupManager.GetGroup(params.GUID)
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

function GroupManager:__Setup()
    GroupManager.LoadData()
    GroupManager._SetupCompleted = true
end
