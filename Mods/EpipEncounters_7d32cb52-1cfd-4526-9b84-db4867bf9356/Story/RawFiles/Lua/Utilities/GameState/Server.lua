
---------------------------------------------
-- METHODS
---------------------------------------------

---@return boolean
function GameState.IsPaused()
   return Ext.Server.GetGameState() == GameState.SERVER_STATES.PAUSED
end

---@return GameState
function GameState.GetState()
    return Ext.Server.GetGameState()
end

---@return boolean
function GameState.IsSessionLoaded()
    return GameState.IN_SESSION_STATES[GameState.GetState()] == true
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for clients becoming ready (PrepareRunning -> Running).
Net.RegisterListener("EPIPENCOUNTERS_GameStateLib_ClientReady", function (payload)
    GameState.Events.ClientReady:Throw(payload)
end)