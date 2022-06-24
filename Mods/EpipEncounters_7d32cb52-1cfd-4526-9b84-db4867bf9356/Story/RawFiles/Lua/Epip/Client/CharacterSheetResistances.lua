
---------------------------------------------
-- Display Physical and Piercing resistance in character sheet.
---------------------------------------------

local Resistances = {
    
}
Epip.AddFeature("CharacterSheetResistances", nil, Resistances)

local CharacterSheet = Client.UI.CharacterSheet

-- TODO move elsewhere - maybe a whole util lib for strings.
local function Colorize(str, color)
    return '<font color="' .. color .. '">' .. str .. "</font>"
end

CharacterSheet:RegisterHook("SecondaryStatUpdate", function(stats, char)
    if not Resistances:IsEnabled() then return nil end

    -- Calculated, final values.
    local physRes = char.Stats.PhysicalResistance
    local pierceRes = char.Stats.PiercingResistance

    local physLabel = "Physical"
    local pierceLabel = "Pierce"

    -- Mimicking vanilla behaviour of colorizing boosted stats
    local physResString = tostring(physRes) .. "%"
    if physRes > 0 then 
        physResString = Colorize(physResString, Data.Colors.StatBlue)
        physLabel = Colorize(physLabel, Data.Colors.StatBlue)
    elseif physRes < 0 then
        physResString = Colorize(physResString, Data.Colors.StatRed)
        physLabel = Colorize(physLabel, Data.Colors.StatRed)
    end

    local piercingResString = tostring(pierceRes) .. "%"
    if pierceRes > 0 then
        piercingResString = Colorize(piercingResString, Data.Colors.StatBlue)
        pierceLabel = Colorize(pierceLabel, Data.Colors.StatBlue)
    elseif pierceRes < 0 then
        piercingResString = Colorize(piercingResString, Data.Colors.StatRed)
        pierceLabel = Colorize(pierceLabel, Data.Colors.StatRed)
    end

    table.insert(stats, {
        IsSpacingElement = false,
        Group = 2,
        Label = physLabel,
        Value = physResString,
        EngineStat = 24,
        Icon = 21,
        Unknown1 = 20,
    })

    table.insert(stats, {
        IsSpacingElement = false,
        Group = 2,
        Label = pierceLabel,
        Value = piercingResString,
        EngineStat = 23,
        Icon = 22,
        Unknown1 = 17,
    })
end)