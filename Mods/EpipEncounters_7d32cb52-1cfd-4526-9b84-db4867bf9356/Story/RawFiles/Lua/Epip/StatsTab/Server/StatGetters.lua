
local EpipStats = Epip.GetFeature("Feature_CustomStats")

---------------------------------------------
-- KEYWORDS
---------------------------------------------

---@param char EsvCharacter
---@param embodiment string
function EpipStats.UpdateEmbodiment(char, embodiment)
    local statName = "Embodiment_" .. embodiment
    local value = Osiris.QRY_AMER_UI_Ascension_GetEmbodimentCount(char.MyGuid, embodiment)

    EpipStats.UpdateUserVarStat(char, statName, value)
end

EpipStats.RegisterListener("UpdateStat", function(char, id, _)
    local embodiment = id:match("^Embodiment_(.+)$")

    if embodiment then
        EpipStats.UpdateEmbodiment(char, embodiment)
    end
end)

-- Celestial.
EpipStats.RegisterStatUpdateListener("Keyword_Celestial_Healing", function(char, data)
    local value = EpipStats.GetCelestialRestoration(char)

    EpipStats.UpdateUserVarStat(char, "Keyword_Celestial_Healing", value)
end)

-- Vitality Void.
EpipStats.RegisterStatUpdateListener("Keyword_VitalityVoid_Power", function(char, data)
    local value = Osiris.QRY_AMER_KeywordStat_VitalityVoid_GetPower(char.MyGuid, 1) * 100

    EpipStats.UpdateUserVarStat(char, "Keyword_VitalityVoid_Power", value)
end)

EpipStats.RegisterStatUpdateListener("Keyword_VitalityVoid_Radius", function(char, data)
    local value = Osiris.QRY_AMER_KeywordStat_VitalityVoid_GetRadius(char.MyGuid, 1)

    EpipStats.UpdateUserVarStat(char, "Keyword_VitalityVoid_Radius", value)
end)

-- Prosperity.
EpipStats.RegisterStatUpdateListener("Keyword_Prosperity_Threshold", function(char, data)
    local value = Osiris.QRY_AMER_KeywordStat_Prosperity_GetThreshold(char.MyGuid)

    EpipStats.UpdateUserVarStat(char, "Keyword_Prosperity_Threshold", value)
end)

local function UpdateVoracity(char, voracityType, isSummon)
    local extendedStatName = "Voracity_" .. voracityType
    local value = 0

    if isSummon then
        value = value + EpipStats.GetExtendedStat(char, "SummonStat_ExtendedStat", extendedStatName)
    else
        value = value + EpipStats.GetExtendedStat(char, extendedStatName)
    end

    -- Add BothArmor
    if voracityType == "PhysArmor" or voracityType == "MagicArmor" then
        if isSummon then
            value = value + EpipStats.GetExtendedStat(char, "SummonStat_ExtendedStat", "Voracity_BothArmor")
        else
            value = value + EpipStats.GetExtendedStat(char, "Voracity_BothArmor")
        end
    end

    local stat
    if isSummon then
        stat = "Keyword_Voracity_Summon_" .. voracityType
    else
        stat = "Keyword_Voracity_" .. voracityType
    end

    EpipStats.UpdateUserVarStat(char, stat, value)
end

-- Voracity.
EpipStats.RegisterStatUpdateListener("Keyword_Voracity_Life", function(char, _)
    UpdateVoracity(char, "Life", false)
end)
EpipStats.RegisterStatUpdateListener("Keyword_Voracity_PhysArmor", function(char, _)
    UpdateVoracity(char, "PhysArmor", false)
end)
EpipStats.RegisterStatUpdateListener("Keyword_Voracity_MagicArmor", function(char, _)
    UpdateVoracity(char, "MagicArmor", false)
end)
EpipStats.RegisterStatUpdateListener("Keyword_Voracity_Summon_Life", function(char, _)
    UpdateVoracity(char, "Life", true)
end)
EpipStats.RegisterStatUpdateListener("Keyword_Voracity_Summon_PhysArmor", function(char, _)
    UpdateVoracity(char, "PhysArmor", true)
end)
EpipStats.RegisterStatUpdateListener("Keyword_Voracity_Summon_MagicArmor", function(char, _)
    UpdateVoracity(char, "MagicArmor", true)
end)

---------------------------------------------
-- CURRENT COMBAT STATS
---------------------------------------------

EpipStats.RegisterStatUpdateListener("CurrentCombat_DamageDealt", function(char, _)
    local value = Osiris.GetFirstFactOrEmpty("DB_PIP_EpicStats_DamageDealt", char.MyGuid, nil)[2] or 0

    EpipStats.UpdateUserVarStat(char, "CurrentCombat_DamageDealt", value)
end)

EpipStats.RegisterStatUpdateListener("CurrentCombat_DamageReceived", function(char, _)
    local value = Osiris.GetFirstFactOrEmpty("DB_PIP_EpicStats_DamageReceived", char.MyGuid, nil)[2] or 0
    EpipStats.UpdateUserVarStat(char, "CurrentCombat_DamageReceived", value)
end)

EpipStats.RegisterStatUpdateListener("CurrentCombat_HealingDone", function(char, _)
    local value = Osiris.GetFirstFactOrEmpty("DB_PIP_EpicStats_HealingDone", char.MyGuid, nil)[2] or 0
    EpipStats.UpdateUserVarStat(char, "CurrentCombat_HealingDone", value)
end)

