
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local BoardColumn = Bedazzled:GetClass("Feature_Bedazzled_Board_Column")
local BoardGem = Bedazzled:GetClass("Feature_Bedazzled_Board_Gem")
local Match = Bedazzled:GetClass("Feature_Bedazzled_Match")
local Fusion = Bedazzled:GetClass("Feature_Bedazzled_Match_Fusion")
local V = Vector.Create

---@class Feature_Bedazzled_Board
---@field GUID GUID
---@field _IsRunning boolean
---@field _Paused boolean
---@field Score integer
---@field MatchesSinceLastMove integer
---@field Size Vector2
---@field Columns Feature_Bedazzled_Board_Column[]
---@field _QueuedMatches Feature_Bedazzled_Match[]
local _Board = {
    Events = {
        Updated = {}, ---@type Event<Feature_Bedazzled_Board_Event_Updated>
        GemAdded = {}, ---@type Event<Feature_Bedazzled_Board_Event_GemAdded>
        MatchExecuted = {}, ---@type Event<Feature_Bedazzled_Board_Event_MatchExecuted>
        InvalidSwapPerformed = {}, ---@type Event<Feature_Bedazzled_Board_Event_InvalidSwapPerformed>
        GameOver = {}, ---@type Event<Feature_Bedazzled_Board_Event_GameOver>
        GemTransformed = {}, ---@type Event<Feature_Bedazzled_Board_Event_GemTransformed>
    }
}
Bedazzled:RegisterClass("Feature_Bedazzled_Board", _Board)

---------------------------------------------
-- EVENTS
---------------------------------------------

---@class Feature_Bedazzled_Board_Event_Updated
---@field DeltaTime number In seconds.

---@class Feature_Bedazzled_Board_Event_GemAdded
---@field Column Feature_Bedazzled_Board_Column
---@field Gem Feature_Bedazzled_Board_Gem

---@class Feature_Bedazzled_Board_Event_MatchExecuted
---@field Match Feature_Bedazzled_Match

---@class Feature_Bedazzled_Board_Event_InvalidSwapPerformed
---@field Gem1 Feature_Bedazzled_Board_Gem
---@field Gem2 Feature_Bedazzled_Board_Gem

---@class Feature_Bedazzled_Board_Event_GameOver

---@class Feature_Bedazzled_Board_Event_GemTransformed
---@field Gem Feature_Bedazzled_Gem
---@field OldType string
---@field NewType string

---------------------------------------------
-- METHODS
---------------------------------------------

---@param size Vector2
---@return Feature_Bedazzled_Board
function _Board.Create(size)
    ---@type Feature_Bedazzled_Board
    local board = {
        GUID = Text.GenerateGUID(),
        _IsRunning = true,
        _QueuedMatches = {},
        Score = 0,
        MatchesSinceLastMove = 0,
        Size = size,
        Columns = {},
        Events = {},
    }
    Inherit(board, _Board)

    -- Initialize events
    for k,_ in pairs(_Board.Events) do
        board.Events[k] = SubscribableEvent:New(k)
    end

    -- Initialize columns
    for i=1,size[1],1 do
        local column = BoardColumn.Create(i, size[2])

        board.Columns[i] = column
    end

    -- Register update event
    GameState.Events.RunningTick:Subscribe(function (ev)
        if not board:IsPaused() then
            board:Update(ev.DeltaTime / 1000)
        end
    end, {StringID = "Bedazzled_" .. board.GUID})

    return board
end

---@return integer
function _Board:GetScore()
    return self.Score
end

