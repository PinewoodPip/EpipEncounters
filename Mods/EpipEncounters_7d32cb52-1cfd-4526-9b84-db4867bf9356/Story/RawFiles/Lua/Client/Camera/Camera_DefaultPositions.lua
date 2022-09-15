
---@class CameraLib
local Camera = Client.Camera
Camera._DefaultPositions = {
    Mode0 = {
        Combat = {
            ZoomedOut = Vector.Create(
                0.46236446499824524,
                0.75659638643264771,
                -0.46236446499824524
            ),
            ZoomedIn = Vector.Create(
                0.59481185674667358,
                0.54073804616928101,
                -0.59481185674667358
            ),
        },
        Controller = {
            ZoomedOut = Vector.Create(
                0.53900372982025146,
                0.63881921768188477,
                -0.54898530244827271
            ),
            ZoomedIn = Vector.Create(
                0.5951041579246521,
                0.54009449481964111,
                -0.5951041579246521
            ),
        },
        Overhead = {
            ZoomedOut = Vector.Create(
                0.054834380745887756,
                0.99698871374130249,
                -0.054834380745887756
            ),
            ZoomedIn = Vector.Create(
                0.054834380745887756,
                0.99698871374130249,
                -0.054834380745887756
            ),
        },
        Default = {
            ZoomedOut = Vector.Create(
                0.49292176961898804,
                0.71697711944580078,
                -0.49292176961898804
            ),
            ZoomedIn = Vector.Create(
                0.59481185674667358,
                0.54073804616928101,
                -0.59481185674667358
            ),
        },
    },
    Mode1 = {
        Combat = {
            ZoomedOut = Vector.Create(
                0.46236446499824524,
                0.75659638643264771,
                -0.46236446499824524
            ),
            ZoomedIn = Vector.Create(
                0.59481185674667358,
                0.54073804616928101,
                -0.59481185674667358
            ),
        },
        Controller = {
            ZoomedOut = Vector.Create(
                0.53900372982025146,
                0.63881921768188477,
                -0.54898530244827271
            ),
            ZoomedIn = Vector.Create(
                0.5951041579246521,
                0.54009449481964111,
                -0.5951041579246521
            ),
        },
        Overhead = {
            ZoomedOut = Vector.Create(
                0.054834380745887756,
                0.99698871374130249,
                -0.054834380745887756
            ),
            ZoomedIn = Vector.Create(
                0.054834380745887756,
                0.99698871374130249,
                -0.054834380745887756
            ),
        },
        Default = {
            ZoomedOut = Vector.Create(
                0.40824827551841736,
                0.81649655103683472,
                -0.40824827551841736
            ),
            ZoomedIn = Vector.Create(
                0.59481185674667358,
                0.54073804616928101,
                -0.59481185674667358
            ),
        },
    },
}

---------------------------------------------
-- METHODS
---------------------------------------------

---@param positionID "Default"|"Combat"|"Controller"|"Overhead"
---@param mode (0|1)? Defaults to mode 0.
---@return {ZoomedOut:Vector3, ZoomedIn:Vector3}
function Camera.GetDefaultPosition(positionID, mode)
    mode = mode or 0

    return Camera._DefaultPositions["Mode" .. mode][positionID]
end