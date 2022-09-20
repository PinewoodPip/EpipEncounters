
---------------------------------------------
-- Hooks for playerInfo.swf.
-- The SWF is edited to support a BH display, and status sorting in the future.
---------------------------------------------

---@class PlayerInfoUI : UI
local PlayerInfo = {
    LOW_BH_OPACITY = 0.9,
    BH_DISPLAY_SCALE = 0.65,

    previousCombatState = nil,
    nextCharacterSelectionIsManual = false,

    StatusApplyTime = {

    },
    StatusNetIDs = {},

    USE_LEGACY_EVENTS = false,
    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/playerInfo.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/playerInfo.swf"
    },

    Events = {
        ---@type Event<PlayerInfoUI_Event_StatusesUpdated>
        StatusesUpdated = {},
        ---@type Event<PlayerInfoUI_Event_StatusHovered>
        StatusHovered = {},
        ---@type Event<PlayerInfoUI_Event_ActiveCharacterChanged>
        ActiveCharacterChanged = {},
    }
}
if IS_IMPROVED_HOTBAR then
    Client.UI.PlayerInfo.FILEPATH_OVERRIDES = {}
end
Epip.InitializeUI(Client.UI.Data.UITypes.playerInfo, "PlayerInfo", PlayerInfo)
-- PlayerInfo:Debug()

---@class PlayerInfoStatusUpdate
---@field CharacterHandle FlashObjectHandle
---@field Status EclStatus
---@field StatusHandle FlashObjectHandle
---@field Duration number
---@field ElementID integer
---@field Tooltip string
---@field Cooldown number
---@field SortingIndex integer
---@field KeepAlive boolean

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class PlayerInfoUI_Event_StatusesUpdated
---@field Data table<NetId, PlayerInfoStatusUpdate[]>

---@class PlayerInfoUI_Event_StatusHovered
---@field Status EclStatus Will be nil when the mouse is moved out.
---@field Character EclCharacter Will be nil when the mouse is moved out.

---@class PlayerInfoUI_Event_ActiveCharacterChanged
---@field PreviousCharacter EclCharacter?
---@field NewCharacter EclCharacter?
---@field Manual boolean If true, this character change was requested by the player clicking the portrait.

---------------------------------------------
-- METHODS
---------------------------------------------

-- ID for this UI is different on controller, despite using the same swf.
function PlayerInfo:GetUI()
    local isController = Client.IsUsingController()
    local id = Client.UI.Data.UITypes.playerInfo

    if isController then
        id = Client.UI.Data.UITypes.playerInfo_controller
    end

    return Ext.UI.GetByType(id)
end

function PlayerInfo.SetCombatBadgeVisibility(state)
    PlayerInfo:GetRoot().COMBAT_BADGE_ENABLED = state
end

---Returns the characters being shown in the UI.
---@param controlledOnly boolean? Defaults to false.
---@return EclCharacter[]
function PlayerInfo.GetCharacters(controlledOnly)
    local chars = {}
    local arr = PlayerInfo:GetRoot().player_array

    for i=0,#arr-1,1 do
        local player = arr[i]

        if not controlledOnly or player.controlled then
            table.insert(chars, Character.Get(player.characterHandle, true))
        end
    end

    return chars
end

function PlayerInfo.ToggleStatuses(visible)
    local players = PlayerInfo.Root.player_array

    -- Default to inverting state
    visible = visible or not PlayerInfo.GetStatusesVisibility()

    for i=0,#players-1,1 do
        local player = players[i]

        player.statusHolder_mc.visible = visible
    end
end

function PlayerInfo.ToggleSummons(visible)
    local players = PlayerInfo.Root.player_array

    -- Default to inverting state
    visible = visible or not PlayerInfo.GetSummonsVisibility()

    for i=0,#players-1,1 do
        local player = players[i]

        player.harried_mc.visible = true

        player.summonContainer_mc.visible = visible
    end
end

-- TODO support disabling per player
function PlayerInfo.GetStatusesVisibility()
    local players = PlayerInfo.Root.player_array

    return players[0].statusHolder_mc.visible
end

function PlayerInfo.GetSummonsVisibility()
    local players = PlayerInfo.Root.player_array

    return players[0].summonContainer_mc.visible
end

---------------------------------------------
-- INTERNAL METHODS - DO NOT CALL
---------------------------------------------

