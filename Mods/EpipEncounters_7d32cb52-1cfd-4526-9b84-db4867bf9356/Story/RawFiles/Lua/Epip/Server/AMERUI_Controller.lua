
local Controller = {
    Events = {
        ---@type AMERUI_ControllerServer_Event_CommandReceived
        CommandReceived = {},
        ELEMENT_CHAINS = {
            PATH_WHEEL = "PathWheel",
        }
    },
}
Epip.RegisterFeature("AMERUI_Controller", Controller)

---@class AMERUI_ControllerServer_Event_CommandReceived : Event
---@field RegisterListener fun(self, listener:fun(command:string, char:EsvCharacter))
---@field Fire fun(self, command:string, char:EsvCharacter)

---------------------------------------------
-- METHODS
---------------------------------------------

function Controller.GetItemGUID(instance, interface, element)
    if type(instance) == "userdata" then
        local state = Controller.GetState(instance)
        instance = state.Instance
        interface = state.Interface
    end

    local _, _, _, _, guid = Osiris.DB_AMER_UI_ElementsOfInstance:Get(instance, interface, element, nil, nil)

    return guid
end

function Controller.RegisterCommandHandler(interface, page, command, handler)
    Controller:RegisterListener(string.format("%s_%s_CommandReceived_%s", interface, page, command), handler)
end

function Controller.GetState(char)
    ---@type AMERUI_CharacterState
    local state = {}
    local instance, ui, _ = Osiris.DB_AMER_UI_UsersInUI:Get(nil, nil, Utilities.GetPrefixedGUID(char))
    local _, _, page, _ = Osiris.DB_AMER_UI_CurrentPage:Get(instance, ui, nil, nil)

    state.Instance = instance
    state.Interface = ui
    state.Page = page

    return state
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_ControllerSupport_Command", function(payload)
    local command = payload.Command
    local char = Ext.GetCharacter(payload.NetID)
    local state = Controller.GetState(char)

    Controller:DebugLog("Command received: " .. command)
    Controller.Events.CommandReceived:Fire(command, char)
    Controller:FireEvent(string.format("%s_%s_CommandReceived_%s", state.Interface, state.Page, command), char)
end)

Controller.Events.CommandReceived:RegisterListener(function (command, char)
    if command == "ReturnToPreviousPage" then
        local instance, ui, _ = Osiris.DB_AMER_UI_UsersInUI(nil, nil, char.MyGuid)

        if instance ~= nil then
            local _, stackCount = Osiris.DB_AMER_UI_PageStack_Count(instance, nil)

            -- Pop page if there are any. We don't call the method directly as there are some special listeners for it to manipulate the stack in the Greatforge UI.
            if stackCount and stackCount > 0 and ui ~= "AMER_UI_ModSettings" then
                Osi.CharacterItemEvent(char.MyGuid, NULLGUID, "AMER_UI_GEN_PagePop")
            else -- Exit UI otherwise
                Osi.PROC_AMER_UI_ExitUI(char.MyGuid)
            end
        end
    end
end)

---------------------------------------------
-- ASCENSION GATEWAY
---------------------------------------------

Controller.RegisterCommandHandler("AMER_UI_Ascension", "Page_Gateway", "SelectCluster", function(char)
    local item = Controller.GetItemGUID(char, nil, "PathWheel")
    local state = Controller.GetState(char)
    local _, _, _, elementName, _, visibleElementsQuery = Osiris.DB_AMER_UI_ElementsOfInstance:Get(state.Instance, "AMER_UI_Ascension", "PathWheel", nil, nil)

    elementName = visibleElementsQuery[2][4]

    ---@diagnostic disable: unused-local
    local _, _, _, cluster, index, _, tuples = Osiris.DB_AMER_UI_ElementWheel_Element(state.Instance, "AMER_UI_Ascension", "PathWheel", elementName, nil, nil)

    local _, _, _, vindex, index2, _, _, guid, tuples2 = Osiris.DB_AMER_UI_ElementWheel_Visible(state.Instance, "AMER_UI_Ascension", "PathWheel", nil, index, nil, nil, nil)
    ---@diagnostic enable: unused-local

    item = Ext.GetItem(item)
    guid = item.CurrentTemplate.Name .. "_" .. guid

    Osi.CharacterItemEvent(Utilities.GetPrefixedGUID(char), guid, "AMER_UI_Ascension_ClusterChosen")
end)

Controller.RegisterCommandHandler("AMER_UI_Ascension", "Page_Gateway", "ScrollRight", function(char)
    local item = Controller.GetItemGUID(char, nil, "PathWheel")

    Osi.PROC_AMER_UI_ElementWheel_Scroll_Down(Utilities.GetPrefixedGUID(char), item)
end)

Controller.RegisterCommandHandler("AMER_UI_Ascension", "Page_Gateway", "ScrollLeft", function(char)
    local item = Controller.GetItemGUID(char, nil, "PathWheel")

    Osi.PROC_AMER_UI_ElementWheel_Scroll_Up(Utilities.GetPrefixedGUID(char), item)
end)