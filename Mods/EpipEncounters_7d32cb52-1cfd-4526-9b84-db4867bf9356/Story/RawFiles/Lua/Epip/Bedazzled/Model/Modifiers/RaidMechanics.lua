
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local Match = Bedazzled:GetClass("Feature_Bedazzled_Match")
local V = Vector.Create

---@class Features.Bedazzled.Board.Modifiers.RaidMechanics : Features.Bedazzled.Board.Modifier
---@field Settings Features.Bedazzled.Board.Modifiers.RaidMechanics.Config
---@field ProgressUntilNextSpawn number Fraction.
---@field _Finished boolean `true` if a game over from this modifier is queued.
local RaidMechanics = {
    BASE_PROGRESS_PER_MOVE = 0.12, -- Progress towards the next enraged gem spawn gained for each move, without considering the intensity multiplier.
    MAX_STARTING_PROGRESS = 0.15, -- Maximum random starting progress towards the next enrage gem spawn.
    MIN_ENRAGE_TIMER = 7, -- In moves.
    ENRAGE_TIMER_MAX_GRACE = 6, -- Extra enrage timer during early game; decreases progressively until 0.
    ENRAGE_TIME_GRACE_PERIOD_MOVES = 70, -- Moves until the enrage timer grace bonus is completely exhausted.
    ENRAGED_GEM_SCORE_BONUS = 200, -- Bonus points for defusing Enraged Gems.
    -- Recommended intensity values to use;
    -- these use special labels when stringifying the modifier.
    RECOMMENDED_INTENSITY_VALUES = {
        0.6,
        1.0,
        1.6,
    },

    Name = Bedazzled:RegisterTranslatedString({
        Handle = "hc65f56cegc174g497eg8cd3g868daf684df1",
        Text = "Raid Mechanics",
        ContextDescription = [[Modifier name]],
    }),
    Description = Bedazzled:RegisterTranslatedString({
        Handle = "h4a69c351g2ebdg451fgb8dfg6aef67fcc167",
        Text = "If enabled, gems with MMO enrage timers will spawn with increasing frequency. If left unmatched, they will bring a fair and balanced instant game over.",
        ContextDescription = [[Description for "Raid Mechanics" modifier]],
    }),
    TranslatedStrings = {
        Intensity_Easy = Bedazzled:RegisterTranslatedString({
            Handle = "h889783a6g2c7bg4074g9ceegcd7fb602685b",
            Text = "EZ Raid",
            ContextDescription = [[Choice for "Raid Mechanics" modifier setting; "EZ" is gamer slang for "easy"]],
        }),
        Intensity_Medium = Bedazzled:RegisterTranslatedString({
            Handle = "hd9bab9d3gf36ag4da5ga272gdaedd5d48e87",
            Text = "Casual Raid",
            ContextDescription = [[Choice for "Raid Mechanics" modifier setting]],
        }),
        Intensity_Hard = Bedazzled:RegisterTranslatedString({
            Handle = "h6af47672g5722g45fagadf2g2da5380da7c3",
            Text = "Endgame Raid",
            ContextDescription = [[Choice for "Raid Mechanics" modifier setting]],
        }),
    },
    Events = {
        GemEnraged = {}, ---@type Event<{Gem: Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem}>
    }
}
Bedazzled:RegisterClass("Features.Bedazzled.Board.Modifiers.RaidMechanics", RaidMechanics)
local TSK = {
    GameOver_Reason = Bedazzled:RegisterTranslatedString({
        Handle = "h998ff515gc80ag4cb4g9753ga5c426acb4d4",
        Text = "Raid Failed!",
        ContextDescription = [[Game over message for "Raid Mechanics" modifier]],
    }),
    Label_Config_Intensity = Bedazzled:RegisterTranslatedString({
        Handle = "hd0e7acccge5acg47b5gbb4cg304caa1dbbce",
        Text = "Raid (%sx Intensity)",
        ContextDescription = [[Short description for "Raid Mechanics" modifier; param is difficulty rating, as decimal number. "Lv." is short for "Level"]],
    }),
}
RaidMechanics.RECOMMENDED_INTENSITY_TSKS = {
    RaidMechanics.TranslatedStrings.Intensity_Easy,
    RaidMechanics.TranslatedStrings.Intensity_Medium,
    RaidMechanics.TranslatedStrings.Intensity_Hard,
}

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.Bedazzled.Board.Modifiers.RaidMechanics.Config
---@field Intensity number

