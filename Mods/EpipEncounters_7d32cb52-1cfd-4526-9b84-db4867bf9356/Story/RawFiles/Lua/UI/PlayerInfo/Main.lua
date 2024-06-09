
---------------------------------------------
-- Hooks for playerInfo.swf.
-- The SWF is edited to support a BH display, and status sorting in the future.
---------------------------------------------

local BH = EpicEncounters.BatteredHarried

---@class PlayerInfoUI : UI
local PlayerInfo = {
    LOW_BH_OPACITY = 0.9,
    BH_DISPLAY_SCALE = 0.65,
    SOUNDS = {
        -- These 2 are played by the engine, not via PlaySound().
        LINK = "UI_Game_Party_Merge",
        UNLINK = "UI_Game_Party_Split",
    },

    previousCombatState = nil,
    nextCharacterSelectionIsManual = false,

    StatusApplyTime = {

    },
    StatusNetIDs = {},

    FILEPATH_OVERRIDES = {
        ["Public/Game/GUI/playerInfo.swf"] = "Public/EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356/GUI/playerInfo.swf"
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        ---@type Event<PlayerInfoUI_Event_StatusesUpdated>
        StatusesUpdated = {},
        ---@type Event<PlayerInfoUI_Event_StatusHovered>
        StatusHovered = {},
        ---@type Event<PlayerInfoUI_Event_ActiveCharacterChanged>
        ActiveCharacterChanged = {},
    },
    Hooks = {
        GetBHVisibility = {}, ---@type Event<PlayerInfoUI_Hook_GetBHVisibility>
        UpdateInfos = {}, ---@type Event<UI.PlayerInfo.Hooks.UpdateInfos>
    }
}
Epip.InitializeUI(Ext.UI.TypeID.playerInfo, "PlayerInfo", PlayerInfo)

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

---@class PlayerInfoUI_Hook_GetBHVisibility
---@field Character EclCharacter
---@field Visible boolean Hookable.

---@class UI.PlayerInfo.Hooks.UpdateInfos
---@field Entries UI.PlayerInfo.Entries.Base[] Hookable.

---------------------------------------------
-- CLASSES
---------------------------------------------

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
-- METHODS
---------------------------------------------

---ID for this UI is different on controller, despite using the same swf.
---@override
function PlayerInfo:GetUI()
    local isController = Client.IsUsingController()
    local id = Ext.UI.TypeID.playerInfo

    if isController then
        id = Ext.UI.TypeID.playerInfo_c
    end

    return Ext.UI.GetByType(id)
end

---Sets whether the combat badge should show on portraits.
---@param state boolean
function PlayerInfo.SetCombatBadgeVisibility(state)
    PlayerInfo:GetRoot().COMBAT_BADGE_ENABLED = state
end

---Returns the element that holds the data of a character.
---@param char EclCharacter Must be a player (not summon or follower)
---@return FlashMovieClip? --`nil` if the character is not in the UI.
function PlayerInfo.GetPlayerElement(char)
    local handle = Ext.UI.HandleToDouble(char.Handle)
    local arr = PlayerInfo.GetPlayerElements()
    local playerElement = nil

    for i=0,#arr-1,1 do
        local player = arr[i]
        if player.characterHandle == handle then
            playerElement = player
            break
        end
    end

    return playerElement
end

---Returns the array of player elements.
---@return FlashArray
function PlayerInfo.GetPlayerElements()
    return PlayerInfo:GetRoot().player_array
end

---Returns the characters being shown in the UI.
---@param controlledOnly boolean? Defaults to `false`.
---@return EclCharacter[]
function PlayerInfo.GetCharacters(controlledOnly)
    local chars = {}
    local arr = PlayerInfo.GetPlayerElements()

    for i=0,#arr-1,1 do
        local player = arr[i]

        if not controlledOnly or player.controlled then
            table.insert(chars, Character.Get(player.characterHandle, true))
        end
    end

    return chars
end

---Toggles the visibility of status holders.
---@param visible boolean? Defaults to toggling.
function PlayerInfo.ToggleStatuses(visible)
    local players = PlayerInfo.GetPlayerElements()

    -- Default to inverting state
    if visible == nil then
        visible = not PlayerInfo.GetStatusesVisibility()
    end

    for i=0,#players-1,1 do
        local player = players[i]

        player.statusHolder_mc.visible = visible
    end
end

---Toggles the visibility of summons.
---@param visible boolean? Defaults to toggling.
function PlayerInfo.ToggleSummons(visible)
    local players = PlayerInfo.GetPlayerElements()

    -- Default to inverting state
    visible = visible or not PlayerInfo.GetSummonsVisibility()

    for i=0,#players-1,1 do
        local player = players[i]

        player.harried_mc.visible = true

        player.summonContainer_mc.visible = visible
    end
end

---Returns whether status holders are visible.
---TODO support disabling per player
---@return boolean
function PlayerInfo.GetStatusesVisibility()
    local players = PlayerInfo:GetRoot().player_array

    return players[0].statusHolder_mc.visible
