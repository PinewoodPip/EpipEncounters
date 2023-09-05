
---------------------------------------------
-- Getters for stats implemented in Epip.
---------------------------------------------

local CharacterSheet = Client.UI.CharacterSheet

---@class Feature_CustomStats
local EpipStats = Epip.GetFeature("Feature_CustomStats")
EpipStats.DEFAULT_VALUE_COLOR = "32302D"

---------------------------------------------
-- Vanilla Character stats
---------------------------------------------

-- Lifesteal stat
EpipStats.RegisterStatValueHook("LifeSteal", function (ev)
    ev.Value = ev.Character.Stats.LifeSteal
end)

---------------------------------------------
-- ARTIFACTS
---------------------------------------------

if EpicEncounters.IsEnabled() then
    EpipStats.Hooks.GetStatValue:Subscribe(function (ev)
        local isArtifact = Artifact.GetData(ev.Stat:GetID())
    
        if isArtifact then
            ev.Value = Artifact.IsEquipped(ev.Character, ev.Stat:GetID())
        end
    end)
end

---------------------------------------------
-- MISC
---------------------------------------------

-- Party gold stat
EpipStats.RegisterStatValueHook("PartyFunds_Gold", function (ev)
    ev.Value = Item.GetPartyTemplateCount("1c3c9c74-34a1-4685-989e-410dc080be6f")
end)

-- Party splinters stat
EpipStats.RegisterStatValueHook("PartyFunds_Splinters", function (ev)
    ev.Value = Item.GetPartyTemplateCount("a41f2a71-6ff1-4c60-a74a-20c96fb9c487")
end)

---------------------------------------------
-- GENERIC
---------------------------------------------

CharacterSheet.StatsTab:RegisterHook("FormatStatValue", function(value, data, char)
    -- Value is `nil` for unset stats.
    local valueStr = value and Text.Round(value, 2) or ""

    -- Boolean stats show no value
    if data.Boolean or EpipStats.IsCategory(data.ID) then
        valueStr = ""
    else
        if data.MaxCharges then
            valueStr = string.format("%d/%d", valueStr, EpipStats.GetStatValue(char, data.MaxCharges) or 0)
        end

        -- Suffix and prefix
        if data.Suffix then
            valueStr = valueStr .. data.Suffix
        end
        if data.Prefix then
            valueStr = data.Prefix .. valueStr
        end

        -- Grey out absent stats
        if EpipStats.StatIsAtDefaultValue(char, data.ID) then
            valueStr = Text.Format(valueStr, {Color = EpipStats.DEFAULT_VALUE_COLOR})
        end
    end

    return valueStr
end)