---@class Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem : Feature_Bedazzled_Board_Gem
---@field EnrageTimer integer? Moves left.

---@class Features.Bedazzled.Board.Modifiers.RaidMechanics.GemData : Features.Bedazzled.Board.Gem.Data
---@field EnrageTimer integer? Moves left.

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a RaidMechanics modifier.
---@override
---@param config Features.Bedazzled.Board.Modifiers.RaidMechanics.Config
---@return Features.Bedazzled.Board.Modifiers.RaidMechanics
function RaidMechanics:Create(config)
    local mod = RaidMechanics:__Create({
        Settings = config,
    }) ---@cast mod Features.Bedazzled.Board.Modifiers.RaidMechanics
    mod.Events = SubscribableEvent.InitializeEventTable(RaidMechanics.Events)
    return mod
end

---Increments the progress towards the next enraged gem spawn.
function RaidMechanics:IncrementProgress()
    local maxGemsOnBoard = self.Board.Size[1] * self.Board.Size[2]
    -- Intensity cannot be gained from the gem spawns at the start of the game.
    if self.Board.GemsSpawned > maxGemsOnBoard then
        local intensityMultiplier = self.Settings.Intensity
        local newProgress = self.BASE_PROGRESS_PER_MOVE * intensityMultiplier
        self.ProgressUntilNextSpawn = self.ProgressUntilNextSpawn + newProgress
    end
end

---Returns the timer to use for newly-spawned enrage gems.
---Reduced as the game progresses.
---@return integer
function RaidMechanics:GetDefaultEnrageTimer()
    local timer = self.MIN_ENRAGE_TIMER
    local graceMultiplier = 1 - math.min(self.Board.MovesMade / self.ENRAGE_TIME_GRACE_PERIOD_MOVES, 1) -- Extra time is granted during early game.
    timer = timer + graceMultiplier * self.ENRAGE_TIMER_MAX_GRACE
    return math.ceil(timer)
end

