
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
---@field _StatusPrefabInstances GenericUI_Prefab_Status[]
---@field _ForceRescaleTime number Remaining time in seconds during which Resize() updates will be forced.
---@field _CachedState Features.StatusesDisplay.Manager.CachedState Latest position values, to avoid unnecessary updates.
---@field GUID GUID
local Manager = {
    UPDATE_INTERVAL = 0.2, -- In seconds.
    MIN_STATUSES_PER_ROW = 6,
    ROWS = 2,
    FLASH_POSITION = V(102, 2), -- Offset for the root within flash. Used to position the overlay UI properly regardless of resolution.

    _ForceRescaleTime = 0.5
}
StatusesDisplay:RegisterClass("Feature_StatusesDisplay_Manager", Manager)

---@class Features.StatusesDisplay.Manager.CachedState
---@field UIObjectX number?
---@field UIObjectY number?
---@field FlashX number?
---@field FlashY number?
---@field UIScale number?
---@field UIObjectFlashWidth number?
---@field UIObjectFlashHeight number?

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a statuses display.
---@param char EclCharacter
---@return Feature_StatusesDisplay_Manager
function Manager.Create(char)
    local instance = Manager:__Create() ---@type Feature_StatusesDisplay_Manager

    instance.CharacterHandle = char.Handle
    instance._Delay = 0
    instance._CurrentStatusesPerRow = instance.MIN_STATUSES_PER_ROW
    instance.GUID = Text.GenerateGUID()
    instance._StatusPrefabInstances = {}
    instance._ForceRescaleTime = Manager._ForceRescaleTime
    instance._CachedState = {}

    instance:_CreateUI()

    instance.UI:Show()

    return instance
end

---Destroys the manager and its UI.
function Manager:Destroy()
    self.UI:Destroy()
end

---Creates the UI and its static components.
function Manager:_CreateUI()
    local ui = Generic.Create("PIP_StatusDisplay_" .. Text.GenerateGUID())
    local uiObject = ui:GetUI()
    local playerInfoUI = PlayerInfo:GetUI()

    uiObject.Layer = playerInfoUI.Layer + 1
    uiObject.RenderOrder = playerInfoUI.RenderOrder + 1

    local bg = ui:CreateElement("Background", "GenericUI_Element_TiledBackground")
    bg:SetAlpha(0)
    bg:SetBackground("Black", 3, 3)
    local list = ui:CreateElement("List", "GenericUI_Element_Grid")
    list:SetElementSpacing(-4, -4) -- TODO where is the empty space coming from?
    ui.List = list

    self.UI = ui
    self:_UpdateGridProperties()
    self:Update()
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