function PlayerInfo.SetBH(player, element, stacks, visible, height)
    element.visible = visible

    if element.visible then
        element.scaleX = PlayerInfo.BH_DISPLAY_SCALE
        element.scaleY = PlayerInfo.BH_DISPLAY_SCALE

        element.x = 0
        element.y = height

        element.alpha = 1

        -- Fade out at low stacks
        if stacks < 7 then
            element.alpha = PlayerInfo.LOW_BH_OPACITY
        end

        -- Show the right graphic for the current stack amount - hide others
        for i=1,10,1 do
            local numeral = "numeral_" .. i
            element[numeral].visible = i == stacks
        end
    end
end

function PlayerInfo.UpdateBH(player)
    local char = Ext.GetCharacter(Ext.DoubleToHandle(player.characterHandle))

    local displaysVisible = PlayerInfo:ReturnFromHooks("BHDisplaysVisible", false, char, player)

    local battered = Character.GetStacks(char, "B")
    local harried = Character.GetStacks(char, "H")

    local batteredDisplay = player.battered_mc
    local harriedDisplay = player.harried_mc

    PlayerInfo.SetBH(player, batteredDisplay, battered, displaysVisible, 20)
    PlayerInfo.SetBH(player, harriedDisplay, harried, displaysVisible, 69)
end

function PlayerInfo.UpdatePlayers()
    if IS_IMPROVED_HOTBAR then return nil end
    local root = PlayerInfo:GetRoot()
    local players = root.player_array
    local inCombat = Client.IsInCombat()

    if inCombat ~= PlayerInfo.previousCombatState or GameState.IsPaused() then
        root.SetPartyInCombat(inCombat)
        root.STATUS_HOLDER_OPACITY = Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "PlayerInfo_StatusHolderOpacity")
        root.STATUS_HOLDER_ALPHA_OFFSET = -255 * (1 - root.STATUS_HOLDER_OPACITY)

        PlayerInfo.previousCombatState = inCombat
    end


    for i=0,#players-1,1 do
        local player = players[i]

        PlayerInfo.UpdateBH(player)
    end
end

---Returns the active character selected in the UI.
---@return EclCharacter
function PlayerInfo.GetControlledCharacter()
    local root = PlayerInfo:GetRoot()
    local flashHandle = root.selectedCharacterHandle
    local char

    if flashHandle ~= 0 then
        char = Character.Get(flashHandle, true)
    end

    ---@diagnostic disable-next-line: return-type-mismatch
    return char
end

---@param handle EntityHandle
function PlayerInfo.SelectCharacter(handle)
    PlayerInfo:ExternalInterfaceCall("charSel", Ext.UI.HandleToDouble(handle), true)
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Listen for character being selected by player.
PlayerInfo:RegisterCallListener("charSel", function(e, handle, isScripted)
    PlayerInfo.nextCharacterSelectionIsManual = not isScripted
end)

-- Listen for the active character being changed.
PlayerInfo:RegisterCallListener("activeCharacterChanged", function(ev, previousHandle, newHandle)
    local prevChar, newChar

    if previousHandle ~= 0 then prevChar = Character.Get(previousHandle, true) end
    if newHandle ~= 0 then newChar = Character.Get(newHandle, true) end

    PlayerInfo.Events.ActiveCharacterChanged:Throw({
        NewCharacter = newChar,
        PreviousCharacter = prevChar,
        Manual = PlayerInfo.nextCharacterSelectionIsManual,
    })

    PlayerInfo.nextCharacterSelectionIsManual = false
end)

PlayerInfo:RegisterCallListener("statusHovered", function(ev, charFlashHandle, statusFlashHandle)
    local char, status

    if charFlashHandle ~= "" then
        char = Character.Get(Ext.UI.DoubleToHandle(charFlashHandle))
        status = Ext.GetStatus(char.NetID, Ext.UI.DoubleToHandle(statusFlashHandle))
    end

    PlayerInfo.Events.StatusHovered:Throw({
        Character = char,
        Status = status,
    })
end)

-- TODO optimize
GameState.Events.RunningTick:Subscribe(function (_)
    PlayerInfo.UpdatePlayers()
end)

