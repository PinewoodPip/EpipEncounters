
---@class ClientLib : Library
Client = {
    UI = {},
    Input = {}, -- See Input.lua

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    ---------------------------------------------
    -- Internal variables - do not set
    ---------------------------------------------

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
    }
}
Epip.InitializeLibrary("Client", Client)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class ClientLib_Event_ActiveCharacterChanged
---@field PreviousCharacter EclCharacter
---@field NewCharacter EclCharacter

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

---Returns whether the client's char is currently playing its turn in a combat. TODO this fails while fear is applied.
---Relies on StatusConsole.
---@return boolean
function Client.IsActiveCombatant()
    local sc = Client.UI.StatusConsole

    if sc:Exists() then
        local root = sc:GetRoot()
    
        return root and root.fightButtons_mc.duoBtns_mc.visible
    else
        return false
    end
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

---Returns the viewport size.
---@return Vector2
function Client.GetViewportSize()
    return Vector.Create(Ext.UI.GetViewportSize())
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

---Returns the UIObjectManager state for a player.
---@param playerIndex integer? Defaults to `1`.
---@return UIObjectManagerPlayerState
function Client._GetUIObjectManagerState(playerIndex)
    playerIndex = playerIndex or 1
    local playerState = Ext.UI.GetUIObjectManager().PlayerStates[playerIndex]

    return playerState
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Open the pause menu while loading to check for host status.
GameState.Events.ClientReady:Subscribe(function (_)
    Client.UI.GameMenu:GetUI():Show()
    Timer.StartTickTimer(1, function (_)
        Client.UI.GameMenu:GetUI():Hide()
    end)
end)

-- Listen for the save/load buttons being added to the pause menu to
-- determine if this client is the host.
Utilities.Hooks.RegisterListener("GameMenu", "ButtonAdded", function(id, name, enabled)
    -- only the host has load/save buttons, so we know this client is hosting if these are present
    if id == Client.UI.GameMenu.BUTTON_IDS.LOAD then
        if not Client.IS_HOST then -- don't spam the message
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