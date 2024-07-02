
local Conditions = {
    TEMPLATES = {
        TurnStart = "Activates on turn %s%s",
        HealthThreshold = "Activates below %s",
        BatteredHarried = "Activates upon reaching %s %s Stacks",
        StatusGained = "Activates upon gaining the %s status.",
    }
}
Epip.RegisterFeature("EpicEnemiesEffectConditions", Conditions)

local EpicEnemies = Epip.Features.EpicEnemies

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Supply descriptions for default conditions.
EpicEnemies.Hooks.GetActivationConditionDescription:Subscribe(function(ev)
    local condition = ev.Condition
    local type = condition.Type
    local text = ev.Description

    if type == "TurnStart" then
        ---@cast condition EpicEnemiesCondition_TurnStart
        local addendum = ""

        if condition.Repeat then
            addendum = Text.Format(" and every %s turns thereafter", {FormatArgs = {condition.RepeatFrequency or 1}})
        end

        text = Text.Format(Conditions.TEMPLATES.TurnStart, {FormatArgs = {condition.Round, addendum}})
    elseif type == "HealthThreshold" then
        ---@cast condition EpicEnemiesCondition_HealthThreshold
        local str = ""

        if condition.Vitality then
            local vitalityStr = Text.Format("%s%% Vitality", {FormatArgs = {condition.Vitality * 100}})

            str = str .. vitalityStr
        end

        if condition.PhysicalArmor then
            local physArmorStr = Text.Format("%s%% Physical Armor", {FormatArgs = {condition.PhysicalArmor * 100}})

            if condition.RequireAll and condition.Vitality then
                str = str .. " and " .. physArmorStr
            elseif condition.Vitality then
                str = str .. " or " .. physArmorStr
            else
                str = str .. physArmorStr
            end
        end

        if condition.MagicArmor then
            local magicArmorStr = Text.Format("%s%% Physical Armor", {FormatArgs = {condition.MagicArmor * 100}})

            if condition.RequireAll and (condition.PhysicalArmor or condition.Vitality) then
                str = str .. " and " .. magicArmorStr
            elseif condition.PhysicalArmor or condition.Vitality then
                str = str .. " or " .. magicArmorStr
            else
                str = str .. magicArmorStr
            end
        end

        text = Text.Format(Conditions.TEMPLATES.HealthThreshold, {
            FormatArgs = {
                str,
            }
        })
    elseif type == "BatteredHarried" then
        ---@cast condition EpicEnemiesCondition_BatteredHarried
        local stackNames = {
            B = "Battered",
            H = "Harried",
        }
        local stackType = stackNames[condition.StackType] or condition.StackType

        text = Text.Format(Conditions.TEMPLATES.BatteredHarried, {
            FormatArgs = {
                condition.Amount,
                stackType,
            }
        })
    elseif type == "StatusGained" then
        ---@cast condition EpicEnemiesCondition_StatusGained
        local statusName = condition.StatusID
        local stat = Ext.Stats.Get(statusName)

        if stat then
            statusName = Ext.L10N.GetTranslatedStringFromKey(stat.DisplayName)
        end

        text = Text.Format(Conditions.TEMPLATES.StatusGained, {
            FormatArgs = {statusName},
        })
    end

    ev.Description = text
end, {StringID = "DefaultImplementation"})