end

---Returns whether summons are visible.
---@return boolean
function PlayerInfo.GetSummonsVisibility()
    local players = PlayerInfo:GetRoot().player_array

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

---Updates the BH indicators for a player.
---@param player FlashObjectHandle
function PlayerInfo._UpdateBH(player)
    local char = Character.Get(player.characterHandle, true)

    local displaysVisible = PlayerInfo.Hooks.GetBHVisibility:Throw({
        Visible = true,
        Character = char
    }).Visible

    local battered = displaysVisible and BH.GetStacks(char, "B") or 0
    local harried = displaysVisible and BH.GetStacks(char, "H") or 0

    local batteredDisplay = player.battered_mc
    local harriedDisplay = player.harried_mc

    PlayerInfo.SetBH(player, batteredDisplay, battered, displaysVisible, 20)
    PlayerInfo.SetBH(player, harriedDisplay, harried, displaysVisible, 69)
end

function PlayerInfo.UpdatePlayers()
    local root = PlayerInfo:GetRoot()
    local players = root.player_array
    local inCombat = Client.IsInCombat()

    if inCombat ~= PlayerInfo.previousCombatState or GameState.IsPaused() then
        root.SetPartyInCombat(inCombat)
        root.STATUS_HOLDER_OPACITY = Settings.GetSettingValue("Epip_PlayerInfo", "PlayerInfo_StatusHolderOpacity")
        root.STATUS_HOLDER_ALPHA_OFFSET = -255 * (1 - root.STATUS_HOLDER_OPACITY)

        PlayerInfo.previousCombatState = inCombat
    end


    for i=0,#players-1,1 do
        local player = players[i]

        PlayerInfo._UpdateBH(player)
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

Settings.Events.SettingValueChanged:Subscribe(function (ev)
    if ev.Setting.ModTable == "Epip_PlayerInfo" and ev.Setting.ID == "PlayerInfoBH" then
        PlayerInfo.SetCombatBadgeVisibility(not ev.Value)
    end
end)

-- By default, BH displays are visible if characters are in combat, with the setting enabled.
PlayerInfo.Hooks.GetBHVisibility:Subscribe(function (ev)
    local visible = ev.Visible

    visible = visible and EpicEncounters.IsEnabled()
    visible = visible and Settings.GetSettingValue("Epip_PlayerInfo", "PlayerInfoBH")
    visible = visible and Character.IsInCombat(ev.Character)

    ev.Visible = visible
end)

Ext.RegisterUITypeInvokeListener(PlayerInfo.UITypeID, "updateInfos", function(ui, method)
    PlayerInfo.UpdatePlayers()
end, "After")

Ext.RegisterUITypeInvokeListener(PlayerInfo.UITypeID, "updateStatuses", function(ui, method, createIfDoesntExist, cleanupAll)
    PlayerInfo.UpdatePlayers()
end, "After")

-- Cleanup status data on expiry.
PlayerInfo:RegisterCallListener("pipStatusExpired", function (event, flashHandle, characterFlashHandle)
    local handle = Ext.UI.DoubleToHandle(flashHandle)
    local netID = PlayerInfo.StatusNetIDs[flashHandle]

    if netID then
        PlayerInfo.StatusApplyTime[netID] = nil
        PlayerInfo.StatusNetIDs[handle] = nil
    end

end)

-- Hook the updateInfos array.
PlayerInfo:RegisterInvokeListener("updateInfos", function (ev)
    local array = ev.UI:GetRoot().infoUpdate
    local data = Client.Flash.ParseArray(array, PlayerInfo.UPDATE_INFOS_FLASH_ARRAY_TEMPLATE, true) ---@type UI.PlayerInfo.Entries.Base[]

    data = PlayerInfo.Hooks.UpdateInfos:Throw({
        Entries = data,
    }).Entries

    Client.Flash.EncodeArray(array, PlayerInfo.UPDATE_INFOS_FLASH_ARRAY_TEMPLATE, data, true)
end, "Before")

---------------------------------------------
-- SETUP
---------------------------------------------

-- Set some values on playerInfo for summon stretching to work
Ext.Events.SessionLoaded:Subscribe(function()
    -- UI, Root fields are for backwards compatibility
    PlayerInfo.UI = PlayerInfo:GetUI()
    PlayerInfo.Root = PlayerInfo:GetRoot()

    PlayerInfo.Root.summonIconHeight = 60
    PlayerInfo.Root.summonIconWidth = 80
    PlayerInfo.Root.summonIconScrollRectOffset = 22
    PlayerInfo.Root.summonDurationOffset = 35
    PlayerInfo.Root.summonDurationNormalOffset = 50
    PlayerInfo.Root.summonNormalScrollRect = 100
    PlayerInfo.Root.summonNormalScale = 0.8

    -- Variable within SWF tracks whether to hide combat badge.
    PlayerInfo.SetCombatBadgeVisibility(not Settings.GetSettingValue("Epip_PlayerInfo", "PlayerInfoBH"))
end)