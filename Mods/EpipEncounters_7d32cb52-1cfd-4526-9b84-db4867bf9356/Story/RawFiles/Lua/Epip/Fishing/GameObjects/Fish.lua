
local Fishing = Epip.GetFeature("Feature_Fishing")
local UI = Fishing.UI

---@class Feature_Fishing_GameObject_Fish : Feature_Fishing_GameObject
local _Fish = {
    Type = "Fish",
    Timer = 0,
    CYCLE_TIME = 2,
    FishState = "Floating",
    ACCELERATION = 40,
    MAX_ACCELERATION = 30,
    MAX_VELOCITY = 70,
}
Inherit(_Fish, UI._GameObjectClass)
UI.RegisterGameObject("Feature_Fishing_GameObject_Fish", _Fish)

function _Fish:Update(deltaTime)
    local state = self.State
    local seconds = deltaTime / 1000
    local acceleration = state.Acceleration

    -- Switch states
    self.Timer = self.Timer + seconds
    if self.Timer > self.CYCLE_TIME then
        self.FishState = self.FishState == "Floating" and "Sinking" or "Floating"
        self.Timer = 0
        state.Velocity = 0
        state.Acceleration = 0
    end

    if self.FishState == "Floating" then
        acceleration = acceleration - self.ACCELERATION * seconds
    else
        acceleration = acceleration + self.ACCELERATION * seconds
    end

    -- TODO extract method for this; it's common functionality, most classes will not override it
    state.Acceleration = math.clamp(acceleration, -self.MAX_ACCELERATION, self.MAX_ACCELERATION)
    state.Velocity = state.Velocity + acceleration * seconds
    state.Velocity = math.clamp(state.Velocity, -self.MAX_VELOCITY, self.MAX_VELOCITY)

    state.Position = math.clamp(state.Position + state.Velocity * seconds, 0, UI.GetBobberUpperBound()) -- TODO adjust

    if state.Position <= 0 or state.Position >= UI.GetBobberUpperBound() then -- TODO use gameobject method
        state.Velocity = 0
        state.Acceleration = 0
    end
end