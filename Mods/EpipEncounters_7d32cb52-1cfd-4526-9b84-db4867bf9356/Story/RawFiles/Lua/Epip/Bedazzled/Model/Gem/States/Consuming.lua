
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Board_Gem_State_Consuming : Feature_Bedazzled_Board_Gem_State
---@field TimeElapsed integer
local State = {
    Duration = 0.4,
}
Inherit(State, Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State"))
Bedazzled.RegisterGemStateClass("Feature_Bedazzled_Board_Gem_State_Consuming", State)

---------------------------------------------
-- METHODS
---------------------------------------------

function State:Create()
    ---@type Feature_Bedazzled_Board_Gem_State_InvalidSwap
    local state = {
        TimeElapsed = 0,
    }
    Inherit(state, self)

    return state
end

function State:Update(dt)
    self.TimeElapsed = self.TimeElapsed + dt
end

function State:IsConsumed()
    return self.TimeElapsed >= self.Duration
end