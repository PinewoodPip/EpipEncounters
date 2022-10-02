
Game.Ascension = {

    MEDITATING_STATUS = "UI_MUTED",

    ELEMENT_TEMPLATES = {
        CLUSTER_WHEEL_RIGHT = "47df5011-a80b-4969-96dc-e9a5a84916ef",
        CLUSTER_WHEEL_LEFT = "dbc232f2-3b1d-4ce5-9b26-d5fe02abd4fd",
    },
}
local Ascension = Game.Ascension
Epip.InitializeLibrary("Ascension", Ascension)

function Ascension:FireEvent(id, ...)
    Utilities.Hooks.FireEvent("Ascension", id, ...)
end

function Ascension:RegisterListener(id, handler)
    Utilities.Hooks.RegisterListener("Ascension", id, handler)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for wheels being scrolled.
Game.AMERUI:RegisterListener("ElementWheelScrolled", function(item, direction)
    item = Ext.GetItem(item)
    templateId = item.RootTemplate.Id
    
    if templateId == Ascension.ELEMENT_TEMPLATES.CLUSTER_WHEEL_LEFT or templateId == Ascension.ELEMENT_TEMPLATES.CLUSTER_WHEEL_RIGHT then
        Ascension:FireEvent("ClusterWheelScrolled", direction)
    end
end)