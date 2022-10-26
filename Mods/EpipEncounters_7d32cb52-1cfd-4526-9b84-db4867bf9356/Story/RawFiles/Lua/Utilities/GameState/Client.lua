
---@class GameStateLib
local GameState = GameState

---------------------------------------------
-- METHODS
---------------------------------------------

---@return boolean
function GameState.IsPaused()
    return Ext.Client.GetGameState() == GameState.CLIENT_STATES.PAUSED
end

---@return GameState
function GameState.GetState()
    return Ext.Client.GetGameState()
end

function GameState._ThrowClientReadyEvent()
    local event = {
        CharacterNetID = Client.GetCharacter().NetID,
        ProfileGUID = Client.GetProfileGUID()
    }

    GameState.Events.ClientReady:Throw(event)
    Net.PostToServer("EPIPENCOUNTERS_GameStateLib_ClientReady", event)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Re-throw ClientReady after a reset.
GameState.Events.LuaResetted:Subscribe(function (_)
    GameState._ThrowClientReadyEvent()
end)