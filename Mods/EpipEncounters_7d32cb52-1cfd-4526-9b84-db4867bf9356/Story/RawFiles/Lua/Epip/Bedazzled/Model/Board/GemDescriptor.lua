
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Gem
---@field Type string
---@field Icon string
---@field Weight integer Defaults to 1.
local _Gem = {}
Bedazzled:RegisterClass("Feature_Bedazzled_Gem", _Gem)

---Creates a gem descriptor.
---@param data Feature_Bedazzled_Gem
---@return Feature_Bedazzled_Gem
function _Gem.Create(data)
    data.Weight = data.Weight or 1
    Inherit(data, _Gem)

    return data
end

---@return string
function _Gem:GetIcon()
    return self.Icon
end