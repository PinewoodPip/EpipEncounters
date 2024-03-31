
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Features.Bedazzled.Board.Modifiers.CementMixer : Features.Bedazzled.Board.Modifier
---@field Settings Features.Bedazzled.Board.Modifiers.CementMixer.Config
---@field _Board Feature_Bedazzled_Board
local CementMixer = {
    BASE_SPAWN_CHANCE = 0.15,
    SPAWN_CHANCE_MULTIPLIER_PER_EPIPE = 0.9, -- Spawn chance penalty applied for each existing epipe.
    ENRAGED_GEM_TIMER_BOON = 5, -- Extra time added to Enraged Gem timers upon consuming an Epipe.
    EPIPE_POINT_BONUS = 1000, -- Bonus points for each Epipe consumed.

    Name = Bedazzled:RegisterTranslatedString({
        Handle = "h0fef09d8gaaabg4e34g9082g9a7be5bf02e4",
        Text = "Cement Mixing",
        ContextDescription = [[Modifier name]],
    }),
    Description = Bedazzled:RegisterTranslatedString({
        Handle = "hf513cfa6g3cf1g4902gb10eg84722e3a18bf",
        Text = "If enabled, \"Epipes\" will occasionally spawn to urge you to reconnect with reality.<br>Epipes are immovable objects, but may be destroyed with the unstoppable force of rune explosions.<br>Doing so will grant additional points and soothe all Enraged Gems on the board.",
        ContextDescription = [[Modifier description for "Cement Mixing"]],
    }),
}
Bedazzled:RegisterClass("Features.Bedazzled.Board.Modifiers.CementMixer", CementMixer)
local TSK = {
    Setting_CementLoad_Choice_Low = Bedazzled:RegisterTranslatedString({
        Handle = "h098ad5cbg18a5g43d2g98feg7d3385daf7eb",
        Text = "Mild Cement Load",
        ContextDescription = [[Scoreboard label for "Cement Mixing" modifier setting; "Load" is used as in "workload"]],
    }),
    Setting_CementLoad_Choice_Medium = Bedazzled:RegisterTranslatedString({
        Handle = "hd4217716gdedbg405ag8c48g01d70222be7d",
        Text = "Considerable Cement Load",
        ContextDescription = [[Scoreboard label for "Cement Mixing" modifer setting; "Load" is used as in "workload"]],
    }),
    Setting_CementLoad_Choice_High = Bedazzled:RegisterTranslatedString({
        Handle = "h1d60df09gccf3g48ccg9f74g5ac1b7ca5272",
        Text = "Huge Cement Load",
        ContextDescription = [[Scoreboard label for "Cement Mixing" modifer setting; "Load" is used as in "workload"]],
    })
}
local IntensityTSKs = {
    [0] = Text.CommonStrings.Off,
    [1] = TSK.Setting_CementLoad_Choice_Low,
    [2] = TSK.Setting_CementLoad_Choice_Medium,
    [3] = TSK.Setting_CementLoad_Choice_High,
}

-- Register the Epipe gem.
Bedazzled.RegisterGem({
    Type = "Epipe",
    Icon = "PIP_LOOT_Epipe",
    Weight = 0,
})

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.Bedazzled.Board.Modifiers.CementMixer.Config
---@field Intensity number Multiplier for the base spawn chance.

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a CementMixer modifier.
---@override
---@param config Features.Bedazzled.Board.Modifiers.CementMixer.Config
---@return Features.Bedazzled.Board.Modifiers.CementMixer
function CementMixer:Create(config)
    local mod = CementMixer:__Create({
        Settings = config,
    }) ---@cast mod Features.Bedazzled.Board.Modifiers.CementMixer
    return mod
end

---Returns the spawn chance for the next Epipe.
---@return number -- Fraction.
function CementMixer:GetSpawnChanceWeight()
    local chance = self.BASE_SPAWN_CHANCE
    -- Reduce chance for each Epipe already on the board.
    for _,gem in ipairs(self._Board:GetGems()) do
        if gem:GetDescriptor().Type == "Epipe" then
            chance = chance * self.SPAWN_CHANCE_MULTIPLIER_PER_EPIPE
        end
    end
    return chance
end

---@override
---@param board Feature_Bedazzled_Board
function CementMixer:Apply(board)
    self._Board = board

    -- Allow Epipes to spawn.
    board.Hooks.GemGemSpawnWeight:Subscribe(function (ev)
        local gem = ev.Descriptor
        if gem.Type == "Epipe" then
            ev.Weight = self:GetSpawnChanceWeight()
        end
    end)

    -- Prevent Epipes from being interacted with.
    board.Hooks.IsGemInteractable:Subscribe(function (ev)
        if ev.Gem:GetDescriptor().Type == "Epipe" then
            ev.Interactable = false
        end
    end)

    -- Add extra points to matches containing Epipes.
    -- Should run after all other subscribers.
    board.Hooks.GetMatchAt:Subscribe(function (ev)
        local match = ev.Match
        if match then
            for _,gem in ipairs(match:GetAllGems()) do
                if gem.Type == "Epipe" then
                    match.Score = match.Score + self.EPIPE_POINT_BONUS
                end
            end
        end
    end, {Priority = -9999})

    -- Increase Enraged Gem timers when an Epipe is consumed.
    board.Events.MatchExecuted:Subscribe(function (ev)
        for _,gem in ipairs(ev.Match:GetAllGems()) do
            if gem.Type == "Epipe" then
                for _,otherGem in ipairs(board:GetGems()) do
                    ---@cast otherGem Features.Bedazzled.Board.Modifiers.RaidMechanics.Gem
                    print(otherGem.EnrageTimer)
                    if otherGem.EnrageTimer then
                        -- Force a refresh of the gem for UI purposes.
                        local gemData = board:GetGemData(otherGem)
                        gemData.EnrageTimer = otherGem.EnrageTimer + self.ENRAGED_GEM_TIMER_BOON
                        board:ApplyGemData(otherGem, gemData)
                    end
                end
            end
        end
    end)
end

---@override
function CementMixer:GetConfigurationSchema()
    return self.Settings
end

---@override
---@param config Features.Bedazzled.Board.Modifiers.CementMixer.Config
function CementMixer.StringifyConfiguration(config)
    local tsk = IntensityTSKs[config.Intensity] or Text.CommonStrings.Unknown
    return tsk:GetString()
end

---@override
---@param config1 Features.Bedazzled.Board.Modifiers.CementMixer.Config
---@param config2 Features.Bedazzled.Board.Modifiers.CementMixer.Config
---@return boolean
function CementMixer.ConfigurationEquals(config1, config2)
    -- Need to avoid floating precision shenanigans.
    return math.abs(config1.Intensity - config2.Intensity) < 0.0001
end

---@override
---@param config Features.Bedazzled.Board.Modifiers.RaidMechanics.Config
---@return boolean
function CementMixer.IsConfigurationValid(config)
    return config.Intensity > 0
end