---@param dt number In seconds.
function _Board:Update(dt)
    -- Process queued matches
    for _,match in ipairs(self._QueuedMatches) do
        self:ConsumeMatch(match)
    end
    self._QueuedMatches = {}

    -- Update columns
    for i,column in ipairs(self.Columns) do
        -- Insert new gem
        if not column:IsFilled() then
            local desc = Bedazzled.GetRandomGemDescriptor()
            local startingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Falling"):Create()
            startingState.Velocity = Bedazzled.SPAWNED_GEM_INITIAL_VELOCITY

            local gem = BoardGem:Create(desc.Type, startingState)
            gem.X = i
            gem.Events.StateChanged:Subscribe(function (ev)
                self:OnGemStateChanged(gem, ev)
            end, {StringID = "DefaultBoardListener"})

            column:InsertGem(gem)

            self.Events.GemAdded:Throw({
                Gem = gem,
                Column = column,
            })
        end

        column:Update(dt)
    end

    -- Search for a match. Only a single match is processed per tick.
    -- The highest-scoring match is prioritized.
    local bestMatch = nil ---@type Feature_Bedazzled_Match
    for x=1,self.Size[2],1 do
        for y=1,self.Size[1],1 do
            local match = self:GetMatchAt(x, y)

            if match and (not bestMatch or match:GetScore() > bestMatch:GetScore()) then
                bestMatch = match
            end
        end
    end
    if bestMatch ~= nil then
        self:ConsumeMatch(bestMatch)
    end

    self.Events.Updated:Throw({DeltaTime = dt})

    -- Game over if all gems are idling with no moves available.
    if self:IsIdle() and not self:HasMovesAvailable() then
        self:EndGame()
    end
end

---Returns whether the game is still running.
---@return boolean
function _Board:IsRunning()
    return self._IsRunning
end

---Ends the game and stops the update loop.
function _Board:EndGame()
    if not self._IsRunning then
        Bedazzled:Error("Board:EndGame", "Attempted to end a board that is not running")
    end

    self._IsRunning = false
    self.Events.GameOver:Throw({})

    -- Stop updates
    GameState.Events.RunningTick:Unsubscribe("Bedazzled_" .. self.GUID)
end

---Returns the gems in a rect.
---@param upperLeft Vector2
---@param lowerRight Vector2
---@return Feature_Bedazzled_Board_Gem[]
function _Board:_GetGemsInArea(upperLeft, lowerRight)
    local gems = {}
    
    for i=upperLeft[1],lowerRight[1],1 do
        for j=lowerRight[2],upperLeft[2],1 do
            local gem = self:GetGemAt(i, j)

            table.insert(gems, gem)
        end
    end

    return gems
end

---@param match Feature_Bedazzled_Match
function _Board:ConsumeMatch(match)
    local consumingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Consuming")
    local fusingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Fusing")
    local transformingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Transforming")

    self.MatchesSinceLastMove = self.MatchesSinceLastMove + 1

    -- Consume gems
    for _,gem in ipairs(match.Gems) do
        local coords = self:GetGemGridCoordinates(gem)

        if gem:IsMatchable() then -- Only matchable gems can be consumed
            gem:SetState(consumingState:Create())
        end

        -- For each detonating gem in the match, queue a new match
        if gem:HasModifier("Rune") then
            local explosion = Match.Create(coords)
            gem:RemoveModifier("Rune")

            -- Add gems in a 3x3 area
            explosion:AddGems(self:_GetGemsInArea(V(coords[1] - 1, coords[2] + 1), V(coords[1] + 1, coords[2] - 1)))

            self:QueueMatch(explosion)
        elseif gem:HasModifier("LargeRune") then
            local lightning = Match.Create(coords)
            gem:RemoveModifier("LargeRune")

            -- Add gems in row
            lightning:AddGems(self:_GetGemsInArea(V(1, coords[2]), V(self.Size[2], coords[2])))

            -- Add gems in column
            lightning:AddGems(self:_GetGemsInArea(V(coords[1], self.Size[1]), V(coords[1], 1)))

            self:QueueMatch(lightning)
        elseif gem:HasModifier("GiantRune") then
            local supernova = Match.Create(coords)
            gem:RemoveModifier("GiantRune")

            -- Add gems in rows
            supernova:AddGems(self:_GetGemsInArea(V(1, coords[2] + 1), V(self.Size[2], coords[2] - 1)))

            -- Add gems in columns
            supernova:AddGems(self:_GetGemsInArea(V(coords[1] - 1, self.Size[1]), V(coords[1] + 1, 1)))

            self:QueueMatch(supernova)
        end
    end

    -- Fuse gems
    for _,fusion in ipairs(match.Fusions) do
        local target = fusion.TargetGem

        if fusion.TargetType then
            self:TransformGem(target, fusion.TargetType)
        end
        if fusion.TargetModifier then
            target:AddModifier(fusion.TargetModifier)
        end
        target:SetState(transformingState:Create())

        for _,gem in ipairs(fusion.FusingGems) do
            gem:SetState(fusingState:Create(target))
        end
    end

    self:AddScore(match:GetScore())

    self.Events.MatchExecuted:Throw({
        Match = match,
    })
