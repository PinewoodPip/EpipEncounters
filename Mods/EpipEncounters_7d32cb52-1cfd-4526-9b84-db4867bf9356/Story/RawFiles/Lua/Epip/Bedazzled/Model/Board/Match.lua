
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Match
---@field Score integer
---@field OriginPosition Vector2
---@field Gems Feature_Bedazzled_Board_Gem[]
---@field Fusions Feature_Bedazzled_Match_Fusion[]
local _Match = {}
Bedazzled:RegisterClass("Feature_Bedazzled_Match", _Match)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Feature_Bedazzled_Match_Fusion
---@field TargetGem Feature_Bedazzled_Board_Gem
---@field TargetModifier string
---@field FusingGems Feature_Bedazzled_Board_Gem[]
local _Fusion = {}
Bedazzled:RegisterClass("Feature_Bedazzled_Match_Fusion", _Fusion)

---@param targetGem Feature_Bedazzled_Board_Gem
---@param targetModifier string
---@param fusingGems Feature_Bedazzled_Board_Gem[]
---@return Feature_Bedazzled_Match_Fusion
function _Fusion.Create(targetGem, targetModifier, fusingGems)
    ---@type Feature_Bedazzled_Match_Fusion
    local fusion = {
        TargetGem = targetGem,
        TargetModifier = targetModifier,
        FusingGems = fusingGems,
    }
    Inherit(fusion, _Fusion)

    return fusion
end

---Returns whether this fusion contains a gem in any way (as target or fusing gem)
---@param gem Feature_Bedazzled_Board_Gem
---@return boolean
function _Fusion:ContainsGem(gem)
    return self.TargetGem == gem or table.contains(self.FusingGems, gem)
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param originPosition Vector2
---@return Feature_Bedazzled_Match
function _Match.Create(originPosition)
    ---@type Feature_Bedazzled_Match
    local match = {
        OriginPosition = originPosition,
        Gems = {},
        Fusions = {},
    }
    Inherit(match, _Match)

    return match
end

---Adds a gem to be consumed.
---@param gem Feature_Bedazzled_Board_Gem
function _Match:AddGem(gem)
    if not self:ContainsGem(gem) then
        table.insert(self.Gems, gem)
    end
end

---Adds a fusion to the match.
---@param fusion Feature_Bedazzled_Match_Fusion
function _Match:AddFusion(fusion)
    table.insert(self.Fusions, fusion)
end

---Returns whether this match already contains the gem in any form (simple consumption or fusion)
---@param gem Feature_Bedazzled_Board_Gem
---@return boolean
function _Match:ContainsGem(gem)
    local containsGem = false

    if table.contains(self.Gems, gem) then
        containsGem = true
    else
        for _,fusion in ipairs(self.Fusions) do
            if fusion:ContainsGem(gem) then
                containsGem = true
                break
            end
        end
    end

    return containsGem
end

---Returns the count of all gems involved in this match, including gems being fused.
---@return integer
function _Match:GetGemCount()
    local count = #self.Gems

    for _,fusion in ipairs(self.Fusions) do
        count = count + 1 + #fusion.FusingGems
    end

    return count
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