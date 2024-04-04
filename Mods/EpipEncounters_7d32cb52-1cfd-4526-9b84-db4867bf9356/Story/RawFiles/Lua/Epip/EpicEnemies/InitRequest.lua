
---------------------------------------------
-- Represents a request to roll effects for a character.
-- Server-only.
---------------------------------------------

---@class Feature_EpicEnemies
local EpicEnemies = Epip.GetFeature("Feature_EpicEnemies")

---@class Features.EpicEnemies.InitRequest : Class
---@field Character EsvCharacter
---@field Budget number Reamining points.
---@field Effects table<string, true>
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
---**Will throw if the effect is not afforadable.**
---Does nothing if the effect(s) are already within the request.
---@param effect Features.EpicEnemies.Effect
function InitRequest:AddEffect(effect)
    self:_TryAddEffect(effect)
    for prereq,_ in pairs(effect.Prerequisites or {}) do
        self:_TryAddEffect(EpicEnemies.GetEffectData(prereq))
    end
end

---Utility method for `AddEffect()`.
---@param effect Features.EpicEnemies.Effect
function InitRequest:_TryAddEffect(effect)
    if not self.Effects[effect.ID] then
        local cost = effect:GetCost()
        if cost > self.Budget then
            self:__Error("AddEffect", "Cannot afford effect")
        end
        self.Effects[effect.ID] = true
        self.Budget = self.Budget - cost
    end
end