end

---Increments the player's score.
---@param points integer
function _Board:AddScore(points)
    self.Score = self.Score + points
end

---@param x integer Column index.
---@param y integer Gem index within the column.
---@return Feature_Bedazzled_Board_Gem
function _Board:GetGemAt(x, y)
    local column = self.Columns[x]

    return column and column.Gems[y]
end

---Sets whether the board is paused.
---@see Feature_Bedazzled_Board.IsPaused
---@param paused boolean
function _Board:SetPaused(paused)
    self._Paused = paused
end

---Returns whether the board is paused.
---Paused boards do not run the update loop.
---@return boolean
function _Board:IsPaused()
    return self._Paused
end

---@param gem Feature_Bedazzled_Board_Gem
---@return Vector2
function _Board:GetGemGridCoordinates(gem)
    local position ---@type Vector2

    for x,column in ipairs(self.Columns) do
        local indexInColumn = column:GetGemIndex(gem)

        if indexInColumn then
            position = Vector.Create(x, indexInColumn)
        end
    end

    return position
end

---Swaps the type and data of 2 gems.
---@param gem1 Feature_Bedazzled_Board_Gem
---@param gem2 Feature_Bedazzled_Board_Gem
function _Board:_SwapGems(gem1, gem2)
    -- TODO use memento pattern
    gem1.Type, gem2.Type = gem2.Type, gem1.Type
    gem1.Modifiers, gem2.Modifiers = gem2.Modifiers, gem1.Modifiers
end

---@param gem1 Feature_Bedazzled_Board_Gem
---@param gem2 Feature_Bedazzled_Board_Gem
function _Board:CanSwap(gem1, gem2)
    local canSwap = true

    canSwap = canSwap and gem1 ~= gem2
    canSwap = canSwap and gem1:IsAdjacentTo(gem2)
    canSwap = canSwap and gem1:IsMatchable() and gem2:IsMatchable()

    -- Can only swap if it were to result in a valid move
    -- TODO consider falling gems
    -- Possible solution: have a method that returns a memento of the board including fall gems (but not busy ones) - and check matches there instead
    self:_SwapGems(gem1, gem2)
    local match1, match2 = self:GetMatchAt(self:GetGemGridCoordinates(gem1):unpack()), self:GetMatchAt(self:GetGemGridCoordinates(gem2):unpack())
    canSwap = canSwap and (match1 ~= nil or match2 ~= nil)

    -- Undo the swap
    self:_SwapGems(gem1, gem2)

    -- Can always swap hypercubes
    canSwap = canSwap or (gem1:GetDescriptor().Type == "Protean" or gem2:GetDescriptor().Type == "Protean")

    return canSwap
end

---@param position1 Vector2
---@param position2 Vector2
function _Board:Swap(position1, position2)
    local gem1 = self:GetGemAt(position1:unpack())
    local gem2 = self:GetGemAt(position2:unpack())

    if gem1 and gem2 then
        if self:CanSwap(gem1, gem2) then -- Swap gems
            -- Swap occurs instantly, but the gems cannot
            -- be matched until the Swapping state ends
            self:_SwapGems(gem1, gem2)
    
            local swappingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Swapping")
    
            gem1:SetState(swappingState:Create(gem2))
            gem2:SetState(swappingState:Create(gem1))

            -- Reset cascade counter
            self.MatchesSinceLastMove = 0
        elseif gem1:IsAdjacentTo(gem2) and gem1:IsIdle() and gem2:IsIdle() then -- Enter invalid swap busy state - only if gems are adjacent and idle
            local invalidSwapState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_InvalidSwap")
    
            gem1:SetState(invalidSwapState:Create(gem2))
            gem2:SetState(invalidSwapState:Create(gem1))

            self.Events.InvalidSwapPerformed:Throw({
                Gem1 = gem1,
                Gem2 = gem2,
            })
        end
    end
