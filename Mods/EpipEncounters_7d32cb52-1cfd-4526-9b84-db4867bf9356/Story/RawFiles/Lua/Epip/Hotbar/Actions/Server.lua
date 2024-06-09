
local SourceInfusion, Meditate = EpicEncounters.SourceInfusion, EpicEncounters.Meditate

---@class Feature_HotbarActions
local Actions = Epip.GetFeature("Feature_HotbarActions")

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns a teleporter pyramid in char's inventory.
---@param char EsvCharacter
---@return GUID? --`nil` if the character has no pyramid.
function Actions._GetTeleporterPyramidInInventory(char)
    local pyramidGUID = nil
    for guid,_ in pairs(Actions.TELEPORTER_PYRAMID_GUIDS) do
        local isInCharacterInventory = Osi.GetInventoryOwner(guid) == char.MyGuid
        if isInCharacterInventory then
            pyramidGUID = guid
            break
        end
    end
    return pyramidGUID
end

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

-- Listen for use pyramid action.
Actions.Events.ActionUsed:Subscribe(function (ev)
    if ev.Action.ID == "EPIP_UsePyramid" then
        local userID = ev.Character.ReservedUserID
        local partyMembers = Character.GetPartyMembers(ev.Character)
        local pyramidGUID = Actions._GetTeleporterPyramidInInventory(ev.Character) -- Check if the source character has a pyramid first

        -- Check other party members
        if not pyramidGUID then
            -- Prioritize characters controlled by the same user.
            table.sort(partyMembers, function (a, b)
                local scoreA, scoreB = a.NetID, b.NetID
                if a.ReservedUserID == userID then
                    scoreB = -scoreB
                end
                if b.ReservedUserID == userID then
                    scoreA = -scoreA
                end
                return scoreA > scoreB
            end)

            for _,member in ipairs(partyMembers) do
                if member ~= ev.Character then
                    pyramidGUID = Actions._GetTeleporterPyramidInInventory(member)
                    if pyramidGUID then break end
                end
            end
        end

        if pyramidGUID then
            Osiris.CharacterUseItem(ev.Character, pyramidGUID, "")
        end
    end
end)

-- Forward net events as ActionUsed event listeners.
Net.RegisterListener(Actions.NET_MSG_ACTION_USED, function (payload)
    Actions.Events.ActionUsed:Throw({
        Character = payload:GetCharacter(),
        Action = Actions.GetAction(payload.ActionID),
    })
end)