Client.UI.OptionsSettings:RegisterListener("OptionSet", function(data, value)
    if data.ID == "PlayerInfoBH" then
        PlayerInfo.SetCombatBadgeVisibility(not value)
    end
end)

-- Update the BH displays when characters sheathe/unsheathe
local function OnStatusToggle(payload)
    local status = payload.Status

    if status == "UNSHEATHED" then
        PlayerInfo.UpdatePlayers()
    end
end
Net.RegisterListener("EPIP_StatusApplied", OnStatusToggle)
Net.RegisterListener("EPIP_StatusRemoved", OnStatusToggle)

-- By default, BH displays are visible if characters are unsheathed.
-- TODO better combat check.
PlayerInfo:RegisterHook("BHDisplaysVisible", function(visible, char, playerElement)
    -- local badge = playerElement.currentActionState_mc

    -- Show badges when character is unsheathed.
    if not visible then
        visible = char:GetStatus("UNSHEATHED") ~= nil and Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "PlayerInfoBH")
        -- visible = badge.currentFrame == 1 or badge.currentFrame == 5
    end

    return visible
end)

if not IS_IMPROVED_HOTBAR then
    Ext.RegisterUITypeInvokeListener(PlayerInfo.UITypeID, "updateInfos", function(ui, method)
        PlayerInfo.UpdatePlayers()
    end, "After")
    
    Ext.RegisterUITypeInvokeListener(PlayerInfo.UITypeID, "updateStatuses", function(ui, method, createIfDoesntExist, cleanupAll)
        PlayerInfo.UpdatePlayers()
    end, "After")
end

-- Cleanup status data on expiry.
PlayerInfo:RegisterCallListener("pipStatusExpired", function (event, flashHandle, characterFlashHandle)
    local handle = Ext.UI.DoubleToHandle(flashHandle)
    local netID = PlayerInfo.StatusNetIDs[flashHandle]

    if netID then
        PlayerInfo.StatusApplyTime[netID] = nil
        PlayerInfo.StatusNetIDs[handle] = nil
    end

end)

local function PrepareStatusEntry(data, statusesByHandle, players, now, i)
    local char = Character.Get(Ext.UI.DoubleToHandle(data.CharacterHandle))

    ---@type EclStatus
    local status = Ext.GetStatus(Ext.UI.DoubleToHandle(data.CharacterHandle), Ext.UI.DoubleToHandle(data.StatusHandle))
    data.Status = status

    local netID = PlayerInfo.StatusNetIDs[data.StatusHandle]
    if not status then PlayerInfo:DebugLog("A status was deleted?") else netID = status.NetID end
    PlayerInfo.StatusNetIDs[data.StatusHandle] = netID
    if not netID then return nil end

    if not players[char.NetID] then
        players[char.NetID] = {}
    end

    if status then
        statusesByHandle[data.StatusHandle] = true
    end

    local statusApplyTime = PlayerInfo.StatusApplyTime[netID]
    if not statusApplyTime then
        statusApplyTime = now + i -- Adding the index avoids overlaps in priority
        PlayerInfo.StatusApplyTime[netID] = statusApplyTime -- TODO clean these up regularly
    end
    
    -- Newer statuses are displayed to the right.
    data.SortingIndex = -statusApplyTime
    if not status then data.SortingIndex = data.SortingIndex + (i * 0.05) end -- Is this necessary?
    -- else
    --     local statusApplyTime = PlayerInfo.StatusApplyTime
    --     data.SortingIndex = -now + 50 -- Fixes flickering issue with spam re-applying
    -- end

    local list = players[char.NetID]

    table.insert(list, data)
end

