
-- Temporary script to hide Incons (and LC in Derpy's).

Client.UI.CharacterCreation.Hooks.UpdateTalents:Subscribe(function (ev)
    for i,entry in ipairs(ev.Talents) do
        if entry.TalentID == Character.Talents.Stench.NumericID then
            table.remove(ev.Talents, i)
            break
        end
    end
end)

Client.UI.CharacterSheet.Hooks.UpdateTalents:Subscribe(function (ev)
    for i,entry in ipairs(ev.Stats) do
        if entry.StatID == Character.Talents.Stench.NumericID then
            table.remove(ev.Stats, i)
            break
        end
    end
end)

-- Hide Lucky Charm.
if Mod.IsLoaded(Mod.GUIDS.EE_DERPY) then
    Client.UI.CharacterSheet.Hooks.UpdateAbilityStats:Subscribe(function (ev)
        for i,entry in ipairs(ev.Stats) do
            if entry.StatID == 33 then
                table.remove(ev.Stats, i)
                break
            end
        end
    end)

    Client.UI.CharacterCreation.Hooks.UpdateAbilities:Subscribe(function (ev)
        for i,entry in ipairs(ev.Abilities) do
            if entry.StatID == 33 then
                table.remove(ev.Abilities, i)
                break
            end
        end
    end)
end