
---------------------------------------------
-- Workaround for an issue where synchronizing GUIDs to
-- new player-controlled summons through a UserVars sync
-- would cause the "Journal updated" notification to show.
-- For writing UserVars after they are spawned, Apply() should be called manually.
-- This also potentially applies for other player-controlled entities
-- that might have no GUID on the client.
---------------------------------------------

local Notification = Client.UI.Notification

---@class Features.UservarsGUIDSyncWorkaround : Feature
local Workaround = {
    PLAYERINFO_ADD_SUMMON_WORKAROUND_DURATION = 1, -- Duration to apply the workaround for whenever a playable summon is added to the PlayerInfo UI.
    JOURNAL_UPDATED_SOUND_EVENT = "UI_Notification_JournalUpdate",

    _ShouldPreventNotification = false,
}
Epip.RegisterFeature("Features.UservarsGUIDSyncWorkaround", Workaround)

---------------------------------------------
-- METHODS
---------------------------------------------

---Prevents the journal updated notification from showing up for the specified duration.
---Call before writing a UserVar to a playable entity with no GUID on the client for the first time.
---@param duration number In seconds.
function Workaround.Apply(duration)
    Workaround._ShouldPreventNotification = true
    Timer.Start(duration, function (_)
        Workaround._ShouldPreventNotification = false
    end)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for player summons being added and apply the workaround.
-- Writing UserVars to them when they spawn is a common cause of this bug, as they do not have GUIDs on the client.
-- For writing UserVars after they are spawned, Apply() should be called manually.
Client.UI.PlayerInfo:RegisterInvokeListener("addSummonInfo", function (_)
    Workaround.Apply(Workaround.PLAYERINFO_ADD_SUMMON_WORKAROUND_DURATION)
end)

-- Prevent the "Journal updated" notification while the workaround is active.
Notification.Hooks.ShowReceivalNotification:Subscribe(function (ev)
    if ev.Sound == Workaround.JOURNAL_UPDATED_SOUND_EVENT and Workaround._ShouldPreventNotification then
        ev.Prevent = true
        -- We do not un-set the workaround flag as there might be multiple writes occurring at once - we want the workaround to stay active for the duration.
    end
end)