PlayerInfo:RegisterInvokeListener("updateStatuses", function (event, createIfDoesntExist, cleanupAll)
    if IS_IMPROVED_HOTBAR then return nil end
    local settingEnabled = Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "PlayerInfo_EnableSortingFiltering") and not IS_IMPROVED_HOTBAR
    event.UI:GetRoot().ENABLE_SORTING = settingEnabled
    if not settingEnabled then return nil end

    local root = PlayerInfo.Root
    local array = root.status_array
    local ascendingSort = Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "PlayerInfo_SortingFunction") == 2

    ---@type table<NetId, PlayerInfoStatusUpdate[]>
    local players = {}
    local statusesByHandle = {}
    -- root.cleanupAllStatuses(cleanupAll)

    local now = Ext.Utils.MonotonicTime()

    if not cleanupAll then
        for i=0,#array-1,6 do
            ---@type PlayerInfoStatusUpdate
            local data = {
                CharacterHandle = array[i],
                StatusHandle = array[i + 1],
                ElementID = array[i + 2],
                Duration = array[i + 3],
                Cooldown = array[i + 4],
                Tooltip = array[i + 5],
                KeepAlive = true,
            }

            PrepareStatusEntry(data, statusesByHandle, players, now, i)
        end
        local statusIndex = #array + 1

        -- Iterate existing statuses in the UI to make sure we don't miss sorting them if the engine isn't updating their info currently
        local playerArray = root.player_array
        for i=0,#playerArray-1,1 do
            local player = playerArray[i]

            local statusArray = player.status_array
            for z=0,#statusArray-1,1 do
                local status = statusArray[z]

                if not statusesByHandle[status.id] then
                    PrepareStatusEntry({
                        CharacterHandle = status.owner,
                        StatusHandle = status.id,
                        ElementID = status.pipElementID,
                        Duration = status.pipDuration,
                        Cooldown = status.pipCooldown,
                        Tooltip = status.tooltip,
                        KeepAlive = false,
                    }, statusesByHandle, players, now, statusIndex + z)
                end
            end
        end

        PlayerInfo.Events.StatusesUpdated:Throw({
            Data = players,
        })

        for netID,statusesList in pairs(players) do
            table.sort(statusesList, function (a, b)
                if a.SortingIndex == b.SortingIndex then
                    return a.StatusHandle > b.StatusHandle
                end
                if ascendingSort then
                    -- Non-sorted statuses still sort in order of appliance
                    if a.SortingIndex < 0 and b.SortingIndex < 0 then
                        return a.SortingIndex > b.SortingIndex
                    end
                    return a.SortingIndex < b.SortingIndex
                else
                    return a.SortingIndex > b.SortingIndex
                end
            end)

            -- PlayerInfo:DebugLog("--------", Character.Get(netID).DisplayName)
            for i,data in pairs(statusesList) do
                if data.KeepAlive then
                    root.setStatus(createIfDoesntExist, data.CharacterHandle, data.StatusHandle, data.ElementID, data.Duration, data.Cooldown, data.Tooltip, (i - 1), data.KeepAlive)
                else
                    root.SetStatusSortingIndex(data.CharacterHandle, data.StatusHandle, (i - 1))
                end

            end
        end

        PlayerInfo:DebugLog("Statuses updated.")
        
        -- for netID,statuses in pairs(players) do
        --     local char = Character.Get(netID)
        --     if char.DisplayName == "Sebille" then
        --         for _,status in ipairs(statuses) do
        --             local obj = status.Status
        --             local name = status.StatusHandle
        --             if obj then name = status.Status.StatusId end

        --             PlayerInfo:DebugLog(Text.Format("Status %s Priority %s KeepAlive %s", {
        --                 FormatArgs = {
        --                     name,
        --                     status.SortingIndex,
        --                     status.KeepAlive,
        --                 }
        --             }))
        --         end
        --     end
        -- end
    end
    event:PreventAction()

    root.ClearStatusArray()
    root.cleanupAllStatuses(cleanupAll)
end, "Before")

---------------------------------------------
-- SETUP
---------------------------------------------

-- Set some values on playerInfo for summon stretching to work
if not IS_IMPROVED_HOTBAR then
    Ext.Events.SessionLoaded:Subscribe(function()
        PlayerInfo.UI = Ext.UI.GetByType(Client.UI.Data.UITypes.playerInfo)
        PlayerInfo.Root = PlayerInfo.UI:GetRoot()
    
        PlayerInfo.Root.summonIconHeight = 60
        PlayerInfo.Root.summonIconWidth = 80
        PlayerInfo.Root.summonIconScrollRectOffset = 22
        PlayerInfo.Root.summonDurationOffset = 35
        PlayerInfo.Root.summonDurationNormalOffset = 50
        PlayerInfo.Root.summonNormalScrollRect = 100
        PlayerInfo.Root.summonNormalScale = 0.8
    
        -- Variable within SWF tracks whether to hide combat badge.
        PlayerInfo.SetCombatBadgeVisibility(not Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "PlayerInfoBH"))
    end)
end