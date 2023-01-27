
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Board_Gem_State_Falling : Feature_Bedazzled_Board_Gem_State
---@field Acceleration number
---@field Velocity number
---@field TargetPosition number
local State = {}
Inherit(State, Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State"))
Bedazzled.RegisterGemStateClass("Feature_Bedazzled_Board_Gem_State_Falling", State)

---------------------------------------------
-- METHODS
---------------------------------------------

function State:Create()
    ---@type Feature_Bedazzled_Board_Gem_State_Falling
    local state = {
        Acceleration = 0,
        Velocity = 0,
        TargetPosition = 0,
    }
    Inherit(state, self)

    return state
end

function State:Update(dt)
    local gem = self.Gem
    local intendedPosition = self.TargetPosition
    local currentPos = gem:GetPosition()
    local acceleration, velocity = self.Acceleration, self.Velocity

    if currentPos > intendedPosition then
        acceleration = acceleration - Bedazzled.GRAVITY * dt
        velocity = velocity + acceleration * dt
    else
        acceleration, velocity = 0, 0
    end

    -- Transition to idle state
    if currentPos < intendedPosition then
        currentPos = intendedPosition

        local idleState = Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State_Idle"):Create()
        self.Gem:SetState(idleState)
    end

    gem:SetPosition(currentPos + velocity * dt)

    self.Acceleration = acceleration
    self.Velocity = velocity
end

-- Falling gems can be matched - but the game will not do so until they stop falling. This is so they are considered as valid gems for match-finding algorithms, allowing matches to stall until the gems stop falling.
function State:IsMatchable()
    return true
end

function State:IsBusy()
    return true
end