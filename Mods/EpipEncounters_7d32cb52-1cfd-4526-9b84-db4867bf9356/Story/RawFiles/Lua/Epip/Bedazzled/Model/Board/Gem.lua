
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Board_Gem
---@field Type string
---@field X number
---@field Y number
---@field State Feature_Bedazzled_Board_Gem_State
local _BoardGem = {
    Events = {
        StateChanged = {}, ---@type Event<Feature_Bedazzled_Board_Gem_Event_StateChanged>
    },
}
Bedazzled:RegisterClass("Feature_Bedazzled_Board_Gem", _BoardGem)

---@class Feature_Bedazzled_Board_Gem_Event_StateChanged
---@field NewState Feature_Bedazzled_Board_Gem_StateClassName
---@field OldState Feature_Bedazzled_Board_Gem_State

---@param type string
---@param state Feature_Bedazzled_Board_Gem_State
---@return Feature_Bedazzled_Board_Gem
function _BoardGem:Create(type, state)
    ---@type Feature_Bedazzled_Board_Gem
    local obj = {
        Type = type,
        Y = 0,
        X = 0,
        Events = {},
    }
    Inherit(obj, self)

    for k,_ in pairs(_BoardGem.Events) do
        obj.Events[k] = SubscribableEvent:New(k)
    end

    -- Set initial state
    obj:SetState(state)

    return obj
end

---Delagated to state.
---@param dt number In seconds.
function _BoardGem:Update(dt)
    self.State:Update(dt)
end

function _BoardGem:GetIcon()
    return self:GetDescriptor():GetIcon()
end

---@param state Feature_Bedazzled_Board_Gem_State
function _BoardGem:SetState(state)
    local oldState = self.State
    state:SetGem(self)

    self.State = state

    self.Events.StateChanged:Throw({
        NewState = state.ClassName,
        OldState = oldState,
    })
end

---@return number
function _BoardGem:GetSize()
    return Bedazzled.GEM_SIZE
end

---@return boolean
function _BoardGem:IsFalling()
    return self.State.ClassName == "Feature_Bedazzled_Board_Gem_State_Falling"
end

function _BoardGem:IsConsumed() -- TODO delegate these methods to state interface
    local state = self.State ---@type Feature_Bedazzled_Board_Gem_State_Consuming

    return self.State.ClassName == "Feature_Bedazzled_Board_Gem_State_Consuming" and state:IsConsumed()
end

---Returns whether the gem is in an "idle" state, not performing any specific action.
---@return boolean
function _BoardGem:IsIdle()
    return self.State:IsIdle()
end

---Busy gems cannot start falling.
---@return boolean
function _BoardGem:IsBusy()
    return self.State:IsBusy()
end

---@param y number
function _BoardGem:SetPosition(y)
    self.Y = y
end

---@return number
function _BoardGem:GetPosition()
    return self.Y
end

---@return integer, integer
function _BoardGem:GetBoardPosition()
    return self.X, self.Y
end

---@return Feature_Bedazzled_Gem
function _BoardGem:GetDescriptor()
    return Bedazzled.GetGemDescriptor(self.Type)
end

---@return boolean
function _BoardGem:IsMatchable()
    return self.State:IsMatchable()
end

---@param otherGem Feature_Bedazzled_Board_Gem
---@return boolean
function _BoardGem:IsAdjacentTo(otherGem)
    local x, y = otherGem:GetBoardPosition()
    local distanceX, distanceY = math.abs(self.X - x), math.abs(self.Y - y)

    return (distanceX == 1 or distanceY == 1) and not (distanceX >= 1 and distanceY >= 1)
end