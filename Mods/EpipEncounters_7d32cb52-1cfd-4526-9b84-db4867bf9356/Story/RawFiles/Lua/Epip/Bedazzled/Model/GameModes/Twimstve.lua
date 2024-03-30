
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local BoardClass = Bedazzled:GetClass("Feature_Bedazzled_Board")
local GameClass = Bedazzled:GetClass("Features.Bedazzled.GameMode")
local V = Vector.Create
local GemStates = {
    MoveFrom = Bedazzled.GetGemStateClass("Features.Bedazzled.Board.Gem.State.MoveFrom")
}

---@class Features.Bedazzled.GameModes.Twimstve : Features.Bedazzled.GameMode
---@field FreeMovesRemaining integer
local Game = {
    DEFAULT_FREE_MOVES = 25,
    FREE_MOVE_BONUSES = {
        RUNE_CRAFT_SMALL = 2,
        RUNE_CRAFT_LARGE = 3,
        RUNE_CRAFT_GIANT = 4,
        EPIPE_CONSUMED = 5,
    },

    _CallistoQueuedGemTypes = {}, ---@type table<Feature_Bedazzled_Board_Gem, string[]> -- Gem types to zap when a Callisto finished being rotated.

    Name = Bedazzled:RegisterTranslatedString({
        Handle = "h3a62400bg5fccg488agbc25ge3f4990d857a",
        Text = "Twimst've",
        ContextDescription = [[Game mode name; combination of "Twist" and "Whomst've"]],
    }),
    Description = Bedazzled:RegisterTranslatedString({
        Handle = "hb6b35565g099eg426cga87cg3459ca975b10",
        Text = "Match gems by rotating groups of 2x2 gems.",
        ContextDescription = "Game mode description for Twimst've game mode",
    }),
}
Bedazzled:RegisterClass("Features.Bedazzled.GameModes.Twimstve", Game, {"Features.Bedazzled.GameMode"})

-- Prevent this table from holding a refcount for the gems just in case.
setmetatable(Game._CallistoQueuedGemTypes, {
    __mode = 'k',
})

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function Game:Create(size)
    local board = GameClass.Create(self, size) ---@cast board Features.Bedazzled.GameModes.Twimstve
    board.FreeMovesRemaining = self.DEFAULT_FREE_MOVES

    -- Grant extra free moves when certain gems are consumed.
    board.Events.MatchExecuted:Subscribe(function (ev)
        for _,gem in ipairs(ev.Match:GetAllGems()) do
            if gem.Type == "Epipe" then
                board:AddFreeMoves(board.FREE_MOVE_BONUSES.EPIPE_CONSUMED)
            end
        end
        for _,fusion in ipairs(ev.Match.Fusions) do
            if fusion.TargetModifier == "Rune" then
                board:AddFreeMoves(board.FREE_MOVE_BONUSES.RUNE_CRAFT_SMALL)
            elseif fusion.TargetModifier == "LargeRune" then
                board:AddFreeMoves(board.FREE_MOVE_BONUSES.RUNE_CRAFT_LARGE)
            elseif fusion.TargetModifier == "GiantRune" then
                board:AddFreeMoves(board.FREE_MOVE_BONUSES.RUNE_CRAFT_GIANT)
            end
        end
    end)

    return board
end

---Attempts to rotate gems around, which counts as a move.
---@param anchor Vector2 Top-left gem coordinate.
---@param direction "Clockwise"|"Anti-clockwise"
function Game:Rotate(anchor, direction)
    if not self:IsAnchorValid(anchor) then
        self:__Error("Rotate", "Invalid anchor position")
    end
    local gems = self:__GetAnchorGems(anchor)

    -- Report an invalid move if rotation at this position is not possible, or if free moves are exhausted and this move would not result in a match.
    if not self:CanRotateAt(anchor) or (self.FreeMovesRemaining <= 0 and not self:_WouldMoveResultInMatch(anchor, direction)) then
        self:ReportInvalidMove({
            Position = anchor,
            InteractedGems = gems,
        })
    else
        local newStates = self:_RotateGemStates(anchor, direction)

        -- Queue gem types to zap if a Callisto Anomaly was involved.
        for i=1,#gems,1 do
            local gem = gems[i]
            if gem.Type == "Protean" then
                local otherTypes = {} ---@type table<Feature_Bedazzled_GemDescriptor_ID, true>
                for _,otherGem in ipairs(gems) do
                    otherTypes[otherGem.Type] = true
                end
                otherTypes["Protean"] = nil -- Don't zap other proteans.
                self._CallistoQueuedGemTypes[gem] = otherTypes
            end
        end

        -- Check if the move would result in a match
        local isFreeMove = true
        for i=1,#newStates,1 do
            local pos = newStates[i].OriginalPosition
            local match = self:GetMatchAt(pos:unpack())
            if match ~= nil then
                isFreeMove = false
                break
            end
        end

        -- Decrement free moves
        if isFreeMove then
            self.FreeMovesRemaining = self.FreeMovesRemaining - 1
        end

        for i=1,#newStates,1 do
            local gem = gems[i]
            local newState = newStates[i]
            -- TODO there is an off-by-one error in this. But where?
            gem:SetState(GemStates.MoveFrom:Create(newState.OriginalPosition - V(0, 1)))
        end

        self:ReportMove({
            Position = anchor,
            InteractedGems = gems,
        })
    end
