
local EVENTS = Client.Input.FLASH_EVENTS
local Input = Client.UI.Input
local Controller = {
    ---@type AMERUI_Controller_PageHandler
    PageHandler = nil,
    INTERFACE_EVENTS = {
        [EVENTS.ACCEPT] = "A",
        [EVENTS.TAB_NEXT] = "RB",
        [EVENTS.CANCEL] = "B",
        [EVENTS.TAB_PREV] = "LB",
        [EVENTS.UP] = "Up",
        [EVENTS.DOWN] = "Down",
        [EVENTS.LEFT] = "Left",
        [EVENTS.RIGHT] = "Right",
        [EVENTS.CONTROLLER_CONTEXT_MENU] = "X",
    },
    INPUTS = {
        BUTTONS = {
            A = "A",
            B = "B",
            RB = "RB",
            LB = "LB",
            X = "X",
            Y = "Y", -- TODO!
        },
        MOVEMENT = {
            LEFT = "Left",
            RIGHT = "Right",
            DOWN = "Down",
            UP = "Up",
        }
    },
    PAGE_HANDLERS = {},
    COMMAND_NET_CHANNEL = "EPIPENCOUNTERS_ControllerSupport_Command",
    Hooks = {},
    Events = {
        ---@type AMERUI_Controller_Event_InputSent
        InputSent = {},
    },
}

Epip.Features.AMERUI_Controller = Controller

---@class ControllerInput
---@field ID string
---@field StickAxisX number
---@field StickAxisY number

Epip.AddFeature("AMERUI_Controller", "AMERUI_Controller", Controller)
Controller:Debug()

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class AMERUI_Controller_Event_InputSent : Event
---@field RegisterListener fun(self, listener:fun(input:ControllerInput))
---@field Fire fun(self, input:ControllerInput)

---------------------------------------------
-- METHODS
---------------------------------------------

---@param query AMERUI_Controller_PageHandler
function Controller.IsCurrentPage(handler)
    local pageID = query
    if type(query) == "table" then pageID = query.PAGE end

    ---@type AMERUI_CharacterState
    local state = Game.AMERUI.GetState()

    return state.Interface == handler.INTERFACE and state.Page == handler.PAGE
end

---------------------------------------------
-- PAGE HANDLER CLASS
---------------------------------------------

---@class AMERUI_Controller_PageHandler
---@field PAGE string Page ID.
---@field INTERFACE string Interface ID.

---@type AMERUI_Controller_PageHandler
_AMERUI_PageHandler = {
    PAGE = "",
    INTERFACE = "",
}

---Creates a new page handler.
---@param handler table
---@return AMERUI_Controller_PageHandler
function _AMERUI_PageHandler.Create(handler)
    setmetatable(handler, {__index = _AMERUI_PageHandler})

    if not handler.PAGE or not handler.INTERFACE then
        Controller:LogError("Page handlers must define INTERFACE and PAGE IDs.")
        return nil
    end

    return handler
end

---Register a listener for an input. Fires only when the page is currently active.
---@param button string Input ID.
---@param handler fun(input:ControllerInput)
function _AMERUI_PageHandler:RegisterInputHandler(button, handler)
    Controller:RegisterListener(self.INTERFACE .. "_" .. self.PAGE .. "_InputCaptured_" .. button, handler)
end

Controller.PageHandler = _AMERUI_PageHandler

---------------------------------------------
-- COMMON CONTROLS
---------------------------------------------

function Controller.ReturnToPreviousPage()
    Controller.SendServerCommand("ReturnToPreviousPage")
end

function Controller.SendServerCommand(command, data)
    Net.PostToServer(Controller.COMMAND_NET_CHANNEL, {
        Command = command,
        NetID = Client.GetCharacter().NetID,
        Data = data,
    })
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Input.Events.EventCaptured:RegisterListener(function (event)
    ---@type ControllerInput
    local input = {
        ID = Controller.INTERFACE_EVENTS[event],
        StickAxisX = 0, -- TODO
        StickAxisY = 0, -- TODO
    }

    ---@type AMERUI_CharacterState
    local state = Game.AMERUI.GetState()

    if state then
        local event = state.Interface .. "_" .. state.Page .. "_InputCaptured_" .. input.ID

        Controller:FireEvent(event, input)

        print(event)
    end
end)


Game.Ascension:RegisterListener("ClientToggledMeditating", function(state)
    for event,name in pairs(Controller.INTERFACE_EVENTS) do
        Input.ToggleEventCapture(event, state, "PIP_AMERUI_Controller")
    end

    Controller:DebugLog("Changed state: " .. tostring(state))
end)