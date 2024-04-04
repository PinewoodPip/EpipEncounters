
---@class Feature_EpicEnemies : Feature
local EpicEnemies = {
    ---@type table<string, EpicEnemiesEffect>
    EFFECTS = {},
    ---@type EpicEnemiesEffectsCategory[]
    CATEGORIES = {},
    INITIALIZED_TAG = "PIP_EpicEnemy",
    INELIGIBLE_TAG = "PIP_EpicEnemies_Ineligible",
    EFFECT_TAG_PREFIX = "PIP_EpicEnemies_Effect_",
    SETTINGS_MODULE_ID = "EpicEnemies",
    DEFAULT_EFFECT_PRIORITY = 1,

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

    Events = {
        
    },
    Hooks = {},
}

if Ext.IsServer() then
    ---@type EpicEnemies_Event_EffectApplied
    EpicEnemies.Events.EffectApplied = {}
    ---@type EpicEnemies_Hook_IsEligible
    EpicEnemies.Hooks.IsEligible = {}
    ---@type EpicEnemies_Event_EffectRemoved
    EpicEnemies.Events.EffectRemoved = {}
    ---@type EpicEnemies_Hook_IsEffectApplicable
    EpicEnemies.Hooks.IsEffectApplicable = {}
    ---@type EpicEnemies_Event_EffectActivated
    EpicEnemies.Events.EffectActivated = {}
    ---@type EpicEnemies_Event_EffectDeactivated
    EpicEnemies.Events.EffectDeactivated = {}
    ---@type EpicEnemies_Hook_CanActivateEffect
    EpicEnemies.Hooks.CanActivateEffect = {}
end

Epip.RegisterFeature("EpicEnemies", EpicEnemies)
Epip.Features.EpicEnemies = EpicEnemies

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

---@class EpicEnemiesEffectsCategory
---@field Name string
---@field ID string
---@field Effects string[]|EpicEnemiesEffect[] Can be an array of EpicEnemiesEffect while calling the register method. Will be turned into an ID array afterwards.

---Legacy class name; use `Features.EpicEnemies.Effect` instead.
---@class EpicEnemiesEffect
---@field ID string
---@field Name string
---@field Description string
---@field Cost integer
---@field Weight integer
---@field DefaultWeight integer
---@field DefaultCost integer
---@field ActivationCondition EpicEnemiesActivationCondition
---@field Category string?
---@field Visible boolean? Whether this effect appears in tooltips. Defaults to `true`.
---@field Priority number? Effects with higher priority will attempt to roll first. Defaults to `1`.
---@field Prerequisites table<string, true>? List of effect IDs to apply beforehand, consuming budget accordingly if not yet applied.
_EpicEnemiesEffect = {
    Description = "NO DESCRIPTION",
    Name = "NO NAME",
    DefaultCost = 10,
    DefaultWeight = 10,
}
---@class Features.EpicEnemies.Effect : EpicEnemiesEffect

---Get the cost of an effect.
function _EpicEnemiesEffect:GetCost()
    local cost = self.DefaultCost or self.Cost

    return cost
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
---@return EpicEnemiesEffect
function EpicEnemies.GetEffectData(id)
    return EpicEnemies.EFFECTS[id]
end

---@param category EpicEnemiesEffectsCategory
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
---@param effect EpicEnemiesEffect
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

    setmetatable(effect, {__index = _EpicEnemiesEffect})

    EpicEnemies.EFFECTS[id] = effect

    -- Register customizable setting
    local setting = EpicEnemies.GenerateOptionData(effect)
    Settings.RegisterSetting(setting)
end

---@param effect EpicEnemiesEffect
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