
---------------------------------------------
-- Client scripting for the Epic Enemies feature.
---------------------------------------------

Epip.Features.EpicEnemies = {
    -- Prefix for the display statuses. We check for those to determine what special logic an enemy has.
    STATUS_PREFIX = "PIP_EpicBosses_",
    INFO_STATUS = "PIP_OSITOOLS_EpicBossesDisplay", -- Status that shows condensed tooltip.
    DESCRIPTION_PARAM = "PIP_OSITOOLS_EpicBossesDisplay",

    -- Descriptions of the effects, for condensed tooltips.
    BOONS = {
        ["Ascension_Elementalist_ACT_FireEarth_AllySkills"] = "- Elementalist Activator: Falcon; Geomancer/Pyromancer",
        ["Ascension_Elementalist_ACT_PredatorOrVuln3"] = "- Elementalist Activator: Arcanist; Predator/Vulnerable III",
        ["Ascension_Elementalist_ACT_AirWater_AllySkills"] = "- Elementalist Activator: Hind; Aerotheurge/Hydrosophist",
        ["Ascension_Elementalist_ACT_AirWater_AllySkills_MK2_HuntsWar"] = "- Elementalist Activator: Pegasus; Huntsman/Warfare",
        ["Ascension_Elementalist_MUTA_FireEarth_NonTieredStatuses"] = "- Elementalist Mutator: Falcon; Calcifying/Scorched",
        ["Ascension_ViolentStrike_ACT_ElemStacks"] = "- Elementalist Mutator: Arcanist; Violent Strike when 2 or more stacks",
        ["Ascension_Elementalist_MUTA_FeedbackPowerEffect"] = "- Elementalist Mutator: Kraken; +10% Damage from Power per stack",
        ["Ascension_Elementalist_MUTA_FeedbackCrit"] = "- Elementalist Mutator: Scorpion; +5% Crit Chance per stack",
    
        ["Ascension_Predator_ACT_BHStacks"] = "- Predator Activator: Falcon; After reaching 7 stacks of either Battered or Harried",
        ["Ascension_Predator_ACT_Terrified"] = "- Predator Activator: Manticore; Terrified",
        ["Ascension_Predator_ACT_Dazzled"] = "- Predator Activator: Tiger; Dazzled",
        ["Ascension_Predator_MUTA_Hemorrhage"] = "- Predator Mutator: Tiger; Apply Hemorrhage if target is Bleeding",
        ["Ascension_Predator_MUTA_Slowed2"] = "- Predator Mutator: Falcon; Apply up to Slowed II",
    
        ["Ascension_ViolentStrike_ACT_BasicOnHit"] = "- Violent Strikes Activator: Conqueror; 15% chance per hit",
        ["Ascension_ViolentStrike_ACT_DamageAtOnce"] = "- Violent Strikes Activator: Archer; After dealing damage exceeding 20% of total Vitality",
        ["Ascension_ViolentStrike_ACT_0AP"] = "- Violent Strikes Activator: Hatchet; After reaching 0 AP",
        ["Ascension_ViolentStrike_MUTA_VitalityVoidACT"] = "- Violent Strikes Mutator: Conqueror; Vitality Void when performing Violent Strike",
        ["Ascension_ViolentStrike_MUTA_Terrified2"] = "- Violent Strikes Mutator: Hatchet; Apply up to Terrified II",
    
        ["Ascension_Centurion_ACT_MissedByAttack"] = "- Centurion Activator: Key; After dodging an attack",
        ["Ascension_Centurion_ACT_HitAlly"] = "- Centurion Activator: Guardsman; When an ally is hit",
    
        ["Ascension_Celestial_ACT_Offensive"] = "- Celestial Activator: Champion; Vulnerable III",
        ["Ascension_Celestial_ACT_AllySource"] = "- Celestial Activator: Hind; When an ally with less than 50% Vitality spends Source",
    
        ["Ascension_VitalityVoid_ACT_CombatDeath"] = "- Vitality Void Activator: Death; When a non-summon character dies",
        ["Ascension_VitalityVoid_ACT_SourceSpent"] = "- Vitality Void Activator: Fly; For each Source Point spent",
    
        ["Ascension_Ward_ACT_MK2_CritByEnemy"] = "- Ward Activator: Gryphon; When being Critically Hit",
    
        ["Ascension_MageFin"] = "- Spellcaster Finesse; Finesse's AP recovery works on magic spells",
        ["Ascension_Presence_MUTA_MK2_VitRegen"] = "- Presence Mutators: missing Vitality regeneration, damage and resistances",
        ["Ascension_Wither_ACT_Calcifying"] = "- Wither Activator: Basilisk; Calcifying also applies Wither",
        ["Ascension_Skill_BoneshapedCrusher"] = "- Summon Boneshaped Crusher Spell",
    },
}
local EpicEnemies = Epip.Features.EpicEnemies

---------------------------------------------
-- LISTENERS
---------------------------------------------

-- Ext.Events.StatusGetDescriptionParam:Subscribe(function(event)
--     local status = event.Status
--     local char = event.Owner
--     local source = event.StatusSource
--     local params = event.Params
--     local mainParam = params["1"]

--     if status.Name == EpicEnemies.INFO_STATUS and mainParam == EpicEnemies.DESCRIPTION_PARAM then
--         local tooltip = {}
--         local finalString = ""

--         for specialLogic, desc in pairs(EpicEnemies.BOONS) do
--             local status = EpicEnemies.STATUS_PREFIX .. specialLogic

--             if (char.Character:GetStatus(status) ~= nil) then
--                 finalString = finalString .. desc .. "<br>"
--             end
--         end

--         event.Description = finalString
--         return finalString
--    end
-- end)

---------------------------------------------
-- SETUP
---------------------------------------------

-- Patch display statuses to be invisible.
Ext.Events.StatsLoaded:Subscribe(function()
    for logic,desc in pairs(EpicEnemies.BOONS) do

        local statID = EpicEnemies.STATUS_PREFIX .. logic
        local stat = Ext.Stats.Get(statID)

        if stat ~= nil then
            stat.DisplayName = " "
            stat.Icon = ""
            -- Ext.SyncStat(statID)
        end
    end
end)