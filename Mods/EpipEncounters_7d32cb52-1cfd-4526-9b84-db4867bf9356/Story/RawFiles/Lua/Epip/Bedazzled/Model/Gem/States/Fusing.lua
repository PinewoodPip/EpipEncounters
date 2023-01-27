
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Board_Gem_State_Fusing : Feature_Bedazzled_Board_Gem_State
---@field TargetGem Feature_Bedazzled_Board_Gem
---@field TimeElapsed integer
local State = {
    Duration = 0.5,
}
Inherit(State, Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State"))
Bedazzled.RegisterGemStateClass("Feature_Bedazzled_Board_Gem_State_Fusing", State)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param targetGem Feature_Bedazzled_Board_Gem
function State:Create(targetGem)
    ---@type Feature_Bedazzled_Board_Gem_State_Fusing
    local state = {
        TargetGem = targetGem,
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

function State:IsBusy()
    return true
end

function State:IsMatchable()
    return false
end