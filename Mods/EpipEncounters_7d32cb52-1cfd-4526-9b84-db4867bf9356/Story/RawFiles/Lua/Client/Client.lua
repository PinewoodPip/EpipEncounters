
---@class ClientLib : Library
Client = {
    UI = {GM = {}, Controller = {}},
    Input = {}, -- See Input.lua
    _IsInDialogue = false,

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    ---------------------------------------------
    -- Internal variables - do not set
    ---------------------------------------------

    _PathToUI = {}, ---@type table<integer, UI>

    IS_HOST = false,
    GAME_STATES = {
        UNKNOWN = "Unknown",
        INIT = "Init",
        INIT_MENU = "InitMenu",
        INIT_NETWORK = "InitNetwork",
        INIT_CONNECTION = "InitConnection",
        IDLE = "Idle",
        LOAD_MENU = "LoadMenu",
        MENU = "Menu",
        EXIT = "Exit",
        SWAP_LEVEL = "SwapLevel",
        LOAD_LEVEL = "LoadLevel",
        LOAD_MODULE = "LoadModule",
        LOAD_SESSION = "LoadSession",
        LOAD_GM_CAMPAIGN = "LoadGMCampaign",
        UNLOAD_LEVEL = "UnloadLevel",
        UNLOAD_MODULE = "UnloadModule",
        UNLOAD_SESSION = "UnloadSession",
        PAUSED = "Paused",
        PREPARE_RUNNING = "PrepareRunning",
        RUNNING = "Running",
        DISCONNECT = "Disconnect",
        JOIN = "Join",
        SAVE = "Save",
        START_SAVING = "StartLoading",
        STOP_LOADING = "StopLoading",
        START_SERVER = "StartServer",
        MOVIE = "Movie",
        INSTALLATION = "Installation",
        GAME_MASTER_PAUSE = "GameMasterPause",
        MOD_RECEIVING = "ModReceiving",
        LOBBY = "Lobby",
        BUILD_STORY = "BuildStory",
        LOAD_LOCALIZATION = "LoadLoca", -- Name confirmed by Norbyte, though looks to be unused?
    },

    Events = {
        ActiveCharacterChanged = {}, ---@type Event<ClientLib_Event_ActiveCharacterChanged>
        SkillStateChanged = {}, ---@type Event<ClientLib_Event_SkillStateChanged>
        ViewportChanged = {}, ---@type Event<ClientLib_Event_ViewportChanged>
        InDialogueStateChanged = {}, ---@type Event<{InDialogue:boolean}>
        LocalCoopStarted = {}, ---@type Event<Empty> Will be thrown during session load if reloading while in local co-op.
        LocalCoopEnded = {}, ---@type Event<Empty>
        SelectorModeChanged = {}, ---@type Event<{PlayerIndex:integer, Enabled:boolean}>
    }
}
Epip.InitializeLibrary("Client", Client)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class ClientLib_Event_ActiveCharacterChanged
---@field PreviousCharacter EclCharacter
---@field NewCharacter EclCharacter? Can be `nil` in GM mode.

---Fired when the active client character enters or exits a skill state.
---@class ClientLib_Event_SkillStateChanged
---@field Character EclCharacter The active client character.
---@field State EclSkillState?

---Fired when the size of the viewport changes.
---@class ClientLib_Event_ViewportChanged
---@field NewSize Vector2
---@field OldSize Vector2

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns true if the client character is preparing a Source Infusion.
---@meta EE
---@return boolean
function Client.IsPreparingInfusion()
    return EpicEncounters.SourceInfusion.IsPreparingInfusion(Client.GetCharacter())
end

---Returns true if the client is the host of the current session.  
---Relies on GameMenu.
---@return boolean
function Client.IsHost()
    return Client.IS_HOST
end

---Returns the current date and time as a string.
---@return string
function Client.GetDateString()
    local ui = Client.UI.Vanity:GetUI()
    local date = ui:GetRoot().getDate()

    return date
end

