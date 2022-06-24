
local Controller = Epip.Features.AMERUI_Controller

local Handler = Controller.PageHandler.Create({
    INTERFACE = "AMER_UI_Ascension",
    PAGE = "Page_Gateway",
})

Handler:RegisterInputHandler(Controller.INPUTS.BUTTONS.A, function(input)
    Controller.SendServerCommand("SelectCluster")
end)

Handler:RegisterInputHandler(Controller.INPUTS.BUTTONS.B, function(input)
    Controller.ReturnToPreviousPage()
end)

local function ScrollLeft()
    Controller.SendServerCommand("ScrollLeft")
end

local function ScrollRight()
    Controller.SendServerCommand("ScrollRight")
end

Handler:RegisterInputHandler(Controller.INPUTS.BUTTONS.LB, ScrollLeft)
Handler:RegisterInputHandler(Controller.INPUTS.BUTTONS.RB, ScrollRight)

Handler:RegisterInputHandler(Controller.INPUTS.MOVEMENT.LEFT, ScrollLeft)
Handler:RegisterInputHandler(Controller.INPUTS.MOVEMENT.RIGHT, ScrollRight)