---@override
---@param board Feature_Bedazzled_Board
function RaidMechanics:Apply(board)
    self.Board = board
    self.ProgressUntilNextSpawn = 0
    self._Finished = false

    -- Tick down enrage timers with each move.
    board.Events.MovePerformed:Subscribe(function (_)
        for _,gem in ipairs(board:GetGems()) do
            ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
            if gem.EnrageTimer then
                gem.EnrageTimer = gem.EnrageTimer - 1 -- A game over is not queued here, as we want to allow the player one last chance to match the gem when the timer is 1 before a swap.
            end
        end
    end)

    -- Prevent moves when an enraged gem's timer is at 0.
    -- This does not necessarily mean that gem will end the game,
    -- as it might be about to be matched.
    board.Hooks.IsInteractable:Subscribe(function (ev)
        if self._Finished then
            ev.Interactable = false
        else
            for _,gem in ipairs(board:GetGems()) do
                ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
                if gem.EnrageTimer and gem.EnrageTimer <= 0 then
                    ev.Interactable = false
                    break
                end
            end
        end
    end)

    -- Clear enrage timers from fused gems.
    board.Events.MatchExecuted:Subscribe(function (ev)
        for _,fusion in ipairs(ev.Match.Fusions) do
            local gem = fusion.TargetGem ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
            gem.EnrageTimer = nil
        end
    end)

    -- End the game if a game over is queued and the board becomes idle.
    local updatedSubscriberID = "Modifier.RaidMechanics"
    board.Events.Updated:Subscribe(function (_)
        -- Queue ending the game once any gem timer reaches 0 and the board is idle.
        if board:IsRunning() and board:IsIdle() then
            for _,gem in ipairs(board:GetGems()) do
                ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem

                if gem.EnrageTimer and gem.EnrageTimer <= 0 then
                    self._Finished = true
                    break
                end
            end
        end

        if self._Finished then
            board:EndGame(TSK.GameOver_Reason)

            -- Blow up all gems on the board. Spectacularly.
            local explosion = Match.Create(V(1, 1), Match.REASONS.EXPLOSION)
            explosion:SetScore(0)
            explosion:AddGems(board:GetGems())
            board:ConsumeMatch(explosion)

            board.Events.Updated:Unsubscribe(updatedSubscriberID)
        end
    end, {StringID = updatedSubscriberID})

    -- Increase progress for each move made and roll for new enrage gems.
    board.Events.MovePerformed:Subscribe(function (_)
        self:IncrementProgress()
        if self.ProgressUntilNextSpawn >= 1 then -- Roll new enraged gems
            -- Randomize starting progress towards next gem
            self.ProgressUntilNextSpawn = math.random() * self.MAX_STARTING_PROGRESS

            -- Add a timer to a random gem that is not an Epipe (would be too evil) nor special (ex. runes), and doesn't have a timer already.
            local gems = table.filter(board:GetGems(), function (gem)
                ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
                return gem.Type ~= "Epipe" and #gem.Modifiers == 0 and gem.EnrageTimer == nil and gem:IsIdle()
            end)
            local gem = gems[math.random(1, #gems)] ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
            gem.EnrageTimer = self:GetDefaultEnrageTimer()

            self.Events.GemEnraged:Throw({
                Gem = gem,
            })
        end
    end, {Priority = 9999})

    -- Grant extra points for consuming Enraged Gems.
    -- Should run last to ensure the match is created.
    board.Hooks.GetMatchAt:Subscribe(function (ev)
        local match = ev.Match
        if ev.Match then
            for _,gem in ipairs(match:GetAllGems()) do
                ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
                if gem.EnrageTimer then
                    match.Score = match.Score + self.ENRAGED_GEM_SCORE_BONUS
                end
            end
        end
    end, {{Priority = -9999}})

    -- Copy enrage timer data when necessary.
    board.Events.GemDataApplied:Subscribe(function (ev)
        local gem = ev.Gem ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
        local data = ev.Data ---@cast data Features.Bedazzled.Board.Modifiers.RaidMechanics.GemData
        gem.EnrageTimer = data.EnrageTimer
    end)
    board.Hooks.GetGemData:Subscribe(function (ev)
        local gem = ev.Gem ---@cast gem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
        ev.Data.EnrageTimer = gem.EnrageTimer
    end)
end

---@override
function RaidMechanics:GetConfigurationSchema()
    return self.Settings
end

---@override
---@param config Features.Bedazzled.Board.Modifiers.RaidMechanics.Config
function RaidMechanics.StringifyConfiguration(config)
    local str
    local index = table.reverseLookup(RaidMechanics.RECOMMENDED_INTENSITY_VALUES, config.Intensity)
    -- Pray for no float precision issues
    if index then
        str = RaidMechanics.RECOMMENDED_INTENSITY_TSKS[index]:GetString()
    else
        str = TSK.Label_Config_Intensity:Format({
            FormatArgs = {config.Intensity},
        })
    end
    return str
end

---@override
---@param config1 Features.Bedazzled.Board.Modifiers.RaidMechanics.Config
---@param config2 Features.Bedazzled.Board.Modifiers.RaidMechanics.Config
---@return boolean
function RaidMechanics.ConfigurationEquals(config1, config2)
    return config1.Intensity == config2.Intensity
end

---@override
---@param config Features.Bedazzled.Board.Modifiers.RaidMechanics.Config
---@return boolean
function RaidMechanics.IsConfigurationValid(config)
    return config.Intensity > 0
end
