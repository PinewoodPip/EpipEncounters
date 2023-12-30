
---------------------------------------------
-- Display Physical and Piercing resistances in character sheet.
---------------------------------------------

---@type Feature
local Resistances = {
    -- I'm not 100% sure where these are used, but they align with our needs, hopefully across all languages.
    -- The examine UI uses different strings (ex. "Physical Resistance")
    RESISTANCE_TSKHANDLES = {
        PHYSICAL = "ha6c38456g4c6ag47b2gae87g60a26cf4bf7b", -- "Physical"
        PIERCING = "h22f6b7bcgc548g49cbgbc04g9532e893fb55", -- "Piercing"
    },
}
Epip.RegisterFeature("CharacterSheetResistances", Resistances)

local CharacterSheet = Client.UI.CharacterSheet

CharacterSheet.Hooks.UpdateSecondaryStats:Subscribe(function (ev)
    if Resistances:IsEnabled() then
        local char = ev.Character

        -- Calculated, final values.
        local physRes = char.Stats.PhysicalResistance
        local pierceRes = char.Stats.PiercingResistance

        local physColor = nil
        local pierceColor = nil

        -- Mimick vanilla behaviour of colorizing boosted stats
        if physRes > 0 then
            physColor = Color.TOOLTIPS.STAT_BLUE
        elseif physRes < 0 then
            physColor = Color.TOOLTIPS.STAT_RED
        end

        if pierceRes > 0 then
            pierceColor = Color.TOOLTIPS.STAT_BLUE
        elseif pierceRes < 0 then
            pierceColor = Color.TOOLTIPS.STAT_RED
        end

        local physLabel = Text.Format(Text.GetTranslatedString(Resistances.RESISTANCE_TSKHANDLES.PHYSICAL, "Physical"), {
            Color = physColor,
        })
        local pierceLabel = Text.Format(Text.GetTranslatedString(Resistances.RESISTANCE_TSKHANDLES.PIERCING, "Piercing"), {
            Color = physColor,
        })

        local physValueLabel = Text.Format("%s%%", {
            FormatArgs = {physRes},
            Color = physColor,
        })
        local pierceValueLabel = Text.Format("%s%%", {
            FormatArgs = {pierceRes},
            Color = pierceColor,
        })

        ---@type SecondaryStat
        local physResEntry = {
            EntryTypeID = "Stat",
            Type = 2,
            Label = physLabel,
            ValueLabel = physValueLabel,
            StatID = 24,
            IconID = 21, -- From UI override.
            BoostValue = 20,
        }

        ---@type SecondaryStat
        local pierceResEntry = {
            EntryTypeID = "Stat",
            Type = 2,
            Label = pierceLabel,
            ValueLabel = pierceValueLabel,
            StatID = 23,
            IconID = 22, -- From UI override.
            BoostValue = 17,
        }

        table.insert(ev.Stats, physResEntry)
        table.insert(ev.Stats, pierceResEntry)
    end
end)