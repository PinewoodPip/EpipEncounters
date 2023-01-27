
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Match
---@field Score integer
---@field OriginPosition Vector2
---@field Gems Feature_Bedazzled_Board_Gem[]
local _Match = {}
Bedazzled:RegisterClass("Feature_Bedazzled_Match", _Match)

---@param originPosition Vector2
---@return Feature_Bedazzled_Match
function _Match.Create(originPosition)
    ---@type Feature_Bedazzled_Match
    local match = {
        OriginPosition = originPosition,
        Gems = {},
    }
    Inherit(match, _Match)

    return match
end

---@param gem Feature_Bedazzled_Board_Gem
function _Match:AddGem(gem)
    if not table.contains(self.Gems, gem) then
        table.insert(self.Gems, gem)
    end
end

---@return integer
function _Match:GetGemCount()
    return #self.Gems
end

---Gets the match's point score.
---Match scores have to be set manually by the matching algorithm;
---they are not handled by this class.
---@return integer
function _Match:GetScore()
    return self.Score
end

---Sets the match's points score.
---@param score integer
function _Match:SetScore(score)
    self.Score = score
end