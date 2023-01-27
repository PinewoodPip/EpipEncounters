
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Board_Gem_State_Idle : Feature_Bedazzled_Board_Gem_State
local State = {}
Inherit(State, Bedazzled.GetGemStateClass("Feature_Bedazzled_Board_Gem_State"))
Bedazzled.RegisterGemStateClass("Feature_Bedazzled_Board_Gem_State_Idle", State)

---------------------------------------------
-- METHODS
---------------------------------------------

function State:IsIdle()
    return true
end