---Updates the prefab for a status at a certain index within the grid.
---**Will create and initialize a new prefab if none is found at the index.**
---@param index integer
---@param status EclStatus
function Manager:_UpdateStatusInstance(index, status)
    local prefabInstance = self._StatusPrefabInstances[index]
    local char = Character.Get(self.CharacterHandle)

    -- Create a new instance if needed
    if not prefabInstance then
        local list = self:_GetListElement()

        prefabInstance = StatusPrefab.Create(self.UI, "StatusDisplay_" .. tostring(index), list, char, status)
        
        self._StatusPrefabInstances[index] = prefabInstance
    end

    -- Update status displayed
    prefabInstance:SetStatus(char, status)
    prefabInstance:SetVisible(true)

    -- Update right-click listener
    local statusID = status.StatusId
    local statusName = Stats.GetStatusName(status)
    prefabInstance.Events.RightClicked:RemoveNodes()
    prefabInstance.Events.RightClicked:Subscribe(function (_)
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
end

---Returns whether the display should be visible.
---@return boolean
function Manager:_IsVisible()
    return PlayerInfo:IsVisible()
end

---Updates the statuses on the display.
---@param dtSeconds number? An update will be forced if nil.
function Manager:Update(dtSeconds)
    local isForcedUpdate = dtSeconds == nil
    dtSeconds = dtSeconds or self._Delay -- Force-run an update if deltatime is nil.
    local wasVisible = self.UI:IsVisible()
    local visible = self:_IsVisible()
    if visible then -- Calling Show() unnecessarily leads to mouse event issues with different layers!
        self.UI:TryShow()
    else
        self.UI:TryHide()
        return -- Do not perform an update in this case
    end
    local char = Character.Get(self.CharacterHandle)

    if self._ForceRescaleTime >= 0 and not isForcedUpdate then
        local gameState = GameState.GetState()
        if gameState == "Running" or gameState == "GameMasterPause" then
            self._ForceRescaleTime = self._ForceRescaleTime - dtSeconds
        end
    end

    self._Delay = self._Delay - dtSeconds
    if self._Delay <= 0 then
        local visibleStatusesCount = 0

        self._Delay = self.UPDATE_INTERVAL

        for i,status in ipairs(StatusesDisplay.GetStatuses(char)) do
            self:_UpdateStatusInstance(i, status)

            visibleStatusesCount = visibleStatusesCount + 1
        end

        -- Resize grid as status count changes
        if visibleStatusesCount ~= self._CurrentStatusesPerRow * self.ROWS then
            self._CurrentStatusesPerRow = math.ceil(visibleStatusesCount / self.ROWS)
            self._CurrentStatusesPerRow = math.max(self._CurrentStatusesPerRow, self.MIN_STATUSES_PER_ROW)

            self:_UpdateGridProperties()

            -- Hide leftover instances. Must be done after grid reposition
            for i=visibleStatusesCount+1,#self._StatusPrefabInstances,1 do
                local instance = self._StatusPrefabInstances[i]

                instance:SetVisible(false)
            end
        end
    end

    -- Update the position of the widget every frame
    local playerInfoWidget = PlayerInfo.GetPlayerElement(char)
    if playerInfoWidget then -- TODO why is this nil on load?
        local uiObject = self.UI:GetUI()
        local root = self.UI:GetRoot()
        local playerInfoUI = PlayerInfo:GetUI()
        local playerInfoUIScale = playerInfoUI:GetUIScaleMultiplier()
        local playerInfoContainer = playerInfoUI:GetRoot().container_mc
        local pos = Vector.Create(playerInfoUI:GetPosition())
        local cachedState = self._CachedState

        -- Use same scale as the PlayerInfo UI.
        -- This is only necessary to support UIScaling; otherwise the UI already scales properly.
        -- During a brief time window after creation, Resize() does not scale the UI properly,
        -- thus we must keep re-trying for a while before we can have the cache check apply.
        local wasResized = false
        if playerInfoUIScale ~= cachedState.UIScale or not wasVisible or cachedState.UIObjectFlashWidth ~= uiObject.FlashSize[1] or cachedState.UIObjectFlashHeight ~= uiObject.FlashSize[2] or self._ForceRescaleTime >= 0 then
            uiObject:Resize(playerInfoUI.FlashMovieSize[1], playerInfoUI.FlashMovieSize[2], playerInfoUIScale)
            wasResized = true
        end

        -- Update UIObject position
        if pos[1] ~= cachedState.UIObjectX or pos[2] ~= cachedState.UIObjectY then
            self.UI:SetPosition(pos)
        end

        -- Update MovieClip position
        -- Resizing the UI forces the root to be set to (0, 0),
        -- so we must re-set it in that case as well
        local newX = playerInfoContainer.x + playerInfoWidget.x + self.FLASH_POSITION[1]
        local newY = playerInfoContainer.y + playerInfoWidget.y + self.FLASH_POSITION[2]

        -- Controller UI needs an offset for unknown reasons.
        if Client.IsUsingController() then
            newX = newX + 51
            newY = newY + 30
        end

        if cachedState.FlashX ~= newX or not wasVisible or wasResized then
            root.x = newX
        end
        if cachedState.FlashY ~= newY or not wasVisible or wasResized then
            root.y = newY
        end

        cachedState.FlashX = newX
        cachedState.FlashY = newY
        cachedState.UIObjectX = pos[1]
        cachedState.UIObjectY = pos[2]
        cachedState.UIScale = playerInfoUIScale
        -- Tracking the FlashSize is necessary as it is reset
        -- when rescaling the viewport or exiting the GameMenu UI.
        cachedState.UIObjectFlashWidth = uiObject.FlashSize[1]
        cachedState.UIObjectFlashHeight = uiObject.FlashSize[2]
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