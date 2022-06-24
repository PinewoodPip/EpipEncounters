
local Controller = Epip.Features.AMERUI_Controller

local Handler = Controller.PageHandler.Create({
    INTERFACE = "AMER_UI_Ascension",
    PAGE = "Page_MainHub",
})

Handler:RegisterInputHandler(Controller.INPUTS.BUTTONS.A, function(input)
    print("A pressed")
end)

Handler:RegisterInputHandler(Controller.INPUTS.BUTTONS.B, function(input)
    print("B pressed")
    Controller.ReturnToPreviousPage()
end)