-- Damage taken
Ext.RegisterOsirisListener("NRD_OnHit", 4, "after", function(target, _, amount, _)
    local sourceChar = Character.Get(target)
    if sourceChar and Character.IsPlayer(sourceChar) then
        local oldAmount = Osiris.GetFirstFactOrEmpty("DB_PIP_EpicStats_DamageReceived", target, nil)[2] or 0
        amount = oldAmount + amount

        Osiris.Delete("DB_PIP_EpicStats_DamageReceived", target, nil)
        Osiris.Set("DB_PIP_EpicStats_DamageReceived", target, amount)
    end
end)

-- Healing
Osiris.RegisterSymbolListener("NRD_OnHeal", 4, "after", function(target, source, amount, _)
    source = Osiris.CharacterGetOwner(source) or source

    if Osiris.GetFirstFact("DB_IsPlayer", source) ~= nil and Osiris.CharacterIsPlayer(target) == 1 then
        local oldAmount = Osiris.GetFirstFactOrEmpty("DB_PIP_EpicStats_HealingDone", source, nil)[2] or 0
        amount = oldAmount + amount

        Osiris.Delete("DB_PIP_EpicStats_HealingDone", source, nil)
        Osiris.Set("DB_PIP_EpicStats_HealingDone", source, amount)
    end
end)

-- Damage dealt
Ext.RegisterOsirisListener("NRD_OnHit", 4, "after", function(target, source, amount, handle)
    source = Osiris.CharacterGetOwner(source) or source

    if Osiris.GetFirstFact("DB_IsPlayer", source) ~= nil then
        local oldAmount = Osiris.GetFirstFactOrEmpty("DB_PIP_EpicStats_DamageDealt", source, nil)[2] or 0
        amount = oldAmount + amount

        Osiris.Delete("DB_PIP_EpicStats_DamageDealt", source, nil)
        Osiris.Set("DB_PIP_EpicStats_DamageDealt", source, amount)
    end
end)

-- Reset combat stats upon entering combat.
Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", function(obj, _)
    Osi.PROC_PIP_ResetCombatStats(obj)
end)

---------------------------------------------
-- MISSING REGENERATION
---------------------------------------------

-- Missing regen has Regen_All added to it, and Regen_BothArmor for armor.

EpipStats.RegisterStatUpdateListener("RegenLifeCalculated", function(char, data)
    local value = EpipStats.GetExtendedStat(char, "Regen_All")
    value = value + EpipStats.GetExtendedStat(char, "Regen_Life")

    if value > EpipStats.MISSING_REGEN_CAP then
        value = EpipStats.MISSING_REGEN_CAP
    end

    EpipStats.UpdateUserVarStat(char, "RegenLifeCalculated", value)
end)

EpipStats.RegisterStatUpdateListener("RegenPhysicalArmorCalculated", function(char, data)
    local value = EpipStats.GetExtendedStat(char, "Regen_All")
    value = value + EpipStats.GetExtendedStat(char, "Regen_BothArmor")
    value = value + EpipStats.GetExtendedStat(char, "Regen_PhysicalArmor")

    if value > EpipStats.MISSING_REGEN_CAP then
        value = EpipStats.MISSING_REGEN_CAP
    end

    EpipStats.UpdateUserVarStat(char, "RegenPhysicalArmorCalculated", value)
end)

EpipStats.RegisterStatUpdateListener("RegenMagicArmorCalculated", function(char, data)
    local value = EpipStats.GetExtendedStat(char, "Regen_All")
    value = value + EpipStats.GetExtendedStat(char, "Regen_BothArmor")
    value = value + EpipStats.GetExtendedStat(char, "Regen_MagicArmor")

    if value > EpipStats.MISSING_REGEN_CAP then
        value = EpipStats.MISSING_REGEN_CAP
    end

    EpipStats.UpdateUserVarStat(char, "RegenMagicArmorCalculated", value)
end)

---------------------------------------------
-- REACTION CHARGES
---------------------------------------------

function EpipStats.UpdateReactionCharges(char, stat, reaction)
    local charges = EpipStats.GetCurrentReactionCharges(char, reaction)
    local maxCharges = EpipStats.GetExtendedStat(char, "FreeReactionCharge", reaction)

    EpipStats.UpdateUserVarStat(char, stat, charges)
    EpipStats.UpdateUserVarStat(char, stat .. "_Max", maxCharges)
end

EpipStats.RegisterStatUpdateListener("FreeReaction_Generic", function(char, data)
    EpipStats.UpdateReactionCharges(char, "FreeReaction_Generic", "AnyReaction")
end)
EpipStats.RegisterStatUpdateListener("FreeReaction_Predator", function(char, data)
    EpipStats.UpdateReactionCharges(char, "FreeReaction_Predator", "AMER_Predator")
end)
EpipStats.RegisterStatUpdateListener("FreeReaction_Celestial", function(char, data)
    EpipStats.UpdateReactionCharges(char, "FreeReaction_Celestial", "AMER_Celestial")
end)
EpipStats.RegisterStatUpdateListener("FreeReaction_Centurion", function(char, data)
    EpipStats.UpdateReactionCharges(char, "FreeReaction_Centurion", "AMER_Centurion")
end)
EpipStats.RegisterStatUpdateListener("FreeReaction_Elementalist", function(char, data)
    EpipStats.UpdateReactionCharges(char, "FreeReaction_Elementalist", "AMER_Elementalist")
end)
EpipStats.RegisterStatUpdateListener("FreeReaction_Occultist", function(char, data)
    EpipStats.UpdateReactionCharges(char, "FreeReaction_Occultist", "AMER_Occultist")
end)