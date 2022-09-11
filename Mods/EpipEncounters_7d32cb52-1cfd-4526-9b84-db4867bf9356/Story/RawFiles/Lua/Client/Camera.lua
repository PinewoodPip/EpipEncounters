
---@class CameraLib : Library
local Camera = {}
Client.Camera = Camera

---------------------------------------------
-- METHODS
---------------------------------------------

---@param playerIndex integer? Defaults to 1.
---@return RfCameraController
function Camera.GetPlayerCamera(playerIndex)
    local playerManager = Ext.Entity.GetPlayerManager()
    local player = playerManager.ClientPlayerData[playerIndex or 1]
    local cameraID = player.CameraControllerId
    local cameraManager = Ext.Client.GetCameraManager()

    return cameraManager.Controllers[cameraID]
end

---@param mode integer? Defaults to 0.
---@return GlobalCameraSwitches
function Camera.GetGlobalSwitches(mode)
    return Ext.Utils.GetGlobalSwitches()["CameraSwitchesMode" .. (mode or 0)]
end