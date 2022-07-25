
---@return boolean
function GameState.IsPaused()
    return Ext.Client.GetGameState() == GameState.CLIENT_STATES.PAUSED
end

---@return GameState
function GameState.GetState()
    return Ext.Client.GetGameState()
end