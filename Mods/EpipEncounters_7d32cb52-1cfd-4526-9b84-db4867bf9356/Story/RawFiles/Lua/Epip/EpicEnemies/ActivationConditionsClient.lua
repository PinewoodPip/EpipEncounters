
local Conditions = {
    TEMPLATES = {
        TurnStart = "Activates on turn %s%s",
        HealthThreshold = "Activates below %s",
    }
}
Epip.AddFeature("EpicEnemiesEffectConditions", "EpicEnemiesEffectConditions", Conditions)

local EpicEnemies = Epip.Features.EpicEnemies

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

EpicEnemies.Hooks.GetActivationConditionDescription:RegisterHook(function(text, condition, char)
    local type = condition.Type

    if type == "TurnStart" then
        local addendum = ""

        if condition.Repeat then
            addendum = Text.Format(" and every %s turns thereafter", {FormatArgs = condition.RepeatFrequency or 1})
        end

        text = Text.Format(Conditions.TEMPLATES.TurnStart, {FormatArgs = {condition.Round, addendum}})
    elseif type == "HealthThreshold" then
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
    end

    return text
end)