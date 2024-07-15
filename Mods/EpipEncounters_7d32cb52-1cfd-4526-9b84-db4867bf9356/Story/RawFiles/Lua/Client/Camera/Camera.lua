
---@class CameraLib : Library
local Camera = {}
Epip.InitializeLibrary("Camera", Camera)
Client.Camera = Camera

---@alias CameraLib.PositionMode "Default"|"Combat"|"Overhead"|"Controller"

---------------------------------------------
-- METHODS
---------------------------------------------

---@param playerIndex integer? Defaults to `1`.
---@return RfCameraController
function Camera.GetPlayerCamera(playerIndex)
    local playerManager = Ext.Entity.GetPlayerManager()
    local player = playerManager.ClientPlayerData[playerIndex or 1]
    local cameraID = player.CameraControllerId
    local cameraManager = Ext.Client.GetCameraManager()

    return cameraManager.Controllers[cameraID]
end

---Returns the camera's current target distance.
---@return number? -- `nil` if the current camera is not the game one.
function Camera.GetTargetDistance()
    local camera = Camera.GetPlayerCamera()
    local dist = nil
    if GetExtType(camera) == "ecl::GameCamera" then -- There's dialogue in the game that can occur during cutscenes that use a different camera.
        ---@cast camera EclGameCamera
        dist = camera.TargetCameraDistance
    end
    return dist
end

---@param mode (0|1)? Defaults to `0`.
---@return GlobalCameraSwitches
function Camera.GetGlobalSwitches(mode)
    return Ext.Utils.GetGlobalSwitches()["CameraSwitchesMode" .. (mode or 0)]
end

---Returns the current position mode of the game camera.
---**Will never return "Controller", as it is currently unknown when this mode is used. TODO!**
---@param playerIndex integer? Defaults to `1`.
---@return CameraLib.PositionMode? -- `nil` if the current camera is not the game one.
function Camera.GetCurrentPositionMode(playerIndex)
    local gameCamera = Camera.GetPlayerCamera(playerIndex)
    local mode = nil ---@type CameraLib.PositionMode?

    -- Check if the current camera is the game one
    if gameCamera and GetExtType(gameCamera) == "ecl::GameCamera" then
        ---@cast gameCamera EclGameCamera
        if (gameCamera.Flags & 4) ~= 0 then -- Flag 4 appears to correspond to the top-down mode.
            mode = "Overhead"
        elseif Client.IsInCombat() then
            mode = "Combat"
        else
            mode = "Default"
        end
    end

    return mode
end

---Returns the switches for a position.
---@param mode (0|1)? Defaults to `0`.
---@param position CameraLib.PositionMode
---@return Vector3, Vector3
function Camera.GetPositionSwitches(mode, position)
    local switches = Camera.GetGlobalSwitches(mode)
    local infix = position == "Default" and "" or position
    local pos1 = switches["Default" .. infix .. "Position"]
    local pos2 = switches["Default" .. infix .. "Position2"]

    return Vector.Create(pos1), Vector.Create(pos2)
end

---Sets the switches for a position.
---@param mode (0|1)? Defaults to `0`.
---@param position CameraLib.PositionMode
---@param pos1 Vector3
---@param pos2 Vector3
function Camera.SetPositionSwitches(mode, position, pos1, pos2)
    local switches = Camera.GetGlobalSwitches(mode)
    local infix = position == "Default" and "" or position

    switches["Default" .. infix .. "Position"] = pos1
    switches["Default" .. infix .. "Position2"] = pos2
end
