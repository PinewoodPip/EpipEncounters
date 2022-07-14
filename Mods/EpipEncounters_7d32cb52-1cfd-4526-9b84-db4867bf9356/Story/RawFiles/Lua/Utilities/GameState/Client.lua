
function GameState.IsPaused()
    return Ext.Client.GetGameState() == GameState.CLIENT_STATES.PAUSED
end