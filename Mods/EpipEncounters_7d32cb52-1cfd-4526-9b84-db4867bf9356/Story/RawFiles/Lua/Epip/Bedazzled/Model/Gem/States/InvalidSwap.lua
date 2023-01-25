
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Board_Gem_State_InvalidSwap : Feature_Bedazzled_Board_Gem_State
---@field OtherGem Feature_Bedazzled_Board_Gem
---@field TimeElapsed integer
local State = {
    Duration = 0.4,
}
Inherit(State, Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State"))
Bedazzled.RegisterGemStateClass("Feature_Bedazzled_Board_Gem_State_InvalidSwap", State)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param otherGem Feature_Bedazzled_Board_Gem
function State:Create(otherGem)
    ---@type Feature_Bedazzled_Board_Gem_State_InvalidSwap
    local state = {
        TimeElapsed = 0,
        OtherGem = otherGem,
    }
    Inherit(state, self)

    return state
end

function State:Update(dt)
    self.TimeElapsed = self.TimeElapsed + dt

    if self.TimeElapsed >= self.Duration then
        local idleState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Idle")

        self.Gem:SetState(idleState:Create())
    end
end