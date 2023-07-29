
---@class Features.PunisherVoiceActing
local VA = Epip.GetFeature("Features.PunisherVoiceActing")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for confirmation from the host that the date range is valid.
Net.RegisterListener(VA.NETMSG_DATERANGE_VALID, function (_)
    VA:DebugLog("Received date range confirmation")
    VA._IsDateRangeValid = true

    Net.Broadcast(VA.NETMSG_DATERANGE_VALID)

    -- Play extra party-size-related voicelines upon entering combat.
    Osiris.RegisterSymbolListener("ObjectEnteredCombat", 2, "after", function (objGUID, _)
        if Text.RemoveGUIDPrefix(objGUID) == VA.PUNISHER_GUIDS.FJ_TOWER then
            Timer.Start(10, function (_)
                local punisher = Character.Get(objGUID)
                local partySize = Osiris.SysCount("DB_IsPlayer", 1)

                if partySize <= 2 then -- Lone wolf
                    Osiris.CharacterStatusText(punisher, VA.EXTRA_CLIPS.FACETANKING)
                elseif partySize ~= 4 then -- Weird-sized party
                    Osiris.CharacterStatusText(punisher, VA.EXTRA_CLIPS.NOT_4MAN)
                end
            end)
        end
    end)

    -- Play extra lines on round start.
    Osiris.RegisterSymbolListener("CombatRoundStarted", 2, "after", function (combatID, round)
        if round == 2 then
            local punisher = Character.Get(VA.PUNISHER_GUIDS.FJ_TOWER)

            if punisher and Combat.GetCombatID(punisher) == combatID then
                -- Check for cringe mod setups
                if not Mod.IsLoaded(Mod.GUIDS.EE_DERPY_ARTIFACT_TIERS) then -- No artifact tiers
                    Osiris.CharacterStatusText(punisher, VA.EXTRA_CLIPS.NO_ARTIFACT_TIERS)
                end
            end
        end
    end)

    -- Play extra difficulty complaint dialogue on death
    Osiris.RegisterSymbolListener("PROC_Derpy_PunisherDeath", 0, "after", function ()
        local coro = Coroutine.Create(function (inst)
            inst:Sleep(3)
            Osiris.CharacterStatusText(VA.PUNISHER_GUIDS.FJ_TOWER, VA.EXTRA_CLIPS.CRINGE_DIFFICULTY_1)
            inst:Sleep(7)
            Osiris.CharacterStatusText(VA.PUNISHER_GUIDS.FJ_TOWER, VA.EXTRA_CLIPS.CRINGE_DIFFICULTY_2)
        end)
        coro:Continue()
    end)
end)

GameState.Events.ClientReady:Subscribe(function (_)
    if VA._IsDateRangeValid then
        Net.Broadcast(VA.NETMSG_DATERANGE_VALID)
    end
end)