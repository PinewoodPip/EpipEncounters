
---@class Features.MeditateControllerSupport
local Support = Epip.GetFeature("Features.MeditateControllerSupport")

---------------------------------------------
-- METHODS
---------------------------------------------

---Returns the UI to the previous page.
---@param char EsvCharacter
function Support.ReturnToPreviousPage(char)
    local instanceID = Support._GetInstanceID(char)
    local element = Support._GetElement(instanceID, Support._GetCurrentUI(instanceID), "Back", "Back")
    if element then
        Osiris.CharacterUseItem(char, element, "AMER_UI_Ascension_NavBar_Back")
    else -- Exit the UI if it's at the starting page.
        Support.ExitUI(char)
    end
end

---Causes char to exit their current meditate UI.
---@param char EsvCharacter
function Support.ExitUI(char)
    if Osi.DB_AMER_UI_UsersInUI:Get(nil, nil, char.RootTemplate.Id .. "_" .. char.MyGuid)[1] ~= nil then
        Osiris.CharacterUseSkill(char, EpicEncounters.Meditate.MEDITATE_SKILL_ID, char, 1, 1, 1)
    end
end

---Scrolls a Wheel element.
---@param instance integer
---@param ui string
---@param wheel string
---@param direction "Previous"|"Next"
function Support.ScrollWheel(instance, ui, wheel, direction)
    local charGUID = Support._GetInstanceCharacter(instance)
    local element = Support._GetElement(instance, ui, wheel, nil)
    if direction == "Previous" then
        Osi.PROC_AMER_UI_ElementWheel_Scroll_Down(charGUID, element)
    else -- "Next" direction case.
        Osi.PROC_AMER_UI_ElementWheel_Scroll_Up(charGUID, element)
    end
end

---Returns the item of an element.
---@param instance integer
---@param ui string
---@param collection string?
---@param name string?
---@return GUID?
function Support._GetElement(instance, ui, collection, name)
    return Osiris.GetFirstFactOrEmpty("DB_AMER_UI_ElementsOfInstance", instance, ui, collection, name, nil)[5]
end

---Returns the character of an instance.
---@param instance integer
---@return GUID
function Support._GetInstanceCharacter(instance)
    return Osiris.GetFirstFact("DB_AMER_UI_UsersInUI", instance, nil, nil)[3]
end

---Returns the instance ID of char.
---@param char EsvCharacter|GUID
---@return integer
function Support._GetInstanceID(char)
    local charGuid = GetExtType(char) ~= nil and char.RootTemplate.Id .. "_" .. char.MyGuid or char -- Object overload.
    return Osiris.GetFirstFact("DB_AMER_UI_UsersInUI", nil, nil, charGuid)[1]
end

---Returns the current page of an instance.
---@param instance integer
---@return string, integer -- Page ID and stack index.
function Support._GetCurrentPage(instance)
    local fact = Osiris.GetFirstFact("DB_AMER_UI_CurrentPage", instance, nil, nil, nil)
    return fact[3], fact[4]
end

---Returns the current UI of an instance.
---@param instance integer
---@return string
function Support._GetCurrentUI(instance)
    local fact = Osiris.GetFirstFact("DB_AMER_UI_CurrentPage", instance, nil, nil, nil)
    return fact[2]
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
    local element = Osi.DB_AMER_UI_ElementsOfInstance:Get(instanceID, Support._GetCurrentUI(instanceID), payload.CollectionID, payload.ElementID, nil)[1][5]
    Osiris.CharacterUseItem(char, element, payload.EventID)
end)

-- Handle requests to scroll and interact with wheels.
Net.RegisterListener(Support.NETMSG_SCROLL_WHEEL, function (payload)
    local instanceID = Support._GetInstanceID(payload:GetCharacter())
    -- TODO page sanity checks
    Support.ScrollWheel(instanceID, Support._GetCurrentUI(instanceID), payload.WheelID, payload.Direction)
end)
Net.RegisterListener(Support.NETMSG_INTERACT_WHEEL, function (payload)
    local char = payload:GetCharacter()
    local instanceID = Support._GetInstanceID(char)
    -- TODO page sanity checks
    local tuples = Osi.DB_AMER_UI_ElementsOfInstance:Get(instanceID, Support._GetCurrentUI(instanceID), payload.WheelID, nil, nil)
    local element = tuples[2][5] -- The center element of the wheel is the one that's used to navigate to other pages.
    Osiris.CharacterUseItem(char, element, payload.EventID)
end)

-- Exit the UI when lua is reset, for testing convenience,
-- as the libraries do not support the UI being open right after initialization.
Ext.Events.ResetCompleted:Subscribe(function (_)
    local host = Character.Get(Osiris.CharacterGetHostCharacter())
    Support.ExitUI(host)
end)

-- Handle requests to return to the previous page or exit the UI.
Net.RegisterListener(Support.NETMSG_BACK, function (payload)
    local char = payload:GetCharacter()
    Support.ReturnToPreviousPage(char)
end)
Net.RegisterListener(Support.NETMSG_EXIT, function (payload)
    local char = payload:GetCharacter()
    Support.ExitUI(char)
end)
