
---------------------------------------------
-- Represents a request to roll effects for a character.
-- Server-only.
---------------------------------------------

---@class Feature_EpicEnemies
local EpicEnemies = Epip.GetFeature("Feature_EpicEnemies")

---@class Features.EpicEnemies.InitRequest : Class
---@field Character EsvCharacter
---@field Budget number Reamining points.
---@field Effects set<string>
local InitRequest = {}
EpicEnemies:RegisterClass("Features.EpicEnemies.InitRequest", InitRequest)

---------------------------------------------
-- METHODS
---------------------------------------------

---Creates an initialization request.
---@param data Features.EpicEnemies.InitRequest
---@return Features.EpicEnemies.InitRequest
function InitRequest.Create(data)
    data.Effects = data.Effects or {}
    return InitRequest:__Create(data) ---@type Features.EpicEnemies.InitRequest
end

---Adds an effect, consuming points from the budget.
---Will also add prerequisites.
---**Will throw if the effect is not affordable or already added.**
---Does nothing if the effect(s) are already within the request.
---@param effect Features.EpicEnemies.Effect
function InitRequest:AddEffect(effect)
    if self:HasEffect(effect) then return self:__Error("AddEffect", "Effect already added", effect.ID) end
    local cost = EpicEnemies.GetEffectCost(effect, self)
    if cost > self.Budget then
        self:__Error("AddEffect", "Cannot afford effect", effect.ID, ". Budget", self.Budget)
    end
    self:_TryAddEffect(effect)
    for prereq,_ in pairs(effect.Prerequisites or {}) do
        self:_TryAddEffect(EpicEnemies.GetEffectData(prereq))
    end
    self.Budget = self.Budget - cost
end

---Returns whether the request has an effect.
---@param effect Features.EpicEnemies.Effect|string
---@return boolean
function InitRequest:HasEffect(effect)
    local effectID = type(effect) == "table" and effect.ID or effect -- String overload.
    return self.Effects[effectID]
end

---Utility method for `AddEffect()`.
---@param effect Features.EpicEnemies.Effect
function InitRequest:_TryAddEffect(effect)
    if not self.Effects[effect.ID] then
        self.Effects[effect.ID] = true
    end
end
