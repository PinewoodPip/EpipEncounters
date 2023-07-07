
---@class Feature_HotbarActions
local Actions = Epip.GetFeature("Feature_HotbarActions")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the Meditate and Source Infuse actions.
Actions.Events.ActionUsed:Subscribe(function (ev)
    local char = ev.Character

    if ev.Action.ID == "EE_Meditate" then
        Osiris.CharacterUseSkill(char, "Shout_NexusMeditate", char, 0 ,0, 0);
    elseif ev.Action.ID == "EE_SourceInfuse" then
        if Character.IsInCombat(char) then -- Character must be in combat and be the active combatant
            local combatID = Combat.GetCombatID(char)
            if combatID and Combat.GetActiveCombatant(combatID) == char then
                Osiris.CharacterUseSkill(char, "Shout_SourceInfusion", char, 0 ,0, 0);
            end
        end
    end
end)

-- Listen for Toggle Party Link action.
Actions.Events.ActionUsed:Subscribe(function (ev)
    if ev.Action.ID == "EPIP_TogglePartyLink" then
        Osiris.PROC_PIP_Hotkey_TogglePartyLink(ev.Character)
    end
end)

-- Listen for Bedroll Rest action.
-- Requires only one bedroll, anywhere in the party inventory.
Actions.Events.ActionUsed:Subscribe(function (ev)
    if ev.Action.ID == "EPIP_UserRest" then
        Osiris.PROC_PIP_Hotkey_UserRest(ev.Character)
    end
end)

-- Listen for Respec Mirror action.
-- Requires only one portable respec mirror, anywhere in the party inventory.
Actions.Events.ActionUsed:Subscribe(function (ev)
    if ev.Action.ID == "PIP_Respec" then
        Osiris.PROC_PIP_Hotkey_Respec(ev.Character)
    end
end)

-- Forward net events as ActionUsed event listeners.
Net.RegisterListener(Actions.NET_MSG_ACTION_USED, function (payload)
    Actions.Events.ActionUsed:Throw({
        Character = payload:GetCharacter(),
        Action = Actions.GetAction(payload.ActionID),
    })
end)