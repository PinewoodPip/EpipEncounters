
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Features.Bedazzled.Board.Modifiers.TimeLimit : Features.Bedazzled.Board.Modifier
---@field Settings Features.Bedazzled.Board.Modifiers.TimeLimit.Config
---@field RemainingTime number In seconds.
local TimeLimit = {
    Name = Bedazzled:RegisterTranslatedString("he8f917c8g97fag44e2g9e7ag38bd6d8ac1a5", {
        Text = "Time Limit",
        ContextDescription = "Modifier name",
    }),
    Description = Bedazzled:RegisterTranslatedString("ha6259170g2afdg4323gaf0ag1ab3c1fbb152", {
        Text = "Applies a time limit in seconds. If >0, the game will end when time runs out.",
        ContextDescription = "Modifier description for Time Limit",
    }),
}
Bedazzled:RegisterClass("Features.Bedazzled.Board.Modifiers.TimeLimit", TimeLimit)
local TSK = {
    GameOver_Reason = Bedazzled:RegisterTranslatedString("h243c4e8fg02cag48e2ga5f0g4a39d365d481", {
        Text = "Time's up!",
        ContextDescription = "Game over reason for time limit expiring",
    })
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.Bedazzled.Board.Modifiers.TimeLimit.Config : Features.Bedazzled.Board.Modifier.Configuration
---@field TimeLimit number In seconds.

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a TimeLimit modifier.
---@override
---@param config Features.Bedazzled.Board.Modifiers.TimeLimit.Config
---@return Features.Bedazzled.Board.Modifiers.TimeLimit
function TimeLimit:Create(config)
    local mod = TimeLimit:__Create({
        Settings = config,
    }) ---@cast mod Features.Bedazzled.Board.Modifiers.TimeLimit
    return mod
end

---@override
---@param board Feature_Bedazzled_Board
function TimeLimit:Apply(board)
    self.RemainingTime = self.Settings.TimeLimit

    -- Tick down the timer each update.
    board.Events.Updated:Subscribe(function (ev)
        self.RemainingTime = math.max(0, self.RemainingTime - ev.DeltaTime)

        -- Stop the game when the time runs out.
        if self.RemainingTime <= 0 and board:IsIdle() then
            board:EndGame(TSK.GameOver_Reason)
        end
    end)

    -- Prevent interacting with the board once the time has run out.
    -- This is so that no additional moves can be made while
    -- gems are settling after the time limit has expired.
    board.Hooks.IsInteractable:Subscribe(function (ev)
        ev.Interactable = ev.Interactable and self.RemainingTime > 0
    end)
end

---@override
function TimeLimit:GetConfigurationSchema()
    return self.Settings
end
---@override
---@param config1 Features.Bedazzled.Board.Modifiers.TimeLimit.Config
---@param config2 Features.Bedazzled.Board.Modifiers.TimeLimit.Config
---@return boolean
function TimeLimit.ConfigurationEquals(config1, config2)
    return config1.TimeLimit == config2.TimeLimit
end

---@override
---@param config Features.Bedazzled.Board.Modifiers.TimeLimit.Config
---@return boolean
function TimeLimit.IsConfigurationValid(config)
    return config.TimeLimit > 0
end
