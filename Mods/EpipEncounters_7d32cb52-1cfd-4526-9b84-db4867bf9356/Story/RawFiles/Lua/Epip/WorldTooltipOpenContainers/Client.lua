
local WorldTooltip = Client.UI.WorldTooltip
local Input = Client.Input

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

-- Request the move-and-use tasks to be cancelled when pressing right-click or escape.
Input.Events.KeyStateChanged:Subscribe(function (ev)
    if (ev.State == "Released" and ev.InputID == "right2") or (ev.InputID == "escape") then -- For right-click, the timing the game uses for cancelling regular movement is on-release.
        local char = Client.GetCharacter()
        if OpenContainers.IsTaskRunning(char) then
            Net.PostToServer(OpenContainers.NETMSG_REQUEST_CANCEL, {CharacterNetID = char.NetID})

            -- Prevent pause menu from being brought up.
            if ev.InputID == "escape" then
                ev:Prevent()
            end
        end
    end
end)