---Returns the current date and time as an object. Relies on Client.UI.Time
---@param utc? boolean Whether to use UTC time. Defaults to false.
---@return DateTime
function Client.GetDate(utc)
    return Client.UI.Time.GetDate(utc)
end

---Returns the global position of the mouse in the screen space, in pixel coordinates.
---@return integer, integer
function Client.GetMousePosition()
    return table.unpack(Ext.UI.GetMouseFlashPos())
end

---Returns whether the client character is currently in dialogue.
---@return boolean
function Client.IsInDialogue()
    return Client.GetCharacter().InDialog
end

---Returns the currently-controlled character on the client.  
---@param playerIndex integer? Defaults to 1.
---@return EclCharacter
function Client.GetCharacter(playerIndex)
    playerIndex = playerIndex or 1
    local playerManager = Ext.Entity.GetPlayerManager()
    local char = Character.Get(playerManager.ClientPlayerData[playerIndex].CharacterNetId) ---@type EclCharacter

    return char
end

---Returns the profile GUID of a player.
---@param playerIndex integer? Defaults to 1.
---@return GUID
function Client.GetProfileGUID(playerIndex)
    playerIndex = playerIndex or 1
    local playerManager = Ext.Entity.GetPlayerManager()

    return playerManager.ClientPlayerData[playerIndex].ProfileGuid
end

---Returns true if the game is in a gameplay state, or late into loading.
---@return boolean
function Client.IsInGameplayState()
    local state = Ext.Client.GetGameState()
    local STATES = Client.GAME_STATES

    return state == STATES.LOAD_SESSION or state == STATES.RUNNING or state == STATES.PREPARE_RUNNING
end

--- Copies text to the clipboard.  
---Some characters, like newlines, will be trimmed out as per the vanilla scripting on the swf.
---Relies on MessageBox.
---@param text string
function Client.CopyToClipboard(text)
    Client.UI.MessageBox.CopyToClipboard(text)
end

---Returns whether the client's char is currently playing its turn in a combat.
---@return boolean
function Client.IsActiveCombatant()
    local char = Client.GetCharacter()
    if char and char.InCombat then
        local combatID = Combat.GetCombatID(char)
        local combatant = Combat.GetActiveCombatant(combatID)
        return combatant and combatant == char or false
    end
    return false
end

---Returns whether the client char is in combat.
---@return boolean
function Client.IsInCombat()
    local char = Client.GetCharacter()
    return char and Game.Character.IsInCombat(char)
end

---Returns whether the client is using a controller.
---@return boolean
function Client.IsUsingController()
    return Ext.UI.GetByPath("Public/Game/GUI/msgBox_c.swf") ~= nil
end

---Returns whether the client is playing with keyboard and mouse.
---@return boolean
function Client.IsUsingKeyboardAndMouse()
    return not Client.IsUsingController()
end

---Returns whether the game is in local co-op mode.
---@return boolean
function Client.IsLocalCoop()
    local playerManager = Ext.Entity.GetPlayerManager()
    local playerCount = table.getKeyCount(playerManager.Players)
    return playerCount >= 2 -- Should never be 3+, as support for more players appears scrapped.
end

---Returns whether a player is in controller selector mode.
---@param playerIndex integer? Defaults to `1`.
function Client.IsInSelectorMode(playerIndex)
    playerIndex = playerIndex or 1
    local camera = Client.Camera.GetPlayerCamera(playerIndex)
    local inSelectorMode = false
    if GetExtType(camera) == "ecl::GameCamera" then
        ---@cast camera EclGameCamera
        inSelectorMode = camera.CameraMode == 1
    end
    return inSelectorMode
end

---Returns the viewport size.
---@return Vector2
function Client.GetViewportSize()
    return Vector.Create(Ext.UI.GetViewportSize())
end

---Returns the UI scale preference of the user.
---This refers to the UIScaling setting; it is unaffected by resolution.
---@return number
function Client.GetGlobalUIScale()
    return Ext.Utils.GetGlobalSwitches().UIScaling
