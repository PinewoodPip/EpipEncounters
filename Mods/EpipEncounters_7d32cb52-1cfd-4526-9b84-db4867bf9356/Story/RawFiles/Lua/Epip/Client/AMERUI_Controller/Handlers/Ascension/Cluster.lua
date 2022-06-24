
local Controller = Epip.Features.AMERUI_Controller

local Handler = Controller.PageHandler.Create({
    INTERFACE = "AMER_UI_Ascension",
    PAGE = "Page_Cluster",
})

Handler:RegisterInputHandler(Controller.INPUTS.BUTTONS.B, function(input)
    Controller.ReturnToPreviousPage()
end)