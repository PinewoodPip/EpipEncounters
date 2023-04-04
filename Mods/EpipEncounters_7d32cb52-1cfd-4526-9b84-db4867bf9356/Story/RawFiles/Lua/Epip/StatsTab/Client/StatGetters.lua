
---------------------------------------------
-- Getters for stats implemented in Epip.
---------------------------------------------

local Tab = Client.UI.CharacterSheet.StatsTab
local CharacterSheet = Client.UI.CharacterSheet
local EpipStats = Epip.GetFeature("Feature_CustomStats")

---------------------------------------------
-- Vanilla Character stats
---------------------------------------------

Tab.RegisterStatValueHook("LifeSteal", function(value, data, char)
    return char.Stats.LifeSteal
end)

---------------------------------------------
-- ARTIFACTS
---------------------------------------------

CharacterSheet.StatsTab:RegisterHook("GetStatValue", function(value, data, char)
    if Artifact.GetData(data.ID) then
        if Artifact.IsEquipped(char, data.ID) then
            return 1
        else
            return 0
        end
    end
end)

---------------------------------------------
-- MISC
---------------------------------------------

Tab.RegisterStatValueHook("PartyFunds_Gold", function(value, data, char)
    return Item.GetPartyTemplateCount("LOOT_Gold_A_1c3c9c74-34a1-4685-989e-410dc080be6f")
end)

Tab.RegisterStatValueHook("PartyFunds_Splinters", function(value, data, char)
    return Item.GetPartyTemplateCount("AMER_LOOT_GreatforgeFragment_A_a41f2a71-6ff1-4c60-a74a-20c96fb9c487")
end)

---------------------------------------------
-- GENERIC
---------------------------------------------

-- Value hook for tagged stats
CharacterSheet.StatsTab:RegisterHook("GetStatValue", function(value, data, char)
    local cachedValue = EpipStats.cachedStats[data.ID]

    if cachedValue then
        return cachedValue
    end
end)

-- Grey out 0'd stat labels
CharacterSheet.StatsTab:RegisterHook("FormatLabel", function(label, data, value)
    -- Prefix keywords with ACT/MUTA
    if data.Keyword and data.BoonType then
        local prefix = "MUTA: "
        if data.BoonType == "Activator" then
            prefix = "ACT: "
        end
        label = prefix .. label
    end

    -- Grey out stats at 0
    if value == 0 and not EpipStats.IsCategory(data.ID) then
        label = "<font color='32302d'>" .. label .. "</font>"
    end

    return label
end)

CharacterSheet.StatsTab:RegisterHook("FormatStatValue", function(value, data, char)
    local valueStr = value

    -- Boolean stats show no value
    if data.Boolean or EpipStats.IsCategory(data.ID) then
        valueStr = ""
    else
        if data.MaxCharges then
            valueStr = string.format("%d/%d", valueStr, EpipStats.cachedStats[data.MaxCharges] or 0)
        end
    
        if data.Suffix then
            valueStr = valueStr .. data.Suffix
        end
    
        if data.Prefix then
            valueStr = data.Prefix .. valueStr
        end

        -- Grey out
        if value == 0 then
            valueStr = "<font color='32302d'>" .. valueStr .. "</font>"
        end
    end

    return valueStr
end)