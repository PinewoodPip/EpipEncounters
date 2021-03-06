
---@meta Library: EpicEnemies, ContextShared, Epip.Features.EpicEnemies, EpicEnemies

local EpicEnemies = {
    ---@type table<string, EpicEnemiesEffect>
    EFFECTS = {},
    ---@type EpicEnemiesEffectsCategory[]
    CATEGORIES = {},
    INITIALIZED_TAG = "PIP_EpicEnemy",
    INELIGIBLE_TAG = "PIP_EpicEnemies_Ineligible",
    EFFECT_TAG_PREFIX = "PIP_EpicEnemies_Effect_",
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

Epip.AddFeature("EpicEnemies", "EpicEnemies", EpicEnemies)
Epip.Features.EpicEnemies = EpicEnemies

---@class EpicEnemiesActivationCondition
---@field Type string
---@field MaxActivations integer

local _EpicEnemiesActivationCondition = {
    Type = "EffectApplied",
    MaxActivations = 1,
}

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
---@field Visible boolean? Whether this effect appears in tooltips. Defaults to true.

---@class EpicEnemiesKeywordData
---@field Keyword Keyword
---@field BoonType KeywordBoonType

---@class EpicEnemiesEffectsCategory
---@field Name string
---@field ID string
---@field Effects string[]|EpicEnemiesEffect[] Can be an array of EpicEnemiesEffect while calling the register method. Will be turned into an ID array afterwards.

---@type EpicEnemiesEffect
_EpicEnemiesEffect = {
    Description = "NO DESCRIPTION",
    Name = "NO NAME",
    DefaultCost = 10,
    DefaultWeight = 10,
}

---Get the cost of an effect.
function _EpicEnemiesEffect:GetCost()
    local cost = self.DefaultCost or self.Cost

    -- if Ext.IsClient() then
    --     cost = Client.UI.OptionsSettings.GetOptionValue("EpicEnemies", self.ID)
    --     print("client: " .. cost)
    -- else
    --     cost = Epip.Features.ServerSettings.GetValue("EpicEnemies", self.ID)
    --     print("server: " .. cost)
    -- end

    return cost
end

function _EpicEnemiesEffect:GetWeight()
    local weight = self.DefaultWeight or self.Weight

    if Ext.IsClient() then
        weight = Client.UI.OptionsSettings.GetOptionValue("EpicEnemies", self.ID)

        if self.Category then
            weight = weight * Client.UI.OptionsSettings.GetOptionValue("EpicEnemies", "EpicEnemies_CategoryWeight_" .. self.Category)
        end
    else
        weight = Epip.Features.ServerSettings.GetValue("EpicEnemies", self.ID) or 0

        -- Multiply by category multiplier
        if self.Category then
            weight = weight * (Epip.Features.ServerSettings.GetValue("EpicEnemies", "EpicEnemies_CategoryWeight_" .. self.Category) or 1)
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

    -- Register slider
    if Ext.IsClient() then
        local setting = {
            ID = settingID,
            Type = "Slider",
            Label = "Category Weight Multiplier",
            SaveOnServer = true,
            ServerOnly = true,
            MinAmount = 0,
            MaxAmount = 5,
            Interval = 0.01,
            DefaultValue = 1,
            HideNumbers = false,
            VisibleAtTopLevel = false,
            Tooltip = Text.Format("A multiplier for the weights of the effects of this category (%s).", {FormatArgs = {category.Name}}),
        }

        Client.UI.OptionsSettings.RegisterOption("EpicEnemies", setting)
    else -- Register server setting
        local setting = {
            ID = settingID,
            Type = "Slider",
            Label = "Category Weight Multiplier",
            SaveOnServer = true,
            ServerOnly = true,
            MinAmount = 0,
            MaxAmount = 5,
            Interval = 0.01,
            DefaultValue = 1,
            HideNumbers = false,
            Tooltip = "A multiplier for the weights of the effects of this category.",
        }
        
        Epip.Features.ServerSettings.AddOption("EpicEnemies", setting)
    end

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

    -- Register customizable option
    local option = EpicEnemies.GenerateOptionData(effect)
    if Ext.IsClient() then
        Client.UI.OptionsSettings.RegisterOption("EpicEnemies", option)
    else
        Epip.Features.ServerSettings.AddOption("EpicEnemies", option)
    end
end

---@param effect EpicEnemiesEffect
function EpicEnemies.GenerateOptionData(effect)
    ---@type OptionsSettingsOption
    local option = {
        ID = effect.ID,
        Type = "Slider",
        ServerOnly = true,
        SaveOnServer = true,
        Interval = 1,
        MinAmount = 0,
        MaxAmount = 100,
        VisibleAtTopLevel = false,
        HideNumbers = false,
        DefaultValue = effect.DefaultWeight,
        Label = effect.Name,
        Tooltip = Text.Format("%s<br><br>Costs %s points.", {FormatArgs = {
            effect.Description,
            effect:GetCost(),
        }}),
    }

    return option
end