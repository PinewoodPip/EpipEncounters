

---@class Feature_DebugCheats
local DebugCheats = Epip.GetFeature("Feature_DebugCheats")

local action = DebugCheats.GetAction("CopyPosition") ---@cast action Feature_DebugCheats_Action_Position

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the action being executed.
action:Subscribe(function (ev)
    local position = ev.Context.Position

    -- Convert to 2D position
    position = Vector.Create(position[1], position[3])
    local text = Text.Format("%s, %s", {
        FormatArgs = {position:unpack()}
    })

    Client.CopyToClipboard(text)
    Client.UI.Notification.ShowNotification(text)
end)