end

---Returns whether gems can be rotated at an anchor.
---Returns `false` for invalid anchors.
---@param anchor Vector2
function Game:CanRotateAt(anchor)
    if not self:IsAnchorValid(anchor) then
        return false
    end
    local gems = self:__GetAnchorGems(anchor)
    -- All gems within the rotator must be matchable and idle.
    local canRotate = not table.any(gems, function (_, v)
        return not v:IsMatchable() or not v:IsIdle() or not self:IsGemInteractable(v)
    end)
    return canRotate
end

---Returns whether an anchor position is valid.
---@param anchor Vector2
function Game:IsAnchorValid(anchor)
    local size = self.Size
    return anchor[1] < size[1] and anchor[2] > 1
end

---Increments the amount of free moves available.
---@param moves integer
function Game:AddFreeMoves(moves)
    self.FreeMovesRemaining = self.FreeMovesRemaining + moves
end

---Returns the gems within the rotator at an anchor.
---@param anchor Vector2
---@return Feature_Bedazzled_Board_Gem[] -- In clock-wise order from top-left.
function Game:__GetAnchorGems(anchor)
    ---@type Feature_Bedazzled_Board_Gem[]
    local gems = {
        self:GetGemAt(anchor[1], anchor[2]),
        self:GetGemAt(anchor[1] + 1, anchor[2]),
        self:GetGemAt(anchor[1] + 1, anchor[2] - 1),
        self:GetGemAt(anchor[1], anchor[2] - 1),
    }
    return gems
end

---@override
---@param gem Feature_Bedazzled_Board_Gem
---@param ev Feature_Bedazzled_Board_Gem_Event_StateChanged
function Game:OnGemStateChanged(gem, ev)
    BoardClass.OnGemStateChanged(self, gem, ev)

    -- Zap gems when Callisto Anomalies finish being rotated.
    if gem.Type == "Protean" and ev.NewState == "Feature_Bedazzled_Board_Gem_State_Idle" then
        local queuedTypes = self._CallistoQueuedGemTypes[gem]
        if queuedTypes then
            self:QueueCallistoAnomalyZap(gem, queuedTypes)
            self._CallistoQueuedGemTypes[gem] = nil
        end
    end
end

---@override
---@return boolean
function Game:HasMovesAvailable()
    -- Check free moves first
    local hasMoves = self.FreeMovesRemaining > 0

    -- Otherwise check for valid moves on board
    if not hasMoves then
        for i=1,self.Size[1] - 1,1 do
            for j=2,self.Size[2],1 do
                -- TODO consider other rotation directions
                local anchor = V(i, j)
                if self:CanRotateAt(anchor) and self:_WouldMoveResultInMatch(anchor, "Clockwise") then
                    hasMoves = true
                    break
                end
            end
        end
    end

    return hasMoves
end

---Swaps gem data according to rotator behaviour.
---@param anchor Vector2 Top-left gem coordinate.
---@param direction "Clockwise"|"Anti-clockwise"
---@return table
function Game:_RotateGemStates(anchor, direction)
    local gems = self:__GetAnchorGems(anchor)
    local newStates = {}
    local lastGem = direction == "Anti-clockwise" and gems[1] or gems[#gems]
    local indexDirection = direction == "Anti-clockwise" and 1 or -1
    for i=(direction == "Anti-clockwise" and 1 or #gems),(direction == "Anti-clockwise" and #gems or 1),indexDirection do
        local nextGem = gems[i + indexDirection] or lastGem
        newStates[i] = {Data = self:GetGemData(nextGem), Type = nextGem.Type, Modifiers = nextGem.Modifiers, OriginalPosition = V(self:GetGemGridCoordinates(nextGem))}
    end
    for i=1,#newStates,1 do
        local gem = gems[i]
        local newState = newStates[i]
        self:ApplyGemData(gem, newState.Data)
    end
    return newStates
end

---Returns whether a move would result in a match.
---@param anchor Vector2 Top-left gem coordinate.
---@param direction "Clockwise"|"Anti-clockwise"
function Game:_WouldMoveResultInMatch(anchor, direction)
    local otherDirection = direction == "Clockwise" and "Anti-clockwise" or "Clockwise"
    self:_RotateGemStates(anchor, direction)
    local wouldMatch = false
    local gems = self:__GetAnchorGems(anchor)
    for _,gem in ipairs(gems) do
        local pos = self:GetGemGridCoordinates(gem)
        local match = self:GetMatchAt(pos:unpack())
        if match ~= nil then
            wouldMatch = true
            break
        end
    end
    self:_RotateGemStates(anchor, otherDirection)
    return wouldMatch
end
