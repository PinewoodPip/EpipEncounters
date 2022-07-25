
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