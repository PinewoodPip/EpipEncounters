
---@class Features.MeditateControllerSupport
local Support = Epip.GetFeature("Features.MeditateControllerSupport")

---------------------------------------------
-- METHODS
---------------------------------------------

---Causes char to exit their current meditate UI.
---@param char EsvCharacter
function Support.ExitUI(char)
    if Osi.DB_AMER_UI_UsersInUI:Get(nil, nil, char.RootTemplate.Id .. "_" .. char.MyGuid)[1] ~= nil then
        Osiris.CharacterUseSkill(char, EpicEncounters.Meditate.MEDITATE_SKILL_ID, char, 1, 1, 1)
    end
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- TODO remove
Osiris.RegisterSymbolListener("CharacterItemEvent", 3, "after", function(char, item, event)
    if string.find(event, "AMER") then
        print("CharacterItemEvent", char, item, event)
    end
end)

Net.RegisterListener(Support.NETMSG_INTERACT, function (payload)
    local char = payload:GetCharacter()
    local instanceID = Osi.DB_AMER_UI_UsersInUI:Get(nil, nil, char.RootTemplate.Id .. "_" .. char.MyGuid)[1][1]
    -- TODO page sanity checks
    local element = Osi.DB_AMER_UI_ElementsOfInstance:Get(instanceID, "AMER_UI_Ascension", payload.CollectionID, payload.ElementID, nil)[1][5] -- TODO
    Osiris.CharacterUseItem(char, element, payload.EventID)
end)

-- Exit the UI when lua is reset, for testing convenience,
-- as the libraries do not support the UI being open right after initialization.
Ext.Events.ResetCompleted:Subscribe(function (_)
    local host = Character.Get(Osiris.CharacterGetHostCharacter())
    Support.ExitUI(host)
end)

-- Handle requests to exit the UI.
Net.RegisterListener(Support.NETMSG_EXIT, function (payload)
    local char = payload:GetCharacter()
    Support.ExitUI(char)
end)
