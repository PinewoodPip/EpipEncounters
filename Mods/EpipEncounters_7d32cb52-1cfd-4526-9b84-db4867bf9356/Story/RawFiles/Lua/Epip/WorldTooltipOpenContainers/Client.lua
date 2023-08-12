
local WorldTooltip = Client.UI.WorldTooltip

---@class Feature_WorldTooltipOpenContainers
local OpenContainers = Epip.GetFeature("WorldTooltipOpenContainers")
OpenContainers.SETTING_ID = "WorldTooltip_OpenContainers"

---------------------------------------------
-- METHODS
---------------------------------------------

---@override
function OpenContainers:IsEnabled()
    return Settings.GetSettingValue("Epip_Tooltips", OpenContainers.SETTING_ID) and _Feature.IsEnabled(self)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for tooltips being clicked.
WorldTooltip.Events.TooltipClicked:Subscribe(function (ev)
    if ev.Item and Item.IsContainer(ev.Item) and OpenContainers:IsEnabled() then
        OpenContainers:DebugLog("Attempting to use", ev.Item.DisplayName)

        Net.PostToServer("EPIPENCOUNTERS_Feature_WorldTooltipOpenContainers_OpenContainer", {
            CharacterNetID = Client.GetCharacter().NetID,
            ItemNetID = ev.Item.NetID,
        })

        ev:Prevent()
    end
end)