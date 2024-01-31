
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Features.Bedazzled.Board.Modifiers.MoveLimit : Features.Bedazzled.Board.Modifier
---@field Settings Features.Bedazzled.Board.Modifiers.MoveLimit.Config
---@field RemainingMoves integer
local MoveLimit = {
    Name = Bedazzled:RegisterTranslatedString("h10cca036g0467g4d94g98acg704e38548857", {
        Text = "Moves Limit",
        ContextDescription = "Modifier name",
    }),
    Description = Bedazzled:RegisterTranslatedString("h2e105e1fg2dcbg47ebgab42gd605bbd2f3cf", {
        Text = "Applies a limit the amount of moves you can make. If >0, the game will end after making the specified amount of valid moves.",
        ContextDescription = "Modifier description for Moves Limit",
    }),
}
Bedazzled:RegisterClass("Features.Bedazzled.Board.Modifiers.MoveLimit", MoveLimit)
local TSK = {
    GameOver_Reason = Bedazzled:RegisterTranslatedString("h8560e895g53e8g4d27ga598gbbcc914ccedb", {
        Text = "Out of moves!",
        ContextDescription = "Game over reason for move limit expiring",
    }),
    Label_Config_Moves = Bedazzled:RegisterTranslatedString("h91bfdf8fg7b3bg44a7g83a4g488252d774b8", {
        Text = "%d Moves",
        ContextDescription = "Short description for a move limit restriction; first parameter is amount of moves",
    })
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.Bedazzled.Board.Modifiers.MoveLimit.Config
---@field MoveLimit integer

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a MoveLimit modifier.
---@override
---@param config Features.Bedazzled.Board.Modifiers.MoveLimit.Config
---@return Features.Bedazzled.Board.Modifiers.MoveLimit
function MoveLimit:Create(config)
    local mod = MoveLimit:__Create({
        Settings = config,
    }) ---@cast mod Features.Bedazzled.Board.Modifiers.MoveLimit
    return mod
end

---@override
---@param board Feature_Bedazzled_Board
function MoveLimit:Apply(board)
    self.RemainingMoves = self.Settings.MoveLimit

    -- Tick down the timer each update.
    board.Events.SwapPerformed:Subscribe(function (_)
        self.RemainingMoves = self.RemainingMoves - 1 -- Should never become negative as interaction is disabled at 0 moves remaining.
    end)

    -- Stop the game when the player runs out of moves.
    -- Must be done in update as we wait for the board to become idle.
    board.Events.Updated:Subscribe(function (_)
        if self.RemainingMoves <= 0 and board:IsIdle() then
            board:EndGame(TSK.GameOver_Reason)
        end
    end)

    -- Prevent interacting with the board once the move limit has run out.
    -- This is so that no additional moves can be made while
    -- gems are settling after the move limit has been reached.
    board.Hooks.IsInteractable:Subscribe(function (ev)
        ev.Interactable = ev.Interactable and self.RemainingMoves > 0
    end)
end

---@override
function MoveLimit:GetConfigurationSchema()
    return self.Settings
end

---@override
---@param config Features.Bedazzled.Board.Modifiers.MoveLimit.Config
function MoveLimit.StringifyConfiguration(config)
    return TSK.Label_Config_Moves:Format({
        FormatArgs = {config.MoveLimit},
    })
end

---@override
---@param config1 Features.Bedazzled.Board.Modifiers.MoveLimit.Config
---@param config2 Features.Bedazzled.Board.Modifiers.MoveLimit.Config
---@return boolean
function MoveLimit.ConfigurationEquals(config1, config2)
    return config1.MoveLimit == config2.MoveLimit
end

---@override
---@param config Features.Bedazzled.Board.Modifiers.MoveLimit.Config
---@return boolean
function MoveLimit.IsConfigurationValid(config)
    return config.MoveLimit > 0
end