end

---Returns whether the board has any valid moves remaining.
---@return boolean
function _Board:HasMovesAvailable()
    local hasMoves = false
    local moveDirections = {
        V(-1, 0),
        V(1, 0),
        V(0, -1),
        V(0, 1),
    }

    for x=1,self.Size[2],1 do
        for y=1,self.Size[1],1 do
            for _,v in ipairs(moveDirections) do
                local pos = V(x, y)
                local gem1, gem2 = self:GetGemAt(pos:unpack()), self:GetGemAt((pos + v):unpack())

                if gem1 and gem2 and self:CanSwap(gem1, gem2) then
                    return true
                end
            end
        end
    end

    return hasMoves
end

---Returns whether all gems on the board are idle.
---@return boolean
function _Board:IsIdle()
    for x=1,self.Size[2],1 do
        for y=1,self.Size[1],1 do
            local pos = V(x, y)
            local gem = self:GetGemAt(pos:unpack())

            if not gem or not gem:IsIdle() then
                return false
            end
        end
    end

    return true
end

---Transforms a gem into another type.
---@param gem Feature_Bedazzled_Board_Gem
---@param newType string
function _Board:TransformGem(gem, newType)
    if not Bedazzled.GetGemDescriptor(newType) then
        Bedazzled:Error("Board:TransformGem", "Unregistered type", newType)
    end
    if not gem then
        Bedazzled:Error("Board:TransformGem", "Gem cannot be nil")
    end
    local oldType = gem.Type

    gem.Type = newType

    self.Events.GemTransformed:Throw({
        Gem = gem,
        OldType = oldType,
        NewType = newType,
    })
end

---Returns whether 2 gems can be matched.
---@param gem Feature_Bedazzled_Board_Gem
---@param otherGem Feature_Bedazzled_Board_Gem
---@return boolean
function _Board:IsGemMatchableWith(gem, otherGem)
    local matchable = true

    if gem == nil or otherGem == nil then
        Bedazzled:Error("Board:IsGemMatchableWith", "Attempted to compare nil gems")
    end

    matchable = matchable and gem:IsMatchable() and otherGem:IsMatchable()
    matchable = matchable and gem:GetDescriptor().Type == otherGem:GetDescriptor().Type

    return matchable
end

---Adds gems from a list to a match, following the default logic for fusions.
---@param match Feature_Bedazzled_Match Mutated.
---@param list Feature_Bedazzled_Board_Gem[]
function _Board:_AddGemsFromListToMatch(match, list)
    -- TODO prioritize fusing into swiped gem
    -- Only add gems if there were >= MINIMUM_MATCH_GEMS in the row/column
    if #list >= Bedazzled.MINIMUM_MATCH_GEMS then
        if #list >= 6 then -- Fuse into a supernova
            local fusion = Fusion.Create(list[1], "GiantRune", list)
            match:AddFusion(fusion)
        elseif #list >= 5 then -- Fuse into a hypercube
            local fusion = Fusion.Create(list[1], nil, list, "Protean")
            match:AddFusion(fusion)
        elseif #list >= 4 then -- Fuse into a Rune
            local fusion = Fusion.Create(list[2], "Rune", list)
            match:AddFusion(fusion)
        else -- Add gems for consumption
            for _,hgem in ipairs(list) do
                match:AddGem(hgem)
            end
        end
    end
end

---Returns the match that exists at the coordinates.
---@param x integer
---@param y integer
---@return Feature_Bedazzled_Match?
function _Board:GetMatchAt(x, y)
    local gem = self:GetGemAt(x, y)
    if not gem then return nil end

    local startingX = x
    local startingY = y
    local match = Match.Create(Vector.Create(x, y))

    -- Find starting X position for the match
    local otherGem = self:GetGemAt(x - 1, startingY)
    while otherGem and self:IsGemMatchableWith(gem, otherGem) do
        startingX = startingX - 1
        otherGem = self:GetGemAt(startingX - 1, y)
    end

    -- Add horizontal gems
    local horizontalGems = {}
    local currentX = startingX
    local horizontalGem = self:GetGemAt(currentX, y)
    while horizontalGem and self:IsGemMatchableWith(gem, horizontalGem) do
        table.insert(horizontalGems, horizontalGem)
        currentX = currentX + 1
        horizontalGem = self:GetGemAt(currentX, y)
    end

    -- Find starting Y position for the match
    otherGem = self:GetGemAt(x, startingY + 1)
    while otherGem and self:IsGemMatchableWith(gem, otherGem) do
        startingY = startingY + 1
        otherGem = self:GetGemAt(x, startingY + 1)
    end

    -- Add vertical gems
    local verticalGems = {}
    local currentY = startingY
    local verticalGem = self:GetGemAt(x, currentY)
    while verticalGem and self:IsGemMatchableWith(gem, verticalGem) do
        table.insert(verticalGems, verticalGem)
        currentY = currentY - 1
        verticalGem = self:GetGemAt(x, currentY)
    end

    local score = 0
    
    -- Fuse star matches into lightning gems
    if #horizontalGems >= 3 and #verticalGems >= 3 then
        local fusionTarget = horizontalGems[#horizontalGems]
        local fusingGems = {}

        -- TODO allow lightning gem + flame gem to generate at once
        for _,hgem in ipairs(horizontalGems) do
            table.insert(fusingGems, hgem)
        end
        for _,vgem in ipairs(verticalGems) do
            if not table.contains(fusingGems, vgem) then
                table.insert(fusingGems, vgem)
            end
        end

        local fusion = Fusion.Create(fusionTarget, "LargeRune", fusingGems)
        match:AddFusion(fusion)

        horizontalGems = {}
        verticalGems = {}
    end

    self:_AddGemsFromListToMatch(match, verticalGems)
    self:_AddGemsFromListToMatch(match, horizontalGems)

    -- 100 points awarded for each gem in the match beyond the 2nd.
    score = score + (1 + (match:GetGemCount() - Bedazzled.MINIMUM_MATCH_GEMS)) * 100

    -- Multiplier for cascades
    -- the var is incremented only after consuming matches,
    -- so in this context it is "1 match behind"
    score = score * (self.MatchesSinceLastMove + 1)

    match:SetScore(score)

    -- Discard the match if any gem is not idle.
    -- This allows matches to be stalled until "animation" states complete.
    for _,addedGem in ipairs(match:GetAllGems()) do
        if not addedGem:IsIdle() then
            match = nil
            break
        end
    end

    -- Discard matches that do not meet the minimum gem count.
    if match and match:GetGemCount() < Bedazzled.MINIMUM_MATCH_GEMS then
        match = nil
    end

    return match
end

---Queues a match to be consumed next tick.
---@param match Feature_Bedazzled_Match
function _Board:QueueMatch(match)
    table.insert(self._QueuedMatches, match)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

---Listen for gems changing states.
---@param gem Feature_Bedazzled_Board_Gem
---@param ev Feature_Bedazzled_Board_Gem_Event_StateChanged
function _Board:OnGemStateChanged(gem, ev)
    -- Queue matches for proteans.
    if ev.OldState.ClassName == "Feature_Bedazzled_Board_Gem_State_Swapping" and gem.Type == "Protean" then
        local zap = Match.Create(self:GetGemGridCoordinates(gem))
        local state = ev.OldState ---@type Feature_Bedazzled_Board_Gem_State_Swapping

        zap:AddGem(gem)

        for _,otherGem in ipairs(self:_GetGemsInArea(V(1, self.Size[1]), V(self.Size[2], 1))) do
            if otherGem.Type == state.OtherGem.Type then
                zap:AddGem(otherGem)
            end
        end

        self:QueueMatch(zap)
    end
end