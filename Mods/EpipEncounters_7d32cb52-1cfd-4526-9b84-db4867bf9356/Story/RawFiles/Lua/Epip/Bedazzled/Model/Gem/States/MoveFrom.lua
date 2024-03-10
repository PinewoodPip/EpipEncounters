

local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Features.Bedazzled.Board.Gem.State.MoveFrom : Feature_Bedazzled_Board_Gem_State
---@field OriginalPosition Vector2
---@field TimeElapsed integer
local State = {
    Duration = 0.4,
}
Inherit(State, Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State"))
Bedazzled.RegisterGemStateClass("Features.Bedazzled.Board.Gem.State.MoveFrom", State)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param originalPosition Vector2
function State:Create(originalPosition)
    ---@type Features.Bedazzled.Board.Gem.State.MoveFrom
    local state = {
        OriginalPosition = originalPosition,
        TimeElapsed = 0,
    }
    Inherit(state, self)

    return state
end

---@override
function State:Update(dt)
    self.TimeElapsed = self.TimeElapsed + dt

    -- Transition to idle afterwards
    if self.TimeElapsed >= self.Duration then
        local idleState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Idle")

        self.Gem:SetState(idleState:Create())
    end
end

function State:IsBusy()
    return true
end

---@override
function State:IsBeingInteracted()
    return true
end
