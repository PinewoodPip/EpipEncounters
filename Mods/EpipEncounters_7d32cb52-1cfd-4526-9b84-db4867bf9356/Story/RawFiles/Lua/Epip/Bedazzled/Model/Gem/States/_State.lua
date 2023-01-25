
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Board_Gem_State
---@field Gem Feature_Bedazzled_Board_Gem
---@field ClassName Feature_Bedazzled_Board_Gem_StateClassName
local State = {}
Bedazzled.RegisterGemStateClass("Feature_Bedazzled_Board_Gem_State", State)

---@alias Feature_Bedazzled_Board_Gem_StateClassName "Feature_Bedazzled_Board_Gem_State"|"Feature_Bedazzled_Board_Gem_State_Idle"|"Feature_Bedazzled_Board_Gem_State_Falling"|"Feature_Bedazzled_Board_Gem_State_InvalidSwap"|"Feature_Bedazzled_Board_Gem_State_Swapping"|"Feature_Bedazzled_Board_Gem_State_Consuming"

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