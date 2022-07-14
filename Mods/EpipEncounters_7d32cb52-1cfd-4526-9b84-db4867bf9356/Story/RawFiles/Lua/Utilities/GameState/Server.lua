
---------------------------------------------
-- METHODS
---------------------------------------------

function GameState.IsPaused()
   return Ext.Server.GetGameState() == GameState.SERVER_STATES.PAUSED
end