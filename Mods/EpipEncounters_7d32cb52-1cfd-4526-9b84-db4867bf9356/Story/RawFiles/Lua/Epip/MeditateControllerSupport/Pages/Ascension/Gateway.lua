
local Support = Epip.GetFeature("Features.MeditateControllerSupport")

---@type Features.MeditateControllerSupport.Page.Wheel
local Gateway = {
    UI = "AMER_UI_Ascension",
    ID = "Page_Gateway",
    Type = "Wheel",
    WheelID = "PathWheel",
    SelectEventID = "AMER_UI_Ascension_ClusterChosen",
}

GameState.Events.ClientReady:Subscribe(function (_)
    Support.Overlay.RegisterPage(Gateway)
end)
