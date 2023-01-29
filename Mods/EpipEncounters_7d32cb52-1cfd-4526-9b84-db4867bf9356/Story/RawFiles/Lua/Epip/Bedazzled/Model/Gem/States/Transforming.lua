
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Board_Gem_State_Transforming : Feature_Bedazzled_Board_Gem_State
---@field TimeElapsed integer
local State = {
    Duration = 0.5,
}
Inherit(State, Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State"))
Bedazzled.RegisterGemStateClass("Feature_Bedazzled_Board_Gem_State_Transforming", State)

---------------------------------------------
-- METHODS
---------------------------------------------

function State:Create()
    ---@type Feature_Bedazzled_Board_Gem_State_Transforming
    local state = {
        TimeElapsed = 0,
    }
    Inherit(state, self)

    return state
end

function State:Update(dt)
    self.TimeElapsed = self.TimeElapsed + dt

    -- Transition back to idle
    if self.TimeElapsed >= self.Duration then
        local idleState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Idle")

        self.Gem:SetState(idleState:Create())
    end
end

function State:IsBusy()
    return true
end

function State:IsMatchable()
    return false
end