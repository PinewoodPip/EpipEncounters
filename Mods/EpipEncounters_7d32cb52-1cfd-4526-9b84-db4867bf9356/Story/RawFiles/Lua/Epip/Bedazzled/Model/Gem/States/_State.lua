
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Board_Gem_State
---@field Gem Feature_Bedazzled_Board_Gem
---@field ClassName Feature_Bedazzled_Board_Gem_StateClassName
local State = {}
Bedazzled.RegisterGemStateClass("Feature_Bedazzled_Board_Gem_State", State)

---@alias Feature_Bedazzled_Board_Gem_StateClassName "Feature_Bedazzled_Board_Gem_State"|"Feature_Bedazzled_Board_Gem_State_Idle"|"Feature_Bedazzled_Board_Gem_State_Falling"|"Feature_Bedazzled_Board_Gem_State_InvalidSwap"|"Feature_Bedazzled_Board_Gem_State_Swapping"|"Feature_Bedazzled_Board_Gem_State_Consuming"|"Feature_Bedazzled_Board_Gem_State_Fusing"|"Feature_Bedazzled_Board_Gem_State_Transforming"

---------------------------------------------
-- METHODS
---------------------------------------------

---@return Feature_Bedazzled_Board_Gem_State
function State:Create()
    local state = {}
    Inherit(state, self)

    return state
end

---@param gem Feature_Bedazzled_Board_Gem
function State:SetGem(gem)
    self.Gem = gem
end

---@param dt number In seconds.
---@diagnostic disable-next-line: unused-local
function State:Update(dt)
    
end

---Returns whether the gem is in an "idle" state, not performing any specific action.
---@return boolean
function State:IsIdle()
    return false
end

---Returns whether the gem is in a "busy" state.
---Busy gems cannot start falling.
---@return boolean
function State:IsBusy()
    return false
end

---Returns whether this gem can be used in matches.
---@return boolean
function State:IsMatchable()
    return false
end

function State:IsConsumed()
    return false
end