
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local BoardColumn = Bedazzled:GetClass("Feature_Bedazzled_Board_Column")
local BoardGem = Bedazzled:GetClass("Feature_Bedazzled_Board_Gem")
local Match = Bedazzled:GetClass("Feature_Bedazzled_Match")
local Fusion = Bedazzled:GetClass("Feature_Bedazzled_Match_Fusion")
local V = Vector.Create

---@class Feature_Bedazzled_Board : Class
---@field GUID GUID
---@field GameMode Feature_Bedazzled_GameMode_ID
---@field _IsRunning boolean
---@field _Paused boolean
---@field Score integer
---@field MovesMade integer
---@field TimeElapsed number In seconds, ticked while the board is updating.
---@field HintCooldown number Time since the last valid move in seconds, ticked while the board is updating.
---@field GemsSpawned integer Total amount of gems spawned naturally.
---@field MatchesSinceLastMove integer
---@field Size Vector2
---@field Columns Feature_Bedazzled_Board_Column[]
---@field _QueuedMatches Feature_Bedazzled_Match[]
---@field _Modifiers table<classname, Features.Bedazzled.Board.Modifier>
---@field _ShouldCheckOutOfMovesGameOver boolean
local _Board = {
    HINT_COOLDOWN = 25, -- In seconds.

    Events = {
        Updated = {}, ---@type Event<Feature_Bedazzled_Board_Event_Updated>
        GemAdded = {}, ---@type Event<Feature_Bedazzled_Board_Event_GemAdded>
        MatchExecuted = {}, ---@type Event<Feature_Bedazzled_Board_Event_MatchExecuted>
        GameOver = {}, ---@type Event<Feature_Bedazzled_Board_Event_GameOver>
        GemTransformed = {}, ---@type Event<Feature_Bedazzled_Board_Event_GemTransformed>
        -- TODO move these to GameMode class
        MovePerformed = {}, ---@type Event<Features.Bedazzled.GameMode.Events.MovePerformed>
        InvalidMovePerformed = {}, ---@type Event<Features.Bedazzled.GameMode.Events.InvalidMovePerformed>
        GemDataApplied = {}, ---@type Event<Features.Bedazzled.Board.Events.GemDataApplied>
        HintRequested = {}, ---@type Event<Features.Bedazzled.Board.Events.HintRequested>
    },
    Hooks = {
        IsInteractable = {}, ---@type Hook<Features.Bedazzled.Board.Hooks.IsInteractable>
        GetGemData = {}, ---@type Hook<Features.Bedazzled.Board.Hooks.GetGemData>
        GetMatchAt = {}, ---@type Hook<Features.Bedazzled.Board.Hooks.GetMatchAt>
        GemGemSpawnWeight = {}, ---@type Hook<Features.Bedazzled.Board.Hooks.GetGemSpawnWeight>
        IsGemInteractable = {}, ---@type Hook<Features.Bedazzled.Board.Hooks.IsGemInteractable>
    },
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

---@class Feature_Bedazzled_Board_Event_GameOver
---@field Score integer
---@field Reason string

---@class Feature_Bedazzled_Board_Event_GemTransformed
---@field Gem Feature_Bedazzled_Gem
---@field OldType string
---@field NewType string

---@class Features.Bedazzled.Board.Events.GemDataApplied
---@field Gem Feature_Bedazzled_Board_Gem
---@field Data Features.Bedazzled.Board.Gem.Data

---@class Features.Bedazzled.Board.Events.HintRequested
---@field Position Vector2

---@class Features.Bedazzled.Board.Hooks.IsInteractable
---@field Interactable boolean Hookable. Defaults to `true`.

---@class Features.Bedazzled.Board.Hooks.GetGemData
---@field Gem Feature_Bedazzled_Board_Gem
---@field Data Features.Bedazzled.Board.Gem.Data Hookable.

---Thrown after all base logic has executed, including checks for minimum gem count in the match.
---@class Features.Bedazzled.Board.Hooks.GetMatchAt
---@field Match Feature_Bedazzled_Match? Hookable.
---@field Position Vector2

---@class Features.Bedazzled.Board.Hooks.GetGemSpawnWeight
---@field Descriptor Feature_Bedazzled_Gem
---@field Weight number Hookable. Defaults to the weight set within the descriptor.

---@class Features.Bedazzled.Board.Hooks.IsGemInteractable
---@field Gem Feature_Bedazzled_Board_Gem
---@field Interactable boolean Hookable. Defaults to `true`.

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates a board.
---@param size Vector2
---@return Feature_Bedazzled_Board
function _Board:Create(size)
    local board = self:__Create({
        GUID = Text.GenerateGUID(),
        _IsRunning = true,
        _QueuedMatches = {},
        Score = 0,
        MovesMade = 0,
        TimeElapsed = 0,
        HintCooldown = self.HINT_COOLDOWN,
        GemsSpawned = 0,
        MatchesSinceLastMove = 0,
        Size = size,
        Columns = {},
        Events = {},
        _Modifiers = {},
        _ShouldCheckOutOfMovesGameOver = false,
    }) ---@cast board Feature_Bedazzled_Board

    board.GameMode = board:GetClassName() -- Legacy field. TODO remove?

    -- Initialize events and hooks
    for k,_ in pairs(self.Events) do
        board.Events[k] = SubscribableEvent:New(k)
    end
    for k,_ in pairs(self.Hooks) do
        board.Hooks[k] = SubscribableEvent:New(k)
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

---Applies a game modifier.
---@param modifier Features.Bedazzled.Board.Modifier
function _Board:ApplyModifier(modifier)
    local modClassName = modifier:GetClassName()
    if self._Modifiers[modClassName] then
        self:__Error("ApplyModifier", "Modifier already applied:", modClassName)
    end

    self._Modifiers[modClassName] = modifier

    modifier:Apply(self)
end

---Returns the active modifiers.
---@return table<classname, Features.Bedazzled.Board.Modifier>
function _Board:GetModifiers()
    return self._Modifiers
end

---Returns the active modifier configs.
---@return Features.Bedazzled.ModifierSet
function _Board:GetModifierConfigs()
    local set = {} ---@type Features.Bedazzled.ModifierSet
    for className,mod in pairs(self._Modifiers) do
        set[className] = mod:GetConfigurationSchema()
    end
    return set
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
            local desc = self:GetRandomGemDescriptor()
            local startingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Falling"):Create()
            startingState.Velocity = Bedazzled.SPAWNED_GEM_INITIAL_VELOCITY

            local gem = BoardGem:Create(desc.Type, startingState)
            gem.X = i
            gem.Events.StateChanged:Subscribe(function (ev)
                self:OnGemStateChanged(gem, ev)
            end, {StringID = "DefaultBoardListener"})

            column:InsertGem(gem)

            self.GemsSpawned = self.GemsSpawned + 1

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

    -- Increment time tracker
    self.TimeElapsed = self.TimeElapsed + dt
    self.HintCooldown = self.HintCooldown - dt
    if self.HintCooldown < 0 then -- Show hint if we crossed the time threshold.
        self:RequestHint()
    end

    self.Events.Updated:Throw({DeltaTime = dt})

    -- Game over if all gems are idling with no moves available.
    self:_CheckOutOfMovesGameOver()
end

---Requests a hint for a board position where a move can be made and resets the automatic hint cooldown.
---@see Features.Bedazzled.Board.Events.HintRequested
---@return Vector2 -- Board position from which a valid move can be made.
function _Board:RequestHint()
    local hintPos = self:GetHintPosition()
    if hintPos then
        self.Events.HintRequested:Throw({
            Position = hintPos
        })
    end
    self.HintCooldown = self.HINT_COOLDOWN
    return hintPos
end

---Returns a position on the board from which a valid move can be made.
---@abstract
---@return Vector2? -- `nil` if no valid moves remain.
function _Board:GetHintPosition()
    self:__ThrowNotImplemented("GetHintPosition")
end

---Checks whether the game should end from having no valid moves on the board.
function _Board:_CheckOutOfMovesGameOver()
    -- IsRunning() check is necessary in case the game ended during the Updated event.
    -- A boolean is used to minimize how often this check runs,
    -- as it can be very expensive.
    if self._ShouldCheckOutOfMovesGameOver and self:IsRunning() and self:IsIdle() then
        if not self:HasMovesAvailable() then
            self:EndGame(Bedazzled.TranslatedStrings.GameOver_Reason_NoMoreMoves)
        end
        self._ShouldCheckOutOfMovesGameOver = false
    end
end

---Returns whether the game is still alive (not in a game over state).
---@return boolean
function _Board:IsRunning()
    return self._IsRunning
end

---Returns whether the user can currently interact with the board.
---@see Features.Bedazzled.Board.Hooks.IsInteractable
---@return boolean
function _Board:IsInteractable()
    return self.Hooks.IsInteractable:Throw({Interactable = true}).Interactable
end

---Returns whether a gem can be interacted with by the player, making it usable within moves.
---@see Features.Bedazzled.Board.Hooks.IsGemInteractable
---@param gem Feature_Bedazzled_Board_Gem
---@return boolean
function _Board:IsGemInteractable(gem)
    return self.Hooks.IsGemInteractable:Throw({
        Gem = gem,
        Interactable = true,
    }).Interactable
end

---Returns a random gem descriptor, weighted.
---@see Features.Bedazzled.Board.Hooks.GetGemSpawnWeight
---@return Feature_Bedazzled_Gem
function _Board:GetRandomGemDescriptor()
    local totalWeight = 0
    local gems = {} ---@type Feature_Bedazzled_Gem[]
    local gemWeights = {} ---@type table<string, number>
    local chosenGem

    for _,gem in pairs(Bedazzled.GetGemDescriptors()) do
        local gemWeight = self.Hooks.GemGemSpawnWeight:Throw({
            Descriptor = gem,
            Weight = gem.Weight,
        }).Weight
        totalWeight = totalWeight + gemWeight
        gemWeights[gem.Type] = gemWeight
        table.insert(gems, gem)
    end

    if totalWeight == 0 then
        self:__Error("GetRandomGemDescriptor", "No gem descriptors with positive weight exist")
    end

    local seed = math.random() * totalWeight
    for _,g in ipairs(gems) do
        seed = seed - gemWeights[g.Type]

        if seed <= 0 and gemWeights[g.Type] > 0 then -- Never choose gems with 0 weight, if 0 was the seed.
            chosenGem = g
            break
        end
    end

    return chosenGem
end

---Ends the game and stops the update loop.
---@param reason TextLib_String Description of why the game ended.
function _Board:EndGame(reason)
    if not self._IsRunning then
        self:__Error("EndGame", "Attempted to end a board that is not running")
    end

    local finalScore = self:GetScore()

    self._IsRunning = false
    self.Events.GameOver:Throw({
        Score = finalScore,
        Reason = Text.Resolve(reason),
    })

    -- Stop updates
    GameState.Events.RunningTick:Unsubscribe("Bedazzled_" .. self.GUID)

    -- Update statistics
    Bedazzled.IncrementStatistic(Bedazzled.Settings.PlayTime, self.TimeElapsed)
    Bedazzled.IncrementStatistic(Bedazzled.Settings.GamesPlayed)

    -- Save statistics and other settings
    Bedazzled:SaveSettings()
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

    -- Consume gems and queue matches from special gems
    for _,gem in ipairs(match:GetAllGems()) do
        local coords = self:GetGemGridCoordinates(gem)

        if gem:IsMatchable() and match:WillConsumeGem(gem) then -- Only matchable gems can be consumed
            gem:SetState(consumingState:Create())
        end

        -- For each detonating gem in the match, queue a new match
        -- Gems cannot detonate while transforming,
        -- preventing matches with detonations from immediately detonating any newly created special gems
        if gem.State.ClassName ~= "Feature_Bedazzled_Board_Gem_State_Transforming" then
            if gem:HasModifier("Rune") then
                local explosion = Match.Create(coords, Match.REASONS.EXPLOSION)
                explosion:SetScore(self:ApplyScoreMultiplier(Bedazzled.BASE_SCORING.MEDIUM_RUNE_DETONATION))
                gem:RemoveModifier("Rune")

                -- Add gems in a 3x3 area
                explosion:AddGems(self:_GetGemsInArea(V(coords[1] - 1, coords[2] + 1), V(coords[1] + 1, coords[2] - 1)))

                self:QueueMatch(explosion)
            elseif gem:HasModifier("LargeRune") then
                local lightning = Match.Create(coords, Match.REASONS.EXPLOSION)
                lightning:SetScore(self:ApplyScoreMultiplier(Bedazzled.BASE_SCORING.LARGE_RUNE_DETONATION))
                gem:RemoveModifier("LargeRune")

                -- Add gems in row
                lightning:AddGems(self:_GetGemsInArea(V(1, coords[2]), V(self.Size[2], coords[2])))

                -- Add gems in column
                lightning:AddGems(self:_GetGemsInArea(V(coords[1], self.Size[1]), V(coords[1], 1)))

                self:QueueMatch(lightning)
            elseif gem:HasModifier("GiantRune") then
                local supernova = Match.Create(coords, Match.REASONS.EXPLOSION)
                supernova:SetScore(self:ApplyScoreMultiplier(Bedazzled.BASE_SCORING.GIANT_RUNE_DETONATION))
                gem:RemoveModifier("GiantRune")

                -- Add gems in rows
                supernova:AddGems(self:_GetGemsInArea(V(1, coords[2] + 1), V(self.Size[2], coords[2] - 1)))

                -- Add gems in columns
                supernova:AddGems(self:_GetGemsInArea(V(coords[1] - 1, self.Size[1]), V(coords[1] + 1, 1)))

                self:QueueMatch(supernova)
            end
        end

        -- Increment gem consumption statistics;
        -- these intentionally also consider gems that are fused or transformed.
        -- Matches with 0 score are not considered to be caused by the player.
        if match.Score > 0 then
            Bedazzled.IncrementStatistic(Bedazzled.Settings.GemsConsumed)
            if gem.Type == "Epipe" then
                Bedazzled.IncrementStatistic(Bedazzled.Settings.EpipesConsumed)
            end
        end
    end

    self.MatchesSinceLastMove = self.MatchesSinceLastMove + 1

    -- Fuse gems
    for _,fusion in ipairs(match.Fusions) do
        local target = fusion.TargetGem

        if fusion.TargetType then
            self:TransformGem(target, fusion.TargetType)

            -- Increment Callisto creation statistic
            if fusion.TargetType == "Protean" then
                Bedazzled.IncrementStatistic(Bedazzled.Settings.CallistoAnomaliesCreated)
            end
        end
        if fusion.TargetModifier then
            target:AddModifier(fusion.TargetModifier)

            -- Increment rune creation statistics
            if fusion.TargetModifier == "Rune" then
                Bedazzled.IncrementStatistic(Bedazzled.Settings.SmallRunesCreated)
            elseif fusion.TargetModifier == "LargeRune" then
                Bedazzled.IncrementStatistic(Bedazzled.Settings.LargeRunesCreated)
            elseif  fusion.TargetModifier == "GiantRune" then
                Bedazzled.IncrementStatistic(Bedazzled.Settings.GiantRunesCreated)
            end
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

---Returns all gems currently on the board.
---@return Feature_Bedazzled_Board_Gem[]
function _Board:GetGems()
    local gems = {} ---@type Feature_Bedazzled_Board_Gem[]
    for _,column in ipairs(self.Columns) do
        for _,gem in ipairs(column.Gems) do
            table.insert(gems, gem)
        end
    end
    return gems
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

---Returns whether the board has any valid moves remaining.
---@abstract
---@return boolean
function _Board:HasMovesAvailable()
    ---@diagnostic disable-next-line: missing-return
    self:__ThrowNotImplemented("HasMovesAvailable")
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

---Returns whether there are gems being interacted with (ex. swapping).
---@return boolean
function _Board:IsInteracting()
    for x=1,self.Size[2],1 do
        for y=1,self.Size[1],1 do
            local pos = V(x, y)
            local gem = self:GetGemAt(pos:unpack())
            if gem and gem.State:IsBeingInteracted() then
                return true
            end
        end
    end
    return false
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

---Returns the game data for a gem.
---@see Features.Bedazzled.Board.Hooks.GetGemData
---@param gem Feature_Bedazzled_Board_Gem
---@return Features.Bedazzled.Board.Gem.Data
function _Board:GetGemData(gem)
    -- TODO move to Gem
    ---@type Features.Bedazzled.Board.Gem.Data
    local data = {
        Type = gem.Type,
        Modifiers = gem.Modifiers,
    }
    data = self.Hooks.GetGemData:Throw({
        Gem = gem,
        Data = data,
    }).Data
    return data
end

---Applies data properties onto a gem.
---@param gem Feature_Bedazzled_Board_Gem
---@param data Features.Bedazzled.Board.Gem.Data
function _Board:ApplyGemData(gem, data)
    gem.Type = data.Type
    gem.Modifiers = data.Modifiers:Clone()

    self.Events.GemDataApplied:Throw({
        Gem = gem,
        Data = data,
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
---**Assumes that all gems within the list are of the same type.**
---@param match Feature_Bedazzled_Match Mutated.
---@param list Feature_Bedazzled_Board_Gem[]
function _Board:_AddGemsFromListToMatch(match, list)
    -- TODO prioritize fusing into swiped gem
    -- Only add gems if there were >= MINIMUM_MATCH_GEMS in the row/column
    if #list >= Bedazzled.MINIMUM_MATCH_GEMS then
        local isFusable = list[1].Type ~= "Epipe" -- Epipes cannot accept modifiers.
        if #list >= 6 and isFusable then -- Fuse into a supernova
            local fusion = Fusion.Create(list[1], "GiantRune", list)
            match:AddFusion(fusion)
        elseif #list >= 5 and isFusable then -- Fuse into a hypercube
            local fusion = Fusion.Create(list[1], nil, list, "Protean")
            match:AddFusion(fusion)
        elseif #list >= 4 and isFusable then -- Fuse into a Rune
            local fusion = Fusion.Create(list[2], "Rune", list)
            match:AddFusion(fusion)
        else -- Add gems for consumption
            for _,hgem in ipairs(list) do
                match:AddGem(hgem)
            end
        end
    end
end

---Returns the current score multiplier.
---@return number
function _Board:GetScoreMultiplier()
    return (self.MatchesSinceLastMove + 1)
end

---Multiplies a score by the current score multiplier.
---@param baseScore number
---@return number
function _Board:ApplyScoreMultiplier(baseScore)
    return baseScore * self:GetScoreMultiplier()
end

---Returns the match that exists at the coordinates.
---@see Features.Bedazzled.Board.Hooks.GetMatchAt
---@param x integer
---@param y integer
---@return Feature_Bedazzled_Match?
function _Board:GetMatchAt(x, y)
    local gem = self:GetGemAt(x, y)
    if not gem then return nil end

    local startingX = x
    local startingY = y
    local match = Match.Create(Vector.Create(x, y), Match.REASONS.PLAYER_MOVE)

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
    score = score + (1 + (match:GetGemCount() - Bedazzled.MINIMUM_MATCH_GEMS)) * Bedazzled.BASE_SCORING.MATCH

    -- Multiplier for cascades
    -- the var is incremented only after consuming matches,
    -- so in this context it is "1 match behind"
    score = score * self:GetScoreMultiplier()

    if self.MatchesSinceLastMove > 0 then
        match:SetReason(Match.REASONS.CASCADE)
    end

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

    match = self.Hooks.GetMatchAt:Throw({
        Match = match,
        Position = V(x, y),
    }).Match

    return match
end

---Queues a match to be consumed next tick.
---@param match Feature_Bedazzled_Match
function _Board:QueueMatch(match)
    table.insert(self._QueuedMatches, match)
end

---Queues gems to be zapped by a Callisto Anomaly gem.
---@param gem Feature_Bedazzled_Board_Gem Will be consumed.
---@param types table<Feature_Bedazzled_GemDescriptor_ID, true>
function _Board:QueueCallistoAnomalyZap(gem, types)
    local zap = Match.Create(self:GetGemGridCoordinates(gem), Match.REASONS.PLAYER_MOVE)

    zap:AddGem(gem)

    for _,otherGem in ipairs(self:GetGems()) do
        if types[otherGem.Type] then
            zap:AddGem(otherGem)
        end
    end

    local gemsZapped = zap:GetGemCount() - 1 -- Excludes the Callisto Anomaly itself
    zap:SetScore(self:ApplyScoreMultiplier(Bedazzled.BASE_SCORING.PROTEAN_PER_GEM * gemsZapped))

    self:QueueMatch(zap)
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
        local zap = Match.Create(self:GetGemGridCoordinates(gem), Match.REASONS.PLAYER_MOVE)
        local state = ev.OldState ---@type Feature_Bedazzled_Board_Gem_State_Swapping

        zap:AddGem(gem)

        for _,otherGem in ipairs(self:_GetGemsInArea(V(1, self.Size[1]), V(self.Size[2], 1))) do
            if otherGem.Type == state.OtherGem.Type then
                zap:AddGem(otherGem)
            end
        end

        local gemsZapped = zap:GetGemCount() - 1 -- Excludes the protean itself
        zap:SetScore(self:ApplyScoreMultiplier(Bedazzled.BASE_SCORING.PROTEAN_PER_GEM * gemsZapped))

        self:QueueMatch(zap)
    end

    -- Queue checks for running out of valid moves anytime a gem changes state.
    self._ShouldCheckOutOfMovesGameOver = true
end