end

---Translates world coordinates to screen position.
---@param worldPosition Vector3
---@param playerIndex integer? Defaults to `1`.
---@return Vector2
function Client.WorldPositionToScreen(worldPosition, playerIndex)
    local camera = Client.Camera.GetPlayerCamera(playerIndex)
    local proj = camera.Camera.ViewProjection
    local clientViewport = Client.GetViewportSize()
    local vp = Vector.Create(clientViewport[1], clientViewport[2], 0, 0) -- TODO include top/left offsets once available - necessary for editor
    local positionVector = {
        worldPosition[1],
        worldPosition[2],
        worldPosition[3],
        1.0,
    }
    ---@diagnostic disable-next-line: redundant-parameter
    local screenProjection = Ext.Math.Mul(proj, positionVector)
    local screenX = (screenProjection[1] / screenProjection[4] + 1) * 0.5 * vp[1] + vp[3]
    local screenY = vp[2] - (screenProjection[2] / screenProjection[4] + 1) * 0.5 * vp[2] + vp[4]

    return Vector.Create(screenX, screenY)
end

---Returns whether the cursor is over any UIObject.
---@param playerIndex integer? Defaults to `1`.
---@return boolean
function Client.IsCursorOverUI(playerIndex)
    local playerState = Client._GetUIObjectManagerState(playerIndex)

    return playerState.UIUnderMouseCursor
end

---Returns whether the "Store on Lady Vengeance" item context menu option is available.
---**Inaccurate outside of Origins if the extender fork is not installed.**
---@return boolean
function Client.CanSendToLadyVengeance()
    if Ext.Client.GetGameControl ~= nil then -- This function used to be exclusive to the fork.
        return Ext.Client.GetGameControl().CanSendToLadyVengeance
    else
        local levelID = Entity.GetLevelID()
        return not Entity.ORIGINS_LEVELS_WITH_NO_STORAGE_CHEST[levelID]
    end
end

---Attempts to enter a skill preparation state.
---@param char EclCharacter Must be active.
---@param skillID skill
function Client.PrepareSkill(char, skillID)
    if Client.IsUsingKeyboardAndMouse() then
        Client.UI.Hotbar.UseSkill(skillID) -- TODO move code here
    else
        local BottomBar = Client.UI.Controller.BottomBar
        local skillBar = Character.GetSkillBar(char)
        local row = char.PlayerData.SelectedSkillSet
        local slotIndex = row * BottomBar.SLOTS_PER_ROW + 13 -- Index of the last slot in the current row. We're using 1-based index here, so the last slot in the row is 13.
        local slot = skillBar[slotIndex]
        ---@type EocSkillBarItem Store previous slot data to restore later.
        local previousSlotData = {
            Type = slot.Type,
            SkillOrStatId = slot.SkillOrStatId,
            ItemHandle = slot.ItemHandle,
        }

        slot.Type = "Skill"
        slot.SkillOrStatId = skillID

        -- In order for casting to work correctly, the character must be standing still.
        -- Hijack walk & run thresholds temporarily to prevent movement.
        -- Must be done ahead of time.
        if Client.IsUsingController() then
            local switches = Ext.Utils.GetGlobalSwitches()
            local previousWalkThreshold = switches.ControllerCharacterWalkThreshold
            local previousRunThreshold = switches.ControllerCharacterRunThreshold
            switches.ControllerCharacterWalkThreshold = 2 -- 1 is not reliable.
            switches.ControllerCharacterRunThreshold = 2
            Timer.StartTickTimer(8, function () -- 6 ticks is rarely not enough.
                switches = Ext.Utils.GetGlobalSwitches()
                switches.ControllerCharacterWalkThreshold = previousWalkThreshold
                switches.ControllerCharacterRunThreshold = previousRunThreshold
            end)
        end

        local charHandle = char.Handle
        Ext.OnNextTick(function ()
            -- The hotbar must be refreshed for SlotPressed to work.
            BottomBar:ExternalInterfaceCall("prevHotbar")
            BottomBar:ExternalInterfaceCall("nextHotbar")
            Timer.StartTickTimer(3, function (_)
                BottomBar:ExternalInterfaceCall("SlotPressed", 12) -- Note: though it is possible to use slots on other rows, the scenario of being on row 5 is inconvenient to handle, so we opted to just put the skill on the current row.

                -- Restore slot contents
                char = Character.Get(charHandle)
                slot = Character.GetSkillBar(char)[slotIndex]
                slot.Type = previousSlotData.Type
                slot.SkillOrStatId = previousSlotData.SkillOrStatId
                slot.ItemHandle = previousSlotData.ItemHandle

                -- Hide the active skill animation.
                -- TODO play it on the correct slot if the skill is on the bar
                Timer.StartTickTimer(3, function ()
                    BottomBar:GetRoot().showActiveSkill(-1)
                end)
            end)
        end)
    end
end

---Returns the last UIObject the player has interacted with.
---@param playerIndex integer? Defaults to `1`.
---@return UIObject?
function Client.GetActiveUI(playerIndex)
    local playerState = Client._GetUIObjectManagerState(playerIndex)
    local handle = playerState.ActiveUIObjectHandle
    local ui = nil

    if Ext.Utils.IsValidHandle(handle) then
        ui = Ext.UI.GetByHandle(handle)
    end

    return ui
end

---Returns the Epip UI table for a UI, if registered.
---**Does not support Generic UIs.**
---@param ui UIObject|integer UI or type ID.
---@return UI
function Client.GetUI(ui)
    if type(ui) == "number" then -- Type ID overload.
        ui = Ext.UI.GetByType(ui)
    end
    return Client._PathToUI[Client._AbsoluteUIPathToDataPath(ui.Path)]
end

---Returns the UIObjectManager state for a player.
---@param playerIndex integer? Defaults to `1`.
---@return UIObjectManagerPlayerState
function Client._GetUIObjectManagerState(playerIndex)
    playerIndex = playerIndex or 1
    local playerState = Ext.UI.GetUIObjectManager().PlayerStates[playerIndex]

    return playerState
end

---Converts an absolute UI swf path to one relative to the Data directory.
---@param path path
---@return path
function Client._AbsoluteUIPathToDataPath(path)
    return string.match(path, ".*(Public/.+)$")
end

---Throws the `DeterminedAsHost` event and sets the host flag, only if it wasn't set before.
function Client._ThrowHostDetermined()
    if not Client.IS_HOST then
        Client.IS_HOST = true
        Client:__Log("Client is hosting.")
        Client:FireEvent("DeterminedAsHost")
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open the pause menu while loading to check for host status.
GameState.Events.ClientReady:Subscribe(function (_)
    local ui = Client.IsUsingController() and Client.UI.Controller.GameMenu or Client.UI.GameMenu
    -- Listen for host-only buttons being added to the controller menu.
    Client.UI.Controller.GameMenu:RegisterInvokeListener("addMenuButton", function (_, id)
        if id == Client.UI.Controller.GameMenu.BUTTON_IDS.LOAD then
            Client._ThrowHostDetermined()
        end
    end)
    ui:Show()
    Timer.StartTickTimer(0.1, function (_)
        ui:Hide()
    end)
end)

-- Listen for the certain buttons being added to the pause menu to
-- determine if this client is the host.
Utilities.Hooks.RegisterListener("GameMenu", "ButtonAdded", function(id, _, _)
    -- only the host has load/save buttons, so we know this client is hosting if these are present
    if id == Client.UI.GameMenu.BUTTON_IDS.LOAD or id == Client.UI.GameMenu.BUTTON_IDS.GM_RELOAD_ASSETS then
        if not Client.IS_HOST then -- Only show message and fire event once.
            Client.IS_HOST = true
            Client:Log("Client is hosting.")
            Client:FireEvent("DeterminedAsHost")
        end
    end
end)

-- Forward saving events
Utilities.Hooks.RegisterListener("Saving", "SavingStarted", function()
    Client:FireEvent("SavingStarted")
end)

Utilities.Hooks.RegisterListener("Saving", "SavingFinished", function()
    Client:FireEvent("SavingFinished")
end)

-- Listen for the active character's skill state changing to fire events.
local inSkillState = false
GameState.Events.RunningTick:Subscribe(function (_)
    local char = Client.GetCharacter()
    if char then
        local state = Character.GetSkillState(char)
        if inSkillState and state == nil then
            Client.Events.SkillStateChanged:Throw({
                Character = char,
                State = nil,
            })
            inSkillState = false
        elseif not inSkillState and state then
            Client.Events.SkillStateChanged:Throw({
                Character = char,
                State = state,
            })
            inSkillState = true
        end
    end
end)

-- Listen for viewport size changing to fire events.
local oldViewport = Vector.Create(0, 0)
Ext.Events.Tick:Subscribe(function (_)
    local viewport = Ext.UI.GetViewportSize()
    local width, height = viewport[1], viewport[2]

    if oldViewport[1] ~= width or oldViewport[2] ~= height then
        Client.Events.ViewportChanged:Throw({
            OldSize = oldViewport,
            NewSize = Vector.Create(width, height),
        })

        oldViewport = viewport
    end
end)

-- Throw events for in-dialogue state changing.
GameState.Events.RunningTick:Subscribe(function (_)
    local char = Client.GetCharacter()
    local oldState = Client._IsInDialogue
    local newState = char and char.InDialog or false -- The client might've become a spectator with no assigned characters.
    if oldState ~= newState then
        Client._IsInDialogue = newState
        Client.Events.InDialogueStateChanged:Throw({InDialogue = newState})
    end
end, {StringID = "ClientLib.InDialogueStateChangedEvent"})

-- Throw events for entering/exiting splitscreen.
if Client.IsUsingController() then
    local wasInLocalCoop = false
    GameState.Events.Tick:Subscribe(function (_)
        local inCoop = Client.IsLocalCoop()
        if inCoop ~= wasInLocalCoop then
            if inCoop then
                Client.Events.LocalCoopStarted:Throw()
            else
                Client.Events.LocalCoopEnded:Throw()
            end
            wasInLocalCoop = inCoop
        end
    end)
end

-- Throw events for controller selector mode changing.
if Client.IsUsingController() then
    local wasInSelectorMode = {[1] = false, [2] = false} ---@type table<integer, boolean> Maps player ID to selector mode state.
    GameState.Events.RunningTick:Subscribe(function (_)
        local playerCount = Client.IsLocalCoop() and 2 or 1
        for playerIndex=1,playerCount,1 do
            local inSelectorMode = Client.IsInSelectorMode(playerIndex)
            if inSelectorMode ~= wasInSelectorMode[playerIndex] then
                Client.Events.SelectorModeChanged:Throw({
                    PlayerIndex = playerIndex,
                    Enabled = inSelectorMode,
                })
                wasInSelectorMode[playerIndex] = inSelectorMode
            end
        end
    end)
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Forward active character change events, which currently
-- rely on PlayerInfo.
Ext.Events.SessionLoaded:Subscribe(function (_)
    Client.UI.PlayerInfo.Events.ActiveCharacterChanged:Subscribe(function (ev)
        Client.Events.ActiveCharacterChanged:Throw({
            NewCharacter = ev.NewCharacter,
            PreviousCharacter = ev.PreviousCharacter,
        })
    end)
end)

-- Map swf paths to UI tables when the client is ready.
-- This will not cover all cases, such as UIs that are only created afterwards (ex. settings menu). TODO?
GameState.Events.ClientReady:Subscribe(function (_)
    for _,ui in pairs(Client.UI) do
        if ui.GetPath then
            local path = ui:GetPath()
            if path then
                Client._PathToUI[path] = ui
            end
        end
    end
end)
