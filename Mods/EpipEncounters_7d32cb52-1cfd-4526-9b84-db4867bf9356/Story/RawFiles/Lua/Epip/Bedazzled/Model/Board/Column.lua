
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Board_Column
---@field Index integer
---@field Size integer
---@field Gems Feature_Bedazzled_Board_Gem[] From bottom to top.
local _BoardColumn = {
    Events = {},
}
Bedazzled:RegisterClass("Feature_Bedazzled_Board_Column", _BoardColumn)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param size integer
---@return Feature_Bedazzled_Board_Column
function _BoardColumn.Create(index, size)
    ---@type Feature_Bedazzled_Board_Column
    local obj = {
        Index = index,
        Size = size,
        Gems = {},
        Events = {},
    }
    Inherit(obj, _BoardColumn)

    -- Initialize events
    for k,_ in pairs(_BoardColumn.Events) do
        obj.Events[k] = SubscribableEvent:New(k)
    end

    return obj
end

---Returns the index of a gem within the column.
---Ignores whether a gem is falling;
---the index indicates the order of the gem within the whole column,
---regardless of where it currently physically is.
---@param gem Feature_Bedazzled_Board_Gem
---@return integer? --Fails if the gem is not in the column.
function _BoardColumn:GetGemIndex(gem)
    local index

    for i,cgem in ipairs(self.Gems) do
        if cgem == gem then
            index = i
            break
        end
    end

    return index
end

---@param gem Feature_Bedazzled_Board_Gem
function _BoardColumn:InsertGem(gem)
    -- Initial position is at the top of the board,
    -- so the gem falls in
    local startingPosition = (self.Size + #self.Gems + 1) * Bedazzled.GEM_SIZE
    gem:SetPosition(startingPosition)

    table.insert(self.Gems, gem)
end

---@return boolean
function _BoardColumn:IsFilled()
    return #self.Gems >= self.Size
end

---@param dt number In seconds.
function _BoardColumn:Update(dt)
    -- Remove consumed gems -- TODO fire event
    for i=#self.Gems,1,-1 do
        local gem = self.Gems[i]
        if gem:IsConsumed() then
            table.remove(self.Gems, i)
        end
    end

    -- the position of the last busy *or* falling gem
    local lastBusyGemPosition = nil
    for i,gem in ipairs(self.Gems) do
        local targetPosition = (i - 1) * gem:GetSize()

        if gem:IsFalling() then
            local state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_Falling
            state.TargetPosition = targetPosition
            state.StallingPosition = lastBusyGemPosition and lastBusyGemPosition + gem:GetSize()

            lastBusyGemPosition = gem:GetPosition()
        elseif gem:IsBusy() then
            lastBusyGemPosition = gem:GetPosition() + gem:GetSize()
        elseif gem:GetPosition() ~= targetPosition and not gem:IsBusy() then -- If a gem is not in its target position, cause it to fall
            gem:SetState(Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Falling"):Create())

            local state = gem.State ---@type Feature_Bedazzled_Board_Gem_State_Falling
            state.TargetPosition = targetPosition
            state.StallingPosition = lastBusyGemPosition
            state.Velocity = Bedazzled.SPAWNED_GEM_INITIAL_VELOCITY
        end

        gem:Update(dt)
    end
end