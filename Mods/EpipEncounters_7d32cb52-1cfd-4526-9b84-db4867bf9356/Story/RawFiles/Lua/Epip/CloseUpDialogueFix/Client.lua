
---------------------------------------------
-- Fixes the camera being too close to the ground when using
-- the "Close-up dialogue" vanilla setting.
---------------------------------------------

local Camera = Client.Camera

---@type Feature
local CameraFix = {
    CAMERA_DISTANCE = 8.75,

    EVENTID_TICK_UPDATE = "Features.CloseUpDialogueFix.Update",
}
Epip.RegisterFeature("Features.CloseUpDialogueFix", CameraFix)

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Zoom out the camera upon entering dialogue.
Client.Events.InDialogueStateChanged:Subscribe(function (ev)
    if ev.InDialogue then
        -- Update the distance every tick, as it resets
        -- when targets change (ex. when a different character starts talking).
        GameState.Events.RunningTick:Subscribe(function (_)
            local camera = Camera.GetPlayerCamera()
            if GetExtType(camera) == "ecl::GameCamera" then -- There's dialogue in the game that can occur during cutscenes that use a different camera.
                ---@cast camera EclGameCamera
                camera.TargetCameraDistance = CameraFix.CAMERA_DISTANCE
            end
            if not Client.IsInDialogue() then
                GameState.Events.RunningTick:Unsubscribe(CameraFix.EVENTID_TICK_UPDATE)
            end
        end, {StringID = CameraFix.EVENTID_TICK_UPDATE})
    end
end, {EnabledFunctor = function ()
    return Ext.Utils.GetGlobalSwitches().GameCameraEnableCloseUpDialog
end})
