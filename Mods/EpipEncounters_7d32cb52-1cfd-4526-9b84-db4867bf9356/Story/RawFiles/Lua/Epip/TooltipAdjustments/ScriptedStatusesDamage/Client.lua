
---------------------------------------------
-- Displays calculated damage for statuses that deal damage through scripted projectiles.
---------------------------------------------

local Tooltip = Client.Tooltip

---@class Features.TooltipAdjustments.ScriptedStatusesDamage : Feature
local StatusDamage = {
    ---Maps status IDs to their scripted projectile skill.
    ---@type table<string, skill>
    DAMAGE_PROJECTILES = {
        -- EE
        AMER_ENTHRALLED_1 = "Projectile_AMER_SCRIPT_StatusDamage_Enthralled_1",
        AMER_ENTHRALLED_2 = "Projectile_AMER_SCRIPT_StatusDamage_Enthralled_1",
        AMER_ENTHRALLED_3 = "Projectile_AMER_SCRIPT_StatusDamage_Enthralled_1",
        AMER_SCORCHED = "Projectile_AMER_SCRIPT_StatusDamage_Burning",
        AMER_CALCIFYING = "Projectile_AMER_SCRIPT_StatusDamage_Calcifying",
        POISONED = "Projectile_AMER_SCRIPT_StatusDamage_Poisoned",
        BLEEDING = "Projectile_AMER_SCRIPT_StatusDamage_Bleeding",
        AMER_HEMORRHAGE = "Projectile_AMER_SCRIPT_StatusDamage_Bleeding",
        AMER_CORRODING = "Projectile_AMER_SCRIPT_StatusDamage_Acid",
        ACID = "Projectile_AMER_SCRIPT_StatusDamage_Acid",
        SUFFOCATING = "Projectile_AMER_SCRIPT_StatusDamage_Suffocating",
        AMER_BANE = "Projectile_AMER_SCRIPT_StatusDamage_Bane",
        AMER_THEKRAKEN_FIRE = "Projectile_AMER_SCRIPT_StatusDamage_Kraken_Fire",
        AMER_THEKRAKEN_WATER = "Projectile_AMER_SCRIPT_StatusDamage_Kraken_Water",
        AMER_THEKRAKEN_EARTH = "Projectile_AMER_SCRIPT_StatusDamage_Kraken_Earth",
        AMER_THEKRAKEN_AIR = "Projectile_AMER_SCRIPT_StatusDamage_Kraken_Air",
        AMER_CHARGED = "Projectile_AMER_SCRIPT_StatusDamage_Charged",
        AMER_BRITTLE_1 = "Projectile_AMER_SCRIPT_StatusDamage_Brittle",
        AMER_BRITTLE_2 = "Projectile_AMER_SCRIPT_StatusDamage_Brittle",
        AMER_BRITTLE_3 = "Projectile_AMER_SCRIPT_StatusDamage_Brittle",
    },
    -- Maps EE scripted projectile to its Torturer replacement.
    EE_TORTURER_SKILL_OVERRIDES = {
        Projectile_AMER_SCRIPT_StatusDamage_Burning = "Projectile_AMER_SCRIPT_StatusDamage_Burning_Tort",
        -- Projectile_AMER_SCRIPT_StatusDamage_Calcifying = "Projectile_AMER_SCRIPT_StatusDamage_Calcifying_Tort", -- Effect was changed at some point.
        Projectile_AMER_SCRIPT_StatusDamage_Poisoned = "Projectile_AMER_SCRIPT_StatusDamage_Poisoned_Tort",
        Projectile_AMER_SCRIPT_StatusDamage_Bleeding = "Projectile_AMER_SCRIPT_StatusDamage_Bleeding_Tort",
        Projectile_AMER_SCRIPT_StatusDamage_Acid = "Projectile_AMER_SCRIPT_StatusDamage_Acid_Tort",
        Projectile_AMER_SCRIPT_StatusDamage_Corroding_Removed = "Projectile_AMER_SCRIPT_StatusDamage_Corroding_Removed_Tort",
        Projectile_AMER_SCRIPT_StatusDamage_Suffocating = "Projectile_AMER_SCRIPT_StatusDamage_Suffocating_Tort",
        Projectile_AMER_SCRIPT_StatusDamage_Charged = "Projectile_AMER_SCRIPT_StatusDamage_Charged_Tort",
    },

    TranslatedStrings = {
        Pattern_BeforeDamageModifiers = {
            Handle = "hd3c5462egafcbg4008gbba8g657cffae5ed7",
            Text = " %(before damage modifiers%)",
            ContextDescription = [[Pattern for removing EE "Before damage modifiers" status tooltips. Parenthesis must be prefixed by %]],
        },
        Pattern_BeforeModifiers = {
            Handle = "h02273499g09a1g4dccg8d25g55913948a95b",
            Text = " %(before modifiers%)",
            ContextDescription = [[Pattern for removing EE "Before modifiers" status tooltips. Parenthesis must be prefixed by %]],
        },
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,

    Hooks = {
        GetSkill = {}, ---@type Hook<Features.TooltipAdjustments.ScriptedStatusesDamage.Hooks.GetSkill>
    }
}
Epip.RegisterFeature("Features.TooltipAdjustments.ScriptedStatusesDamage", StatusDamage)
local TSK = StatusDamage.TranslatedStrings

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.TooltipAdjustments.ScriptedStatusesDamage.Hooks.GetSkill
---@field SkillID skill Hookable. Defaults to skill from `DAMAGE_PROJECTILES`.
---@field StatusID string
---@field SourceStats StatsObjectInstance

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the skill ID to use for a status.
---@param status EclStatus|string
---@param sourceStats StatsObjectInstance
---@return skill?
function StatusDamage.GetSkill(status, sourceStats)
    local statusID = GetExtType(status) and status.StatusId or status -- String ID overload.
    return StatusDamage.Hooks.GetSkill:Throw({
        SkillID = StatusDamage.DAMAGE_PROJECTILES[statusID],
        StatusID = statusID,
        SourceStats = sourceStats,
    }).SkillID
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Remove "Before modifiers" labels from EE status tooltips.
Tooltip.Hooks.RenderStatusTooltip:Subscribe(function (ev)
    local tooltip = ev.Tooltip
    local statusOwner = Character.Get(ev.Status.StatusSourceHandle)
    if statusOwner and StatusDamage.GetSkill(ev.Status, statusOwner.Stats) ~= nil then -- Only do this for affected skills.
        for _,v in pairs(tooltip.Elements) do
            if v.Type == "StatusDescription" then
                v.Label = v.Label:gsub(TSK.Pattern_BeforeModifiers:GetString(), "")
                v.Label = v.Label:gsub(TSK.Pattern_BeforeDamageModifiers:GetString(), "")
            end
        end
    end
end, {EnabledFunctor = StatusDamage:GetEnabledFunctor()})

-- Replace status tooltip damage parameters with the calculated damage of the scripted skill.
Ext.Events.StatusGetDescriptionParam:Subscribe(function (ev)
    if not StatusDamage:IsEnabled() then return end
    local status = ev.Status
    local source = ev.StatusSource
    local params = ev.Params
    local mainParam = params["1"]

    -- Only proceed for Damage parameter for statuses applied by characters.
    if not source or mainParam ~= "Damage" then return end
    if not GetExtType(source) == "CDivinityStats_Character" then return end
    ---@cast source CDivinityStats_Character

    local skillName = StatusDamage.GetSkill(status.StatusName, source)
    if not skillName then return end

    local skill = Ext.Stats.Get(skillName)
    local level = source.Level

    local damage = GetSkillDamage(skill, source, true, false, {0, 0, 0}, {0, 0, 0}, level, true, nil, nil)

    local newTable = {}
    local newString = ""

    for i,d in pairs(damage:ToTable()) do
        local damageRange = skill["Damage Range"] -- +/- 50% of the damage multiplier
        local minDmg = d.Amount * (1 - ((damageRange/2) / 100))
        local maxDmg = d.Amount * (1 + ((damageRange/2) / 100))

        minDmg = math.max(minDmg, 1)
        minDmg = math.floor(minDmg)

        maxDmg = math.max(maxDmg, 1)
        maxDmg = math.floor(maxDmg)

        local color = ""
        local dName = ""
        local damageType = Damage.GetDamageTypeDefinition(d.DamageType)
        if damageType then
            color = damageType.Color
            dName = Text.GetTranslatedString(damageType.TooltipNameHandle)
        else
            StatusDamage:__LogWarning("Damage type not registered, is it custom?", d.DamageType)
            return
        end

        local dmgString = Text.Format("%s-%s %s", {
            FormatArgs = {
                minDmg, maxDmg, dName,
            },
            Color = color,
        })

        table.insert(newTable, {Amount = dmgString, DamageType = d.DamageType})

        newString = newString .. dmgString
        if i ~= #damage:ToTable() then
            newString = newString .. " + "
        end
    end

    ev.Description = newString
end)

-- In EE, override certain skills with alternative ones when the source character has Torturer.
StatusDamage.Hooks.GetSkill:Subscribe(function (ev)
    local source = ev.SourceStats
    if GetExtType(source) == "CDivinityStats_Character" then -- Only do this for statuses applied by characters.
        ---@cast source CDivinityStats_Character
        if source.TALENT_Torturer then
            print(ev.StatusID)
            ev.SkillID = StatusDamage.EE_TORTURER_SKILL_OVERRIDES[ev.SkillID] or ev.SkillID
            print(ev.SkillID)
        end
    end
end, {StringID = "EE.TorturerOverrides", Priority = -9999})
