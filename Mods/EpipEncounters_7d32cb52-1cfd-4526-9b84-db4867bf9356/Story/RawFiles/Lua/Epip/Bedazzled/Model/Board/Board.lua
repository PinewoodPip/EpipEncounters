
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local BoardColumn = Bedazzled:GetClass("Feature_Bedazzled_Board_Column")
local BoardGem = Bedazzled:GetClass("Feature_Bedazzled_Board_Gem")
local Match = Bedazzled:GetClass("Feature_Bedazzled_Match")

---@class Feature_Bedazzled_Board
---@field Score integer
---@field Size Vector2
---@field Columns Feature_Bedazzled_Board_Column[]
local _Board = {
    Events = {
        Updated = {}, ---@type Event<Feature_Bedazzled_Board_Event_Updated>
        GemAdded = {}, ---@type Event<Feature_Bedazzled_Board_Event_GemAdded>
        MatchExecuted = {}, ---@type Event<Feature_Bedazzled_Board_Event_MatchExecuted>
        InvalidSwapPerformed = {}, ---@type Event<Feature_Bedazzled_Board_Event_InvalidSwapPerformed>
    }
}
Bedazzled:RegisterClass("Feature_Bedazzled_Board", _Board)

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

---@param size Vector2
---@return Feature_Bedazzled_Board
function _Board.Create(size)
    ---@type Feature_Bedazzled_Board
    local board = {
        Score = 0,
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
        board:Update(ev.DeltaTime / 1000)
    end)

    return board
end

function _Board:GetScore()
    return self.Score
end

---@param dt number In seconds.
function _Board:Update(dt)
    for i,column in ipairs(self.Columns) do
        -- Insert new gem
        if not column:IsFilled() then
            local desc = Bedazzled.GetRandomGemDescriptor()
            local startingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Falling"):Create()
            startingState.Velocity = Bedazzled.SPAWNED_GEM_INITIAL_VELOCITY

            local gem = BoardGem:Create(desc.Type, startingState)
            gem.X = i

            column:InsertGem(gem)

            self.Events.GemAdded:Throw({
                Gem = gem,
                Column = column,
            })
        end

        column:Update(dt)
    end

    -- Search for a match. Only one match is processed per tick.
    local match ---@type Feature_Bedazzled_Match
    -- local match = self:GetMatchAt(1, 1)
    for x=1,self.Size[2],1 do
        for y=1,self.Size[1],1 do
            match = self:GetMatchAt(x, y)

            if match then
                break
            end
        end

        if match then
            break
        end
    end

    if match then
        self:ConsumeMatch(match)
    end

    self.Events.Updated:Throw({DeltaTime = dt})
end

---@param match Feature_Bedazzled_Match
function _Board:ConsumeMatch(match)
    local consumingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Consuming")

    for _,gem in ipairs(match.Gems) do
        gem:SetState(consumingState:Create())    
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

---@param gem1 Feature_Bedazzled_Board_Gem
---@param gem2 Feature_Bedazzled_Board_Gem
function _Board:CanSwap(gem1, gem2)
    local canSwap = true

    canSwap = canSwap and gem1 ~= gem2
    canSwap = canSwap and gem1:IsAdjacentTo(gem2)
    canSwap = canSwap and not gem1:IsBusy() and not gem2:IsBusy()

    -- Can only swap if it were to result in a valid move
    -- TODO consider falling gems
    -- Possible solution: have a method that returns a memento of the board including fall gems (but not busy ones) - and check matches there instead
    gem1.Type, gem2.Type = gem2.Type, gem1.Type
    local match1, match2 = self:GetMatchAt(self:GetGemGridCoordinates(gem1):unpack()), self:GetMatchAt(self:GetGemGridCoordinates(gem2):unpack())
    canSwap = canSwap and (match1 ~= nil or match2 ~= nil)

    -- Undo the swap
    gem1.Type, gem2.Type = gem2.Type, gem1.Type

    return canSwap
end

---@param position1 Vector2
---@param position2 Vector2
function _Board:Swap(position1, position2)
    local gem1 = self:GetGemAt(position1:unpack())
    local gem2 = self:GetGemAt(position2:unpack())

    if gem1 and gem2 then
        if self:CanSwap(gem1, gem2) then
            gem1.Type, gem2.Type = gem2.Type, gem1.Type
    
            local swappingState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Swapping")
    
            gem1:SetState(swappingState:Create(gem2))
            gem2:SetState(swappingState:Create(gem1))
        elseif gem1:IsAdjacentTo(gem2) then -- Enter invalid swap busy state - only if gems are adjacent
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

    -- Only add gems if there were >= MINIMUM_MATCH_GEMS in the row/column
    if #horizontalGems >= Bedazzled.MINIMUM_MATCH_GEMS then
        for _,hgem in ipairs(horizontalGems) do
            match:AddGem(hgem)
        end

        score = score + (1 + (#horizontalGems - Bedazzled.MINIMUM_MATCH_GEMS)) * 100
    end
    if #verticalGems >= Bedazzled.MINIMUM_MATCH_GEMS then
        for _,vgem in ipairs(verticalGems) do
            match:AddGem(vgem)
        end

        score = score + (1 + (#verticalGems - Bedazzled.MINIMUM_MATCH_GEMS)) * 100
    end

    match:SetScore(score)

    return match:GetGemCount() >= Bedazzled.MINIMUM_MATCH_GEMS and match or nil
end