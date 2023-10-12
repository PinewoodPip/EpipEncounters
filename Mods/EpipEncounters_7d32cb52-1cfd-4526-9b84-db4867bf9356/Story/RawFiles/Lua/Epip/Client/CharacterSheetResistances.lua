
---------------------------------------------
-- Display Physical and Piercing resistance in character sheet.
---------------------------------------------

local Resistances = {
    
}
Epip.RegisterFeature("CharacterSheetResistances", Resistances)

local CharacterSheet = Client.UI.CharacterSheet

-- TODO move elsewhere - maybe a whole util lib for strings.
local function Colorize(str, color)
    return '<font color="' .. color .. '">' .. str .. "</font>"
end

CharacterSheet.Hooks.UpdateSecondaryStats:Subscribe(function (ev)
    if Resistances:IsEnabled() then
        local char = ev.Character

        -- Calculated, final values.
        local physRes = char.Stats.PhysicalResistance
        local pierceRes = char.Stats.PiercingResistance

        local physColor = nil
        local pierceColor = nil

        -- Mimicking vanilla behaviour of colorizing boosted stats
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

        local physLabel = Text.Format("Physical", {
            Color = physColor,
        })
        local pierceLabel = Text.Format("Pierce", {
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