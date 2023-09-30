
local Set = DataStructures.Get("DataStructures_Set")

---@alias GameState "Unknown"|"Unitialized"|"Init"|"Idle"|"Exit"|"LoadLevel"|"LoadModule"|"LoadGMCampaign"|"LoadSession"|"UnloadLevel"|"UnloadModule"|"UnloadSession"|"Sync"|"Paused"|"Running"|"Save"|"Disconnect"|"GameMasterPause"|"BuildStory"|"ReloadStory"|"Installation"|"InitMenu"|"InitNetwork"|"InitConnection"|"LoadMenu"|"Menu"|"SwapLevel"|"PrepareRunning"|"Running"|"Disconnect"|"Join"|"Save"|"StartLoading"|"StartServer"|"Movie"|"ModReceiving"|"Lobby"|"LoadLoca"

---@class GameStateLib : Feature
GameState = {
    lastTickTime = nil,

    ---@type table<GameState, true>
    IN_SESSION_STATES = {
        Running = true,
        Paused = true,
        PrepareRunning = true,
        GameMasterPause = true,
    },
    LOADING_STATES = Set.Create({
        "LoadLevel",
        "LoadSession",
        "LoadModule",
        "SwapLevel",
        "PrepareRunning",
        "StartLoading",
        "InitConnection",
        "InitNetwork",
        "StartServer",
        "UnloadSession",
        "UnloadLevel",
        "UnloadModule",
        "Idle",
    }),
    MENU_STATES = Set.Create({
        "Unitialized",
        "Init",
        "InitMenu",
        "LoadMenu",
        "Menu",
        "Lobby",
    }),

    ---@type table<string, GameState>
    SERVER_STATES = {
        UNKNOWN = "Unknown",
        UNINITIALIZED = "Unitialized",
        INIT = "Init",
        IDLE = "Idle",
        EXIT = "Exit",
        LOAD_LEVEL = "LoadLevel",
        LOAD_MODULE = "LoadModule",
        LOAD_GM_CAMPAIGN = "LoadGMCampaign",
        LOAD_SESSION = "LoadSession",
        UNLOAD_LEVEL = "UnloadLevel",
        UNLOAD_MODULE = "UnloadModule",
        UNLOAD_SESSION = "UnloadSession",
        SYNC = "Sync",
        PAUSED = "Paused",
        RUNNING = "Running",
        SAVE = "Save",
        DISCONNECT = "Disconnect",
        GAME_MASTER_PAUSE = "GameMasterPause",
        BUILD_STORY = "BuildStory",
        RELOAD_STORY = "ReloadStory",
        INSTALLATION = "Installation"
    },
    ---@type table<string, GameState>
    CLIENT_STATES = {
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
        START_LOADING = "StartLoading",
        STOP_LOADING = "StopLoading",
        START_SERVER = "StartServer",
        MOVIE = "Movie",
        INSTALLATION = "Installation",
        GAME_MASTER_PAUSE = "GameMasterPause",
        MOD_RECEIVING = "ModReceiving",
        LOBBY = "Lobby",
        BUILD_STORY = "BuildStory",
        LOAD_LOCA = "LoadLoca"
    },

    USE_LEGACY_EVENTS = false,
    Events = {
        GamePaused = {}, ---@type Event<GameStateLib_Event_GamePaused>
        GameUnpaused = {}, ---@type Event<GameStateLib_Event_GameUnpaused>
        StateChanged = {}, ---@type Event<GameStateLib_Event_StateChanged>        
        GameReady = {}, ---@type Event<GameStateLib_Event_GameReady>
        Tick = {}, ---@type Event<GameStateLib_Event_Tick>
        RunningTick = {}, ---@type Event<GameStateLib_Event_RunningTick>
        LuaResetted = {}, ---@type Event<EmptyEvent>
        ClientReady = {}, ---@type Event<GameStateLib_Event_ClientReady>
        RegionStarted = {}, ---@type Event<GameStateLib_Event_RegionStarted> Server-only.
    },
}
Epip.InitializeLibrary("GameState", GameState)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIPENCOUNTERS_GameStateLib_ClientReady : NetMessage, GameStateLib_Event_ClientReady

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class GameStateLib_Event_GamePaused
---@class GameStateLib_Event_GameUnpaused

---Fires when the game transitions from PrepareRunning to Running (on the client)
---or when transitioning from Sync to Running (on the server)
---@class GameStateLib_Event_GameReady

---Fired every tick.
---@class GameStateLib_Event_Tick
---@field DeltaTime integer Milliseconds elapsed since last tick

---Fired every tick while the game is not paused.
---@class GameStateLib_Event_RunningTick
---@field DeltaTime integer Milliseconds elapsed since last tick (NOT the last running tick)

---@class GameStateLib_Event_StateChanged
---@field From GameState
---@field To GameState

---Fired when the client transitions from PrepareRunning to Running,
---as well as when lua is reset.
---@class GameStateLib_Event_ClientReady
---@field CharacterNetID NetId
---@field ProfileGUID GUID

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns whether the game state is currently in a session.
---@return boolean
function GameState.IsInSession()
    return GameState.IN_SESSION_STATES[GameState.GetState()] == true
end

---Returns whether the game is within a loading-related state.
---@return boolean
function GameState.IsLoading()
    return GameState.LOADING_STATES:Contains(GameState.GetState())
end

---Returns whether the game is in a main menu-related state.
---@see GameStateLib.MENU_STATES
---@return boolean
function GameState.IsInMainMenu()
    return GameState.MENU_STATES:Contains(GameState.GetState())
end

---Returns whether the game state is within a running session (not paused)
---@return boolean
function GameState.IsInRunningSession()
    return GameState.GetState() == "Running"
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Ext.Events.GameStateChanged:Subscribe(function(ev)
    local from = ev.FromState ---@type GameState
    local to = ev.ToState ---@type GameState

    GameState.Events.StateChanged:Throw({
        From = from,
        To = to,
    })

    if to == GameState.CLIENT_STATES.PAUSED then
        GameState.Events.GamePaused:Throw()
    elseif to == GameState.CLIENT_STATES.RUNNING and from == GameState.CLIENT_STATES.PAUSED then
        GameState.Events.GameUnpaused:Throw()
    elseif from == GameState.CLIENT_STATES.PREPARE_RUNNING and to == GameState.CLIENT_STATES.RUNNING or (Ext.IsServer() and from == "Sync" and to == "Running") then
        GameState.Events.GameReady:Throw()

        -- Throw ClientReady event, and notify the server.
        if Ext.IsClient() then
            GameState._ThrowClientReadyEvent()
        end
    end
end)

-- Forward tick events.
Ext.Events.Tick:Subscribe(function()
    local now = Ext.Utils.MonotonicTime()
    local lastTickTime = GameState.lastTickTime or now
    local deltaTime = now - lastTickTime

    if Ext.GetGameState() == GameState.CLIENT_STATES.RUNNING then

        GameState.Events.RunningTick:Throw({
            DeltaTime = deltaTime,
        })
    end

    GameState.Events.Tick:Throw({
        DeltaTime = deltaTime,
    })

    GameState.lastTickTime = now
end)

-- Also throw GameReady upon reset.
Ext.Events.ResetCompleted:Subscribe(function()
    GameState.Events.GameReady:Throw()
end)

-- Listen for lua being reset.
Ext.Events.ResetCompleted:Subscribe(function (_)
    GameState.Events.LuaResetted:Throw({})
end)