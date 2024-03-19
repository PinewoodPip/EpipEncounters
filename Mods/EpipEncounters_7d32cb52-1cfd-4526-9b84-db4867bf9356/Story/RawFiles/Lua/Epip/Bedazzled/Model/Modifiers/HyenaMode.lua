
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local Match = Bedazzled:GetClass("Feature_Bedazzled_Match")
local V = Vector.Create

---@class Features.Bedazzled.Board.Modifiers.HyenaMode : Features.Bedazzled.Board.Modifier
---@field Settings Empty
local HyenaMode = {
    MATCH_SCORE = 500, -- Score for 2x2 matches.

    Name = Bedazzled:RegisterTranslatedString({
        Handle = "ha05efa1agb975g4152g818egbbbdcc962ed3",
        Text = "Hyena Hunger",
        ContextDescription = [[Modifier name]],
    }),
    Description = Bedazzled:RegisterTranslatedString({
        Handle = "h0680d093g65e0g46c0gbb33g1834d0cee055",
        Text = "If enabled, you become a ferocious hungry hyena on the hunt for otherwise-impossible eldritch 2x2 matches, defying all expectations.",
        ContextDescription = [[Tooltip for Hyena Hunger modifier]],
    }),
}
Bedazzled:RegisterClass("Features.Bedazzled.Board.Modifiers.HyenaMode", HyenaMode)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a Hyena Mode modifier.
---@override
---@param config Empty
---@return Features.Bedazzled.Board.Modifiers.HyenaMode
function HyenaMode:Create(config)
    local mod = HyenaMode:__Create({
        Settings = config,
    }) ---@cast mod Features.Bedazzled.Board.Modifiers.HyenaMode
    return mod
end

---@override
---@param board Feature_Bedazzled_Board
function HyenaMode:Apply(board)
    -- Allow 2x2 matches, anchored by the top-left gem.
    board.Hooks.GetMatchAt:Subscribe(function (ev)

        -- Regular matches take priority.
        if not ev.Match then
            local offsets = {
                V(0, 0),
                V(-1, 0),
                V(-1, 1),
                V(0, 1),
            }

            for _,offset in ipairs(offsets) do
                local pos = ev.Position + offset
                local x, y = pos:unpack()

                -- Anchor for these matches is top-left;
                -- therefore they cannot happen at the bottom and right edges.
                if x < 1 or y > board.Size[1] or x >= board.Size[1] or y == 1 then
                    goto continue
                end

                local isValid = true
                ---@type Feature_Bedazzled_Board_Gem[]
                local gems = {
                    board:GetGemAt(x, y),
                    board:GetGemAt(x + 1, y),
                    board:GetGemAt(x, y - 1),
                    board:GetGemAt(x + 1, y - 1),
                }

                -- Check whether all gems are matchable with each other.
                if gems[1] and #gems == 4 then
                    for i=2,#gems,1 do
                        local gem = gems[i]
                        if not gem or not board:IsGemMatchableWith(gem, gems[1]) then
                            isValid = false
                            break
                        end
                    end
                    if isValid then
                        local match = Match.Create(ev.Position, "PlayerMove")
                        match:AddGems(gems)
                        -- TODO standardize logic?
                        if board.MatchesSinceLastMove > 0 then
                            match:SetReason(Match.REASONS.CASCADE)
                        end
                        match:SetScore(self.MATCH_SCORE * board:GetScoreMultiplier())
                        ev.Match = match
                    end
                end
                ::continue::
            end
        end
    end)
end

---@override
function HyenaMode:GetConfigurationSchema()
    return self.Settings
end

---@override
---@param config Empty
---@return string
---@diagnostic disable-next-line: unused-local
function HyenaMode.StringifyConfiguration(config)
    return HyenaMode.Name:GetString()
end

---@override
---@param config1 Empty
---@param config2 Empty
---@return boolean
---@diagnostic disable-next-line: unused-local
function HyenaMode.ConfigurationEquals(config1, config2)
    return true -- Hyena mode has no config fields.
end

---@override
---@param config Empty
---@return boolean
function HyenaMode.IsConfigurationValid(config)
    return table.isempty(config)
end
