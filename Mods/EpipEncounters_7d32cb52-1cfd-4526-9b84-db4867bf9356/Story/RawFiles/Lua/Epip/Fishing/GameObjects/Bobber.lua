
local Fishing = Epip.GetFeature("Feature_Fishing")
local UI = Fishing.UI

---@class Feature_Fishing_GameObject_Bobber : Feature_Fishing_GameObject
local _Bobber = {
    Type = "Bobber",
}
Inherit(_Bobber, UI._GameObjectClass)
UI.RegisterGameObject("Feature_Fishing_GameObject_Bobber", _Bobber)

---@param deltaTime number In milliseconds.
function _Bobber:Update(deltaTime)
    local state = self.State
    local seconds = deltaTime / 1000
    local acceleration = state.Acceleration
    local applyGravity = not Client.Input.IsKeyPressed("left2") -- TODO turn into a hook

    if applyGravity then
        acceleration = acceleration - UI.GRAVITY * seconds
    else
        acceleration = acceleration + UI.PLAYER_STRENGTH * seconds
    end

    state.Acceleration = math.clamp(acceleration, -UI.MAX_ACCELERATION, UI.MAX_ACCELERATION)
    state.Velocity = state.Velocity + acceleration * seconds
    state.Velocity = math.clamp(state.Velocity, -UI.MAX_VELOCITY, UI.MAX_VELOCITY)

    state.Position = math.clamp(state.Position + state.Velocity * seconds, 0, UI.GetBobberUpperBound())

    if state.Position <= 0 or state.Position >= UI.GetBobberUpperBound() then -- TODO use gameobject method
        state.Velocity = 0
        state.Acceleration = 0
    end
end

---@param otherObject Feature_Fishing_GameObject
---@param deltaTime number In milliseconds.
function _Bobber:OnCollideWith(otherObject, deltaTime)
    if otherObject.Type == "Fish" then
        -- Add progress. The drain must be offset.
        local drain = UI.GetProgressDrain()

        UI.AddProgress((drain + UI.PROGRESS_PER_SECOND) * deltaTime / 1000)
    end
end