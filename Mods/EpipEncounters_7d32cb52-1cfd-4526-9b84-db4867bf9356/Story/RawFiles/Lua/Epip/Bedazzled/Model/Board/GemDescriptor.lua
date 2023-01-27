
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Gem
---@field Type string
---@field Icon string
local _Gem = {}
Bedazzled:RegisterClass("Feature_Bedazzled_Gem", _Gem)

---@return string
function _Gem:GetIcon()
    return self.Icon
end