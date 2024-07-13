
---@class Feature_EpicEnemies : Feature
local EpicEnemies = {
    ---@type Features.EpicEnemies.EffectCategory[]
    CATEGORIES = {},
    INITIALIZED_TAG = "PIP_EpicEnemy",
    INELIGIBLE_TAG = "PIP_EpicEnemies_Ineligible",
    EFFECT_TAG_PREFIX = "PIP_EpicEnemies_Effect_",
    SETTINGS_MODULE_ID = "EpicEnemies",
    DEFAULT_EFFECT_PRIORITY = 1,

    ---@type table<string, Features.EpicEnemies.Effect>
    _RegisteredEffects = {},

    ---@type SettingsLib_Setting[]
    _SHARED_SETTINGS = {
        {
            ID = "EpicEnemies_Toggle",
            Type = "Boolean",
            Name = "Enabled",
            Description = "Enables the Epic Enemies feature.",
            ServerOnly = true,
            SaveOnServer = true,
            DefaultValue = false,
        },
        {
            ID = "EpicEnemies_PointsBudget",
            Type = "ClampedNumber",
            Name = "Points Budget",
            Description = "Controls how many effects enemies affected by Epic Enemies can receive. Effects cost a variable amount of points based on how powerful they are.",
            SaveOnServer = true,
            ServerOnly = true,
            Min = 1,
            Max = 100,
            Step = 1,
            DefaultValue = 30,
            HideNumbers = false,
        },
        {
            ID = "EpicEnemies_PointsMultiplier_Bosses",
            Type = "ClampedNumber",
            Name = "Boss Enemy Points Multiplier",
            Description = "A multiplier for the amount of points boss enemies receive.",
            SaveOnServer = true,
            ServerOnly = true,
            Min = 0,
            Max = 5,
            Step = 0.01,
            DefaultValue = 1,
            HideNumbers = false,
        },
        {
            ID = "EpicEnemies_PointsMultiplier_Normies",
            Type = "ClampedNumber",
            Name = "Normal Enemy Points Multiplier",
            Description = "A multiplier for the amount of points normal enemies receive.",
            SaveOnServer = true,
            ServerOnly = true,
            Min = 0,
            Max = 5,
            Step = 0.01,
            DefaultValue = 0,
            HideNumbers = false,
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Events = {
        EffectApplied = {Context = "Server"}, ---@type Event<Features.EpicEnemies.Events.EffectApplied>
        EffectRemoved = {Context = "Server"}, ---@type Event<Features.EpicEnemies.Events.EffectRemoved>
        EffectActivated = {Context = "Server"}, ---@type Event<Features.EpicEnemies.Events.EffectActivated>
        EffectDeactivated = {Context = "Server"}, ---@type Event<Features.EpicEnemies.Events.EffectDeactivated>
        CharacterInitialized = {Context = "Server"}, ---@type Event<Features.EpicEnemies.Events.CharacterInitialized>
        CharacterCleanedUp = {Context = "Server"}, ---@type Event<Features.EpicEnemies.Events.CharacterCleanedUp>
    },
    Hooks = {
        IsCharacterEligible = {Context = "Server"}, ---@type Hook<Features.EpicEnemies.Hooks.IsCharacterEligible>
        IsEffectApplicable = {Context = "Server"}, ---@type Hook<Features.EpicEnemies.Hooks.IsEffectApplicable>
        CanActivateEffect = {Context = "Server"}, ---@type Hook<Features.EpicEnemies.Hooks.CanActivateEffect>
        GetPointsForCharacter = {Context = "Server"}, ---@type Hook<Features.EpicEnemies.Hooks.GetPointsForCharacter>
        GetActivationConditionDescription = {Context = "Client"} ---@type Hook<Features.EpicEnemies.Hooks.GetActivationConditionDescription>
    },
}

Epip.RegisterFeature("EpicEnemies", EpicEnemies)
Epip.Features.EpicEnemies = EpicEnemies
EpicEnemies:__RegisterDeprecatedKeyRedirect("EFFECTS", {
    WarningMessage = "Use GetRegisteredEffects() instead.",
    Value = function (_)
        return EpicEnemies.GetRegisteredEffects()
    end
})

---@class EpicEnemiesActivationCondition
---@field Type string
---@field MaxActivations integer

local _EpicEnemiesActivationCondition = {
    Type = "EffectApplied",
    MaxActivations = 1,
}

---@class EpicEnemiesKeywordData
---@field Keyword Keyword
---@field BoonType KeywordBoonType

---@class Features.EpicEnemies.EffectCategory
---@field Name string
---@field ID string
---@field Effects string[]|Features.EpicEnemies.Effect[] Can be an array of effects while calling the register method. Will be turned into an ID array afterwards.

---@class Features.EpicEnemies.Effect
---@field ID string
---@field Name TextLib.String
---@field Description TextLib.String
---@field Cost integer
---@field Weight integer
---@field DefaultWeight integer
---@field DefaultCost integer
---@field ActivationCondition EpicEnemiesActivationCondition
---@field Category string?
---@field Visible boolean? Whether this effect appears in tooltips. Defaults to `true`.
---@field Priority number? Effects with higher priority will attempt to roll first. Defaults to `1`.
---@field Prerequisites table<string, true>? List of effect IDs to apply beforehand, consuming budget accordingly if not yet applied.
---@field DiscountPrerequisites boolean? If `true`, the cost of the effect will be the sum of the base cost and every prerequisite that hasn't been obtained yet. Otherwise, the cost will be the sum of the base cost and base costs of all prerequisites, regardless of whether the character already has them. Defaults to `true`.
---@field AllowedAIArchetypes table<aitype, true>? If set, only characters with the specified AI archetypes will be able to roll the effect.
_EpicEnemiesEffect = {
    Description = "NO DESCRIPTION",
    Name = "NO NAME",
    DefaultCost = 10,
    DefaultWeight = 10,
}

---Returns the base cost of an effect without considering prerequisites.
---@return number
function _EpicEnemiesEffect:GetCost()
    return self.DefaultCost or self.Cost
end

function _EpicEnemiesEffect:GetWeight()
    local weight = self.DefaultWeight or self.Weight

    if Ext.IsClient() then
        weight = Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, self.ID)

        if self.Category then
            weight = weight * Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_CategoryWeight_" .. self.Category)
        end
    else
        weight = Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, self.ID) or 0

        -- Multiply by category multiplier
        if self.Category then
            weight = weight * (Settings.GetSettingValue(EpicEnemies.SETTINGS_MODULE_ID, "EpicEnemies_CategoryWeight_" .. self.Category) or 1)
        end
    end

    return weight
end

---------------------------------------------
-- METHODS
---------------------------------------------

---@param char Character|GUID
function EpicEnemies.IsInitialized(char)
    if type(char) ~= "userdata" then char = Ext.GetCharacter(char) end
    return char:HasTag(EpicEnemies.INITIALIZED_TAG)
end

---@param id string
---@return Features.EpicEnemies.Effect
function EpicEnemies.GetEffectData(id)
    return EpicEnemies._RegisteredEffects[id]
end

---@param category Features.EpicEnemies.EffectCategory
function EpicEnemies.RegisterEffectCategory(category)
    local settingID = "EpicEnemies_CategoryWeight_" .. category.ID

    table.insert(EpicEnemies.CATEGORIES, category)

    -- Register setting
    ---@type SettingsLib_Setting_ClampedNumber
    local setting = {
        ID = settingID,
        ModTable = EpicEnemies.SETTINGS_MODULE_ID,
        Type = "ClampedNumber",
        Context = "Server",
        Name = "Category Weight Multiplier",
        Description = Text.Format("A multiplier for the weights of the effects of this category (%s).", {FormatArgs = {category.Name}}),
        SaveOnServer = true,
        ServerOnly = true,
        Min = 0,
        Max = 5,
        Step = 0.01,
        DefaultValue = 1,
        HideNumbers = false,
        VisibleAtTopLevel = false,
    }

    Settings.RegisterSetting(setting)

    for i,effect in ipairs(category.Effects) do
        if type(effect) == "table" then
            EpicEnemies.RegisterEffect(effect.ID, effect)
            effect.Category = category.ID
            category.Effects[i] = effect.ID
        end
    end
end

---@param id string
---@param effect Features.EpicEnemies.Effect
function EpicEnemies.RegisterEffect(id, effect)
    -- Shorthand initializers for default values
    if effect.Cost then effect.DefaultCost = effect.Cost end
    if effect.Weight then effect.DefaultWeight = effect.Weight end

    effect.Cost = nil -- TODO remove - wtf?
    effect.Weight = nil
    effect.ID = id

    if effect.Visible == nil then effect.Visible = true end

    if not effect.ActivationCondition then effect.ActivationCondition = {} end
    Inherit(effect.ActivationCondition, _EpicEnemiesActivationCondition)

    if not effect.DefaultCost then effect.DefaultCost = 10 end
    if not effect.DefaultWeight then effect.DefaultWeight = 10 end
    if effect.DiscountPrerequisites == nil then effect.DiscountPrerequisites = true end

    -- Ensure prerequisites are registered and have no redundancies
    for prereqID in pairs(effect.Prerequisites or {}) do
        local prereqEffect = EpicEnemies.GetEffectData(prereqID)
        if not prereqEffect then
            EpicEnemies:__Error("RegisterEffect", "Prerequisite", prereqID, "for", id, "is not registered")
        elseif next(prereqEffect.Prerequisites or {}) then
            EpicEnemies:__Error("RegisterEffect", "Nesting prerequisites is not supported; an effect cannot have prerequisite effects that have prerequisites themselves. Effect", id)
        end
    end

    setmetatable(effect, {__index = _EpicEnemiesEffect})

    EpicEnemies._RegisteredEffects[id] = effect

    -- Register customizable setting
    local setting = EpicEnemies.GenerateOptionData(effect)
    Settings.RegisterSetting(setting)
end

---Returns all registered effects.
---@return table<string, Features.EpicEnemies.Effect>
function EpicEnemies.GetRegisteredEffects()
    return EpicEnemies._RegisteredEffects
end

---@param effect Features.EpicEnemies.Effect
function EpicEnemies.GenerateOptionData(effect)
    ---@type SettingsLib_Setting_ClampedNumber
    local option = {
        ID = effect.ID,
        Type = "ClampedNumber",
        ModTable = EpicEnemies.SETTINGS_MODULE_ID,
        Context = "Server",
        Name = effect.Name,
        Description = Text.Format("%s<br><br>Costs %s points.", {FormatArgs = {
            effect.Description,
            effect:GetCost(),
        }}),
        ServerOnly = true,
        SaveOnServer = true,
        Step = 1,
        Min = 0,
        Max = 100,
        VisibleAtTopLevel = false,
        HideNumbers = false,
        DefaultValue = effect.DefaultWeight,
    }

    return option
end

---------------------------------------------
-- SETUP
---------------------------------------------

-- Register shared settings
for _,setting in ipairs(EpicEnemies._SHARED_SETTINGS) do
    setting.ModTable = EpicEnemies.SETTINGS_MODULE_ID
    setting.Context = "Server"

    Settings.RegisterSetting(setting)
end