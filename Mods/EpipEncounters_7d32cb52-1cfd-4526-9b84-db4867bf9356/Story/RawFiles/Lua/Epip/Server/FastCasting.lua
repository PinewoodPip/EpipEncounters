
local Casting = {
    SETTING = "FastCasting",
    ANIMATION = "idle1",
}
Epip.AddFeature("FastCasting", "FastCasting", Casting)

---@param charGuid GUID
function Casting.UpdateForCharacter(charGUID)
    if Osiris.DB_IsPlayer:Get(charGUID) then
        if NRD_CharacterGetCurrentAction(charGUID) == "Attack" then
            Osi.ProcObjectTimer(charGUID, "PIP_FastCasting_Buffer", 500)
        else
            CharacterSetAnimationOverride(charGUID, Casting.ANIMATION)
        end
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Osiris.RegisterSymbolListener("PROC_AMER_Combat_TurnStarted", 2, "after", function(char, firstTurnInRound)
    Casting.UpdateForCharacter(char)
end)

Osiris.RegisterSymbolListener("ProcObjectTimerFinished", 2, "after", function(obj, event)
    if event == "PIP_FastCasting_Buffer" then
        Casting.UpdateForCharacter(obj)
    end
end)

Osiris.RegisterSymbolListener("PROC_AMER_ActionPoints_Changed", 3, "after", function(char, old, new)
    Casting.UpdateForCharacter(char)
end)

Osiris.RegisterSymbolListener("PROC_AMER_GEN_BasicAttackObjectStarted", 7, "before", function(defender, _, _, _, attacker, _)
    CharacterFlushQueue(attacker)
    CharacterSetAnimationOverride(attacker, "")
    -- PlayAnimation(attacker, "attack1")
end)