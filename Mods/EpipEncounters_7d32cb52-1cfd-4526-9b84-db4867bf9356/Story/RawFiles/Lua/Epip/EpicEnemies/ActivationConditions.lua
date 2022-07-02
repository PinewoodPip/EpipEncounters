
---------------------------------------------
-- Pre-made activation conditions for Epic Enemies effects.
---------------------------------------------

local Conditions = {

}
Epip.AddFeature("EpicEnemiesEffectConditions", "EpicEnemiesEffectConditions", Conditions)

local EpicEnemies = Epip.Features.EpicEnemies

---------------------------------------------
-- CONDITIONS
---------------------------------------------

Osiris.RegisterSymbolListener("PROC_AMER_Combat_TurnStarted", 2, "after", function(char, hasActed)
    if Osi.IsTagged(char, EpicEnemies.INITIALIZED_TAG) then
        local _, round = Osiris.DB_PIP_CharacterCombatRound:Get(char, nil)
        if round == nil then round = 1 end
        char = Ext.GetCharacter(char)

        EpicEnemies.ActivateEffects(char, "TurnStart", {Round = round})
    end
end)

EpicEnemies.Hooks.CanActivateEffect:RegisterHook(function(activate, char, effect, activationCondition, params)
    local condition = activationCondition.Type

    if condition == "TurnStart" then
        return params.Round == activationCondition.Round or (params.Round >= activationCondition.Round and activationCondition.Repeat)
    end

    return activate
end)