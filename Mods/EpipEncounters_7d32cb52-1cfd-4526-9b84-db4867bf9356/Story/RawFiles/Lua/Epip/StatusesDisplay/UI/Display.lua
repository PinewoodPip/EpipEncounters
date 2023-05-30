
local Generic = Client.UI.Generic
local StatusPrefab = Generic.GetPrefab("GenericUI_Prefab_Status")
local StatusesDisplay = Epip.GetFeature("Feature_StatusesDisplay")
local PlayerInfo = Client.UI.PlayerInfo
local ContextMenu = Client.UI.ContextMenu
local V = Vector.Create

---@class Feature_StatusesDisplay_Manager : Class
---@field UI GenericUI_Instance
---@field CharacterHandle ComponentHandle
---@field _CurrentStatusesPerRow integer
---@field _Delay integer
---@field GUID GUID
local Manager = {
    UPDATE_DELAY = 20,
    MIN_STATUSES_PER_ROW = 6,
    ROWS = 2,
    FLASH_POSITION = V(112, 2), -- Offset for the root within flash. Used to position the overlay UI properly regardless of resolution.
}
StatusesDisplay:RegisterClass("Feature_StatusesDisplay_Manager", Manager)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a statuses display.
---@param char EclCharacter
---@return Feature_StatusesDisplay_Manager
function Manager.Create(char)
    local instance = Manager:__Create({}) ---@type Feature_StatusesDisplay_Manager

    instance.CharacterHandle = char.Handle
    instance._Delay = 0
    instance._CurrentStatusesPerRow = instance.MIN_STATUSES_PER_ROW
    instance.GUID = Text.GenerateGUID()

    instance:_CreateUI()

    GameState.Events.Tick:Subscribe(function (_)
        ---@diagnostic disable-next-line: invisible
        instance:_Update()
    end, {StringID = instance.GUID}) -- TODO unsub

    instance.UI:Show()

    return instance
end

---Destroys the manager and its UI.
function Manager:Destroy()
    self.UI:Destroy()

    GameState.Events.Tick:Unsubscribe(self.GUID)
end

---Creates the UI and its static components.
function Manager:_CreateUI()
    local ui = Generic.Create("PIP_StatusDisplay_" .. Text.GenerateGUID())
    local uiObject = ui:GetUI()
    local playerInfoUI = PlayerInfo:GetUI()

    uiObject.Layer = playerInfoUI.Layer
    uiObject.RenderOrder = playerInfoUI.RenderOrder + 1

    local bg = ui:CreateElement("Background", "GenericUI_Element_TiledBackground")
    bg:SetAlpha(0)
    bg:SetBackground("Black", 3, 3)
    local list = ui:CreateElement("List", "GenericUI_Element_Grid")
    list:SetElementSpacing(0, 0)
    ui.List = list

    self.UI = ui
    self:_UpdateGridProperties()
    self:_Update()
end

---Updates the configuration of the grid element.
function Manager:_UpdateGridProperties()
    local list = self:_GetListElement()

    list:SetGridSize(self._CurrentStatusesPerRow, self.ROWS)
    list:RepositionElements()
end

---Returns the list that holds the status elements.
---@return GenericUI_Element_Grid
function Manager:_GetListElement()
    local list = self.UI:GetElementByID("List") ---@cast list GenericUI_Element_Grid
    return list
end

---Updates the statuses on the display.
function Manager:_Update()
    local char = Character.Get(self.CharacterHandle)

    self._Delay = self._Delay - 1
    if self._Delay <= 0 then
        self._Delay = self.UPDATE_DELAY

        local list = self:_GetListElement()
        local visibleStatusesCount = 0

        list:ClearElements()

        -- TODO pooling, icon optimization
        for _,status in ipairs(StatusesDisplay.GetStatuses(char)) do
            local statusPrefab = StatusPrefab.Create(self.UI, tostring(status.StatusHandle), list, char, status)
            local statusID = status.StatusId
            local statusName = Stats.GetStatusName(status)

            statusPrefab.Events.RightClicked:Subscribe(function (_)
                ContextMenu.Setup({
                    menu = {
                        id = "main",
                        entries = {
                            {id = "StatusesDisplay_StatusHeader", type = "header", text = Text.Format("— %s —", {FormatArgs = {statusName}})},
                            {
                                id = "StatusesDisplay_Checkbox_Filtered",
                                text = Text.CommonStrings.Filtered:GetString(),
                                type = "checkbox",
                                checked = StatusesDisplay.IsStatusFilteredBySetting(statusID),
                                params = {
                                    StatusID = statusID,
                                },
                            },
                            {
                                id = "StatusesDisplay_SortingIndex",
                                type = "stat",
                                selectable = false,
                                text = StatusesDisplay.TranslatedStrings.ContextMenu_SortingIndex:GetString(),
                                params = {
                                    StatusID = statusID,
                                },
                            },
                        }
                    }
                })
                ContextMenu.Open(Vector.Create(Client.GetMousePosition()))
            end)

            visibleStatusesCount = visibleStatusesCount + 1
        end

        -- Resize grid as status count changes
        if visibleStatusesCount ~= self._CurrentStatusesPerRow * self.ROWS then
            self._CurrentStatusesPerRow = math.ceil(visibleStatusesCount / self.ROWS)
            self._CurrentStatusesPerRow = math.max(self._CurrentStatusesPerRow, self.MIN_STATUSES_PER_ROW)

            self:_UpdateGridProperties()
        end
    end

    -- Update the position of the widget every frame
    local playerInfoWidget = PlayerInfo.GetPlayerElement(char)
    if playerInfoWidget then -- TODO why is this nil on load?
        local playerInfoUI = PlayerInfo:GetUI()
        local pos = Vector.Create(playerInfoUI:GetPosition())
        local root = self.UI:GetRoot()
    
        self.UI:SetPosition(pos)

        root.x = playerInfoWidget.x + self.FLASH_POSITION[1]
        root.y = playerInfoWidget.y + self.FLASH_POSITION[2]
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for context menu filter clicks.
Client.UI.ContextMenu.RegisterElementListener("StatusesDisplay_Checkbox_Filtered", "buttonPressed", function(_, params)
    local set = StatusesDisplay:GetSettingValue(StatusesDisplay.Settings.FilteredStatuses) ---@type DataStructures_Set
    local statusID = params.StatusID

    if StatusesDisplay.IsStatusFilteredBySetting(statusID) then
        set:Remove(statusID)
    else
        set:Add(statusID)
    end

    StatusesDisplay:SetSettingValue(StatusesDisplay.Settings.FilteredStatuses, set)
end)

-- Hook context menu to show sorting index.
ContextMenu.RegisterStatDisplayHook("StatusesDisplay_SortingIndex", function(_, _, elementParams)
    local priority = StatusesDisplay.GetStatusPriority(elementParams.StatusID)
    
    return priority
end)

-- Listen for priority changes coming from the context menu.
ContextMenu.RegisterElementListener("StatusesDisplay_SortingIndex", "statButtonPressed", function(_, params, change)
    local statID = params.StatusID
    local priorityMap = StatusesDisplay:GetSettingValue(StatusesDisplay.Settings.SortingIndexes)
    local amount = priorityMap[statID] or 0
    amount = amount + change

    priorityMap[statID] = amount

    StatusesDisplay:SetSettingValue(StatusesDisplay.Settings.SortingIndexes, priorityMap)
    StatusesDisplay:SaveSettings()
end)