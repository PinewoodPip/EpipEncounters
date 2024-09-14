
local Support = Epip.GetFeature("Features.MeditateControllerSupport")

---@type Features.MeditateControllerSupport.Page.AspectGraph
local Aspect = {
    UI = "AMER_UI_Ascension",
    ID = "Page_Cluster",
    Type = "AspectGraph",
}

GameState.Events.ClientReady:Subscribe(function (_)
    Support.Overlay.RegisterPage(Aspect)
end)
