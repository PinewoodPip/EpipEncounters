
---------------------------------------------
-- Hooks for playerInfo.swf.
-- The SWF is edited to support a BH display, and status sorting in the future.
---------------------------------------------

---@class PlayerInfoUI : UI
Client.UI.PlayerInfo = {
    LOW_BH_OPACITY = 0.9,
    BH_DISPLAY_SCALE = 0.65,

    previousCombatState = nil,

    StatusApplyTime = {

    },
    StatusNetIDs = {},

    USE_LEGACY_EVENTS = false,
    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/playerInfo.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/playerInfo.swf"
    },

    Events = {
        ---@type SubscribableEvent<PlayerInfoUI_Event_StatusesUpdated>
        StatusesUpdated = {},
    }
}
if IS_IMPROVED_HOTBAR then
    Client.UI.PlayerInfo.FILEPATH_OVERRIDES = {}
end
local PlayerInfo = Client.UI.PlayerInfo
Epip.InitializeUI(Client.UI.Data.UITypes.playerInfo, "PlayerInfo", PlayerInfo)
PlayerInfo:Debug()

---@class PlayerInfoStatusUpdate
---@field CharacterHandle FlashObjectHandle
---@field Status EclStatus
---@field StatusHandle FlashObjectHandle
---@field Duration number
---@field ElementID integer
---@field Tooltip string
---@field Cooldown number
---@field SortingIndex integer

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class PlayerInfoUI_Event_StatusesUpdated
---@field Data table<NetId, PlayerInfoStatusUpdate[]>

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

---------------------------------------------
-- LISTENERS
---------------------------------------------

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
local function OnStatusToggle(cmd, payload)
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

    PlayerInfo.StatusApplyTime[netID] = nil
    PlayerInfo.StatusNetIDs[handle] = nil
end)

PlayerInfo:RegisterInvokeListener("updateStatuses", function (event, createIfDoesntExist, cleanupAll)
    if not Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "PlayerInfo_EnableSortingFiltering") then return nil end

    local root = PlayerInfo.Root
    local array = root.status_array

    ---@type table<NetId, PlayerInfoStatusUpdate[]>
    local players = {}

    root.cleanupAllStatuses(true)

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
            }

            local char = Character.Get(Ext.UI.DoubleToHandle(data.CharacterHandle))

            ---@type EclStatus
            local status = Ext.GetStatus(Ext.UI.DoubleToHandle(data.CharacterHandle), Ext.UI.DoubleToHandle(data.StatusHandle))
            data.Status = status

            if not players[char.NetID] then
                players[char.NetID] = {}
            end

            local statusApplyTime = PlayerInfo.StatusApplyTime[status.NetID]
            if not statusApplyTime then
                statusApplyTime = now + i -- Adding the index avoids overlaps in priority
                PlayerInfo.StatusApplyTime[status.NetID] = statusApplyTime -- TODO clean these up regularly
                PlayerInfo.StatusNetIDs[data.StatusHandle] = status.NetID
            end

            local list = players[char.NetID]

            -- Newer statuses are displayed to the right.
            data.SortingIndex = -statusApplyTime

            table.insert(list, data)
        end

        PlayerInfo.Events.StatusesUpdated:Throw({
            Data = players,
        })

        -- local newArray = {}
        for _,statusesList in pairs(players) do
            table.sort(statusesList, function (a, b)
                return a.SortingIndex > b.SortingIndex
            end)

            for i,data in pairs(statusesList) do
                -- local statusEntry = {
                --     data.characterHandle,
                --     data.,
                --     data.statusElementId,
                --     data.duration,
                --     data.cooldown,
                --     data.tooltip,
                --     data.sortingIndex,
                -- }
    
                -- for _,value in pairs(statusEntry) do
                --     table.insert(newArray, value)
                -- end
    
                -- PlayerInfo:DebugLog("Status " .. data.Status.StatusId .. ": index " .. data.SortingIndex)

                root.setStatus(createIfDoesntExist, data.CharacterHandle, data.StatusHandle, data.ElementID, data.Duration, data.Cooldown, data.Tooltip, i)
            end
        end

        -- PlayerInfo:DebugLog("Statuses updated.")
        

        event:PreventAction()

        root.ClearStatusArray()
        root.cleanupAllStatuses(cleanupAll)
        -- Game.Tooltip.TableToFlash(ui, "status_array", newArray)
    end
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