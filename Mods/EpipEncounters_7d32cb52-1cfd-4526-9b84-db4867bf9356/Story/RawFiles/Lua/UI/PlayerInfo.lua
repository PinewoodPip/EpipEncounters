
---------------------------------------------
-- Hooks for playerInfo.swf.
-- The SWF is edited to support a BH display, and status sorting in the future.
---------------------------------------------

Client.UI.PlayerInfo = {
    LOW_BH_OPACITY = 0.9,
    BH_DISPLAY_SCALE = 0.65,

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/playerInfo.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/playerInfo.swf"
    },
}
if Epip.IS_IMPROVED_HOTBAR then
    Client.UI.PlayerInfo.FILEPATH_OVERRIDES = {}
end
local PlayerInfo = Client.UI.PlayerInfo
Epip.InitializeUI(Client.UI.Data.UITypes.playerInfo, "PlayerInfo", PlayerInfo)

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

    local battered = Game.Character.GetStacks(char, "B")
    local harried = Game.Character.GetStacks(char, "H")

    local batteredDisplay = player.battered_mc
    local harriedDisplay = player.harried_mc

    PlayerInfo.SetBH(player, batteredDisplay, battered, displaysVisible, 20)
    PlayerInfo.SetBH(player, harriedDisplay, harried, displaysVisible, 69)
end

function PlayerInfo.UpdatePlayers()
    local players = PlayerInfo.Root.player_array

    for i=0,#players-1,1 do
        local player = players[i]

        PlayerInfo.UpdateBH(player)
    end
end

---------------------------------------------
-- LISTENERS
---------------------------------------------

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
Game.Net.RegisterListener("EPIP_StatusApplied", OnStatusToggle)
Game.Net.RegisterListener("EPIP_StatusRemoved", OnStatusToggle)

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

if not Epip.IS_IMPROVED_HOTBAR then
    Ext.RegisterUITypeInvokeListener(PlayerInfo.UITypeID, "updateInfos", function(ui, method)
        PlayerInfo.UpdatePlayers()
    end, "After")
    
    Ext.RegisterUITypeInvokeListener(PlayerInfo.UITypeID, "updateStatuses", function(ui, method, createIfDoesntExist, cleanupAll)
        PlayerInfo.UpdatePlayers()
    end, "After")
end

Ext.RegisterUITypeInvokeListener(PlayerInfo.UITypeID, "updateStatuses", function(ui, method, createIfDoesntExist, cleanupAll)
    if true then return nil end -- TODO finish
    local root = PlayerInfo.Root
    local array = root.status_array
    local players = {}

    root.cleanupAllStatuses(true)

    if not cleanupAll then
        for i=0,#array-1,6 do
            local data = {
                characterHandle = array[i],
                statusHandle = array[i + 1],
                statusElementId = array[i + 2],
                duration = array[i + 3],
                cooldown = array[i + 4],
                tooltip = array[i + 5],
                sortingIndex = i,
            }

            data.character = Ext.GetCharacter(Ext.UI.DoubleToHandle(data.characterHandle))
            data.status = Ext.Stats.Getus(data.character.Handle, Ext.UI.DoubleToHandle(data.statusHandle))

            if not players[data.character.NetID] then
                players[data.character.NetID] = {}
            end

            local list = players[data.character.NetID]

            data.sortingIndex = #list

            table.insert(list, data)
        end

        -- Ext.Dump(statuses)
        players = PlayerInfo:ReturnFromHooks("updateStatuses", players)
        -- Ext.Dump(statuses)

        local newArray = {}
        for netID,statusesList in pairs(players) do
            for i,data in pairs(statusesList) do
                local statusEntry = {
                    data.characterHandle,
                    data.statusHandle,
                    data.statusElementId,
                    data.duration,
                    data.cooldown,
                    data.tooltip,
                    data.sortingIndex,
                }
    
                for z,value in pairs(statusEntry) do
                    table.insert(newArray, value)
                end
    
                -- root.setStatus(createIfDoesntExist, data.characterHandle, data.statusHandle, data.statusElementId, data.duration, data.cooldown, data.tooltip, i)
            end
        end
        

        Game.Tooltip.TableToFlash(ui, "status_array", newArray)
    end  
end, "Before")

---------------------------------------------
-- SETUP
---------------------------------------------

-- Set some values on playerInfo for summon stretching to work
if not Epip.IS_IMPROVED_HOTBAR then
    Ext.Events.SessionLoaded:Subscribe(function()
        PlayerInfo.UI = Ext.UI.GetByType(Client.UI.Data.UITypes.playerInfo)
        PlayerInfo.Root = PlayerInfo.UI:GetRoot()
    
        PlayerInfo.Root.summonIconHeight = 60
        PlayerInfo.Root.summonIconWidth = 80
        PlayerInfo.Root.summonIconScrollRectOffset = 20
        PlayerInfo.Root.summonDurationOffset = 35
        PlayerInfo.Root.summonDurationNormalOffset = 50
        PlayerInfo.Root.summonNormalScrollRect = 100
        PlayerInfo.Root.summonNormalScale = 0.8
    
        -- Variable within SWF tracks whether to hide combat badge.
        PlayerInfo.SetCombatBadgeVisibility(not Client.UI.OptionsSettings.GetOptionValue("EpipEncounters", "PlayerInfoBH"))
    end)
end