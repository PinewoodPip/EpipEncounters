
---------------------------------------------
-- Displays Damage parameters within skill tooltips as their multipliers while shift is held.
-- TODO also apply to other tooltip types?
---------------------------------------------

---@type Feature
local SkillDamageMultipliers = {
    TranslatedStrings = {
        Label_WeaponBased = {
            Handle = "hf2848d52g9abbg4567g89e7gec23e4573bf2",
            Text = "%s%% weapon-based damage",
            ContextDescription = "Used as the damage type label for skills that use weapon damage. First param is damage multiplier",
        },
    },
}
Epip.RegisterFeature("Features.TooltipAdjustments.SkillDamageMultipliers", SkillDamageMultipliers)
local TSK = SkillDamageMultipliers.TranslatedStrings

---------------------------------------------
-- METHODS
---------------------------------------------

-- Replace damage paramater with the damage multiplier if the modifier key is being held.
function SkillDamageMultipliers.TranslateSkillMultiplier(event)
    local params = event.Params
    local targetSkill
    if #params == 1 then -- The skill itself
        targetSkill = event.Skill
    elseif #params == 3 then -- Referenced skill
        targetSkill = Stats.GetSkillData(params[2])
    else
        SkillDamageMultipliers:Error("TranslateSkillMultiplier", "Wrong parameters amount in event")
    end

    local isWeaponBased = targetSkill["UseWeaponDamage"] == "Yes"
    local damageMultiplier = targetSkill["Damage Multiplier"]
    local damageType = Damage.GetDamageTypeDefinition(isWeaponBased and "Physical" or targetSkill["DamageType"])

    if isWeaponBased then -- Specific weapon damage types are not supported; will be colored as physical (see above)
        event.Description = TSK.Label_WeaponBased:Format({
            FormatArgs = {damageMultiplier},
            Color = damageType.Color,
        })
    else
        local damageTypeName = damageType.TooltipNameHandle and Text.GetTranslatedString(damageType.TooltipNameHandle, damageType.StringID) or "" -- Use lower-case names, as that's what the tooltips normally use - except for types that don't have them. Empty strings will cause an extra space in the tooltip; this is consistent with the game's behaviour. 

        event.Description = Text.Format("%s%% %s", {
            FormatArgs = {damageMultiplier, damageTypeName},
            Color = damageType.Color,
        })
    end
end

---Returns whether a SkillGetDescriptionParam event is requesting the description for a Damage parameter.
---@param ev EclLuaSkillGetDescriptionParamEvent
---@return boolean
function SkillDamageMultipliers._IsDamageParam(ev)
    local params = ev.Params
    local isDamageParam = false

    if #params == 1 then -- Damage of the skill itself
        isDamageParam = params[1] == "Damage"
    elseif #params == 3 then -- Damage of other referenced skills
        isDamageParam = params[1] == "Skill" and params[3] == "Damage"
    end

    return isDamageParam
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Show Damage skill params as %-based if shift is held
Ext.Events.SkillGetDescriptionParam:Subscribe(function (ev)
    if Client.Input.IsShiftPressed() and SkillDamageMultipliers._IsDamageParam(ev) then
        SkillDamageMultipliers.TranslateSkillMultiplier(ev)
    end
end, {EnabledFunctor = SkillDamageMultipliers:GetEnabledFunctor()})
