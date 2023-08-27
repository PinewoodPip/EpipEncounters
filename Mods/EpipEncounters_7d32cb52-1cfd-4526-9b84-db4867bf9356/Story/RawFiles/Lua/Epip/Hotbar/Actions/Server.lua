
local SourceInfusion, Meditate = EpicEncounters.SourceInfusion, EpicEncounters.Meditate

---@class Feature_HotbarActions
local Actions = Epip.GetFeature("Feature_HotbarActions")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the Meditate and Source Infuse actions.
Actions.Events.ActionUsed:Subscribe(function (ev)
    local char = ev.Character

    if ev.Action.ID == "EE_Meditate" then
        Meditate.RequestMeditate(char)
    elseif ev.Action.ID == "EE_SourceInfuse" then
        SourceInfusion.RequestInfusion(ev.Character)
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
        local restItems = Osiris.QueryDatabase("DB_RestTemplates", nil, nil, nil, nil)
        for _,tuple in ipairs(restItems) do
            local template = tuple[1]
            local itemCount = Osiris.ItemTemplateIsInPartyInventory(ev.Character, template, 0)
            if itemCount > 0 then
                local itemGUID = Osiris.GetItemForItemTemplateInPartyInventory(ev.Character, template)
                Osiris.CharacterUseItem(ev.Character, itemGUID, "")
            else
                Net.PostToCharacter(ev.Character, Actions.NET_MSG_USERREST_NOBEDROLL)
            end
        end
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