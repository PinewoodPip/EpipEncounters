
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")
local V = Vector.Create

---@class Features.Bedazzled.GameModes.Classic : Features.Bedazzled.GameMode
local Game = {
    Name = Bedazzled:RegisterTranslatedString({
        Handle = "h40000864gc468g40a3g92d2g6f50c437f596",
        Text = "Classic",
        ContextDescription = "Game mode name",
    }),
    Name_Long = Bedazzled:RegisterTranslatedString({
        Handle = "hd58e1335gb503g49abg9c68g413cf2118d20",
        Text = "Bedazzled Classic",
        ContextDescription = "Long game mode name",
    }),
    Description = Bedazzled:RegisterTranslatedString({
        Handle = "hc076bb5dgc710g4bcagab45g7340fc67096e",
        Text = "Match gems by swapping adjacent ones around.",
        ContextDescription = [["Classic" game mode tooltip]],
    }),
}
Bedazzled:RegisterClass("Features.Bedazzled.GameModes.Classic", Game, {"Features.Bedazzled.GameMode"})

---------------------------------------------
-- METHODS
---------------------------------------------

---@param position1 Vector2
---@param position2 Vector2
function Game:Swap(position1, position2)
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

            self:ReportMove({
                Position = position1,
                InteractedGems = {gem1, gem2},
            })
        elseif gem1:IsAdjacentTo(gem2) and (not self:IsGemInteractable(gem1) or not self:IsGemInteractable(gem2)) then
            -- TODO use some state to show what's happening?
            self:ReportInvalidMove({
                Position = position1,
                InteractedGems = {gem1, gem2},
            })
        elseif gem1:IsAdjacentTo(gem2) and gem1:IsIdle() and gem2:IsIdle() then -- Enter invalid swap busy state - only if gems are adjacent and idle
            local invalidSwapState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_InvalidSwap")

            gem1:SetState(invalidSwapState:Create(gem2))
            gem2:SetState(invalidSwapState:Create(gem1))

            self:ReportInvalidMove({
                Position = position1,
                InteractedGems = {gem1, gem2},
            })
        end
    end
end

---Returns whether swapping two gems would result in a valid move, as well as on which which position a match would occur as a result.
---@param gem1 Feature_Bedazzled_Board_Gem
---@param gem2 Feature_Bedazzled_Board_Gem
---@return boolean, Vector2? -- Whether the move is valid and the position that would cause a match; might be `nil` if the move is valid but creates no match.
function Game:_CanSwap(gem1, gem2)
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

    -- Can swap hypercubes with anything
    canSwap = canSwap or (gem1:GetDescriptor().Type == "Protean" or gem2:GetDescriptor().Type == "Protean")

    -- Cannot swap non-interactable gems
    canSwap = canSwap and self:IsGemInteractable(gem1) and self:IsGemInteractable(gem2)

    local match = (match1 or match2)
    return canSwap, match and match.OriginPosition or nil
end

---Returns whether swapping two gems would result in a valid move.
---@param gem1 Feature_Bedazzled_Board_Gem
---@param gem2 Feature_Bedazzled_Board_Gem
function Game:CanSwap(gem1, gem2)
    local canSwap, _ = self:_CanSwap(gem1, gem2)
    return canSwap
end

---@override
function Game:GetHintPosition()
    local moveDirections = {
        V(-1, 0),
        V(1, 0),
        V(0, -1),
        V(0, 1),
    }
    -- Try swapping in each direction from each board position
    for x=1,self.Size[2],1 do
        for y=1,self.Size[1],1 do
            for _,v in ipairs(moveDirections) do
                local pos = V(x, y)
                local gem1, gem2 = self:GetGemAt(pos:unpack()), self:GetGemAt((pos + v):unpack())

                if gem1 and gem2 then
                    local canSwap, matchPos = self:_CanSwap(gem1, gem2)
                    if canSwap then
                        return matchPos or pos -- Fallback to position of gem 1 if the move is valid but creates no match (arbitrary choice)
                    end
                end
            end
        end
    end
    return nil
end

---@override
---@return boolean
function Game:HasMovesAvailable()
    local hasMoves = self:GetHintPosition() ~= nil
    return hasMoves
end

---Swaps the type and data of 2 gems.
---@param gem1 Feature_Bedazzled_Board_Gem
---@param gem2 Feature_Bedazzled_Board_Gem
function Game:_SwapGems(gem1, gem2)
    local data1, data2 = self:GetGemData(gem1), self:GetGemData(gem2)
    self:ApplyGemData(gem1, data2)
    self:ApplyGemData(gem2, data1)
end
