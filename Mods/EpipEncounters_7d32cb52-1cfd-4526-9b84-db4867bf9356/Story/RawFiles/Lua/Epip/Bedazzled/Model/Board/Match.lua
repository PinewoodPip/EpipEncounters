
local Bedazzled = Epip.GetFeature("Feature_Bedazzled")

---@class Feature_Bedazzled_Match
---@field Score integer Defaults to `0`.
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
---@field TargetModifier Feature_Bedazzled_GemModifier_ID?
---@field TargetType Feature_Bedazzled_GemDescriptor_ID?
---@field FusingGems Feature_Bedazzled_Board_Gem[]
local _Fusion = {}
Bedazzled:RegisterClass("Feature_Bedazzled_Match_Fusion", _Fusion)

---@param targetGem Feature_Bedazzled_Board_Gem
---@param targetModifier Feature_Bedazzled_GemModifier_ID?
---@param fusingGems Feature_Bedazzled_Board_Gem[]
---@param targetType Feature_Bedazzled_GemDescriptor_ID?
---@return Feature_Bedazzled_Match_Fusion
function _Fusion.Create(targetGem, targetModifier, fusingGems, targetType)
    -- Target gem cannot be a fusing gem
    local index = table.reverseLookup(fusingGems, targetGem)
    if index then
        table.remove(fusingGems, index)
    end

    ---@type Feature_Bedazzled_Match_Fusion
    local fusion = {
        TargetGem = targetGem,
        TargetModifier = targetModifier,
        TargetType = targetType,
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

---Adds multiple gems to be consumed.
---@param gems Feature_Bedazzled_Board_Gem[]
function _Match:AddGems(gems)
    for _,gem in ipairs(gems) do
        self:AddGem(gem)
    end
end

---Adds a fusion to the match.
---@param fusion Feature_Bedazzled_Match_Fusion
function _Match:AddFusion(fusion)
    local containsGem = false
    if self:ContainsGem(fusion.TargetGem) then
       containsGem = true 
    end
    for _,existingFusion in ipairs(self.Fusions) do
        if existingFusion:ContainsGem(existingFusion.TargetGem) then
            containsGem = true
            break
        end
    end

    -- Cannot add fusion if one or more of its gems are already involved in the match
    if not containsGem then
        table.insert(self.Fusions, fusion)
    end
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

---Returns whether a gem is set to be consumed by this match.
---@param gem Feature_Bedazzled_Board_Gem_State
---@return boolean
function _Match:WillConsumeGem(gem)
    return table.contains(self.Gems, gem)
end

---Returns a list of all gems involved in the match.
---@return Feature_Bedazzled_Board_Gem[]
function _Match:GetAllGems()
    local gems = {}

    for _,gem in ipairs(self.Gems) do
        table.insert(gems, gem)
    end

    for _,fusion in ipairs(self.Fusions) do
        table.insert(gems, fusion.TargetGem)

        for _,gem in ipairs(fusion.FusingGems) do
            table.insert(gems, gem)
        end
    end

    return gems
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
    return self.Score or 0
end

---Sets the match's points score.
---@param score integer
function _Match:SetScore(score)
    self.Score = score
end