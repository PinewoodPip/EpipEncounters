
local Input = Client.Input

---@class Features.SurfacePainter
local SurfacePainter = Epip.GetFeature("Features.SurfacePainter")
local TSK = SurfacePainter.TranslatedStrings

local InputActions = {
    Paint = SurfacePainter:RegisterInputAction("Paint", {
        Name = TSK.InputAction_Paint_Name,
        Description = TSK.InputAction_Paint_Description,
        DeveloperOnly = true,
    }),
}

---------------------------------------------
-- METHODS
---------------------------------------------

---Requests a surface to be painted.
---@see Features.SurfacePainter.Hooks.GetSurfaceData
---@param request Features.SurfacePainter.PaintRequest? If `nil`, will be set from hooks.
function SurfacePainter.RequestPaint(request)
    request = request or SurfacePainter.Hooks.GetSurfaceData:Throw({Request = nil}).Request
    if not request then
        SurfacePainter:LogWarning("No hooks fulfilled a paint request")
        return
    end

    Net.PostToServer(SurfacePainter.NETMSG_PAINT_REQUEST, request)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for the Paint input action.
Input.Events.ActionExecuted:Subscribe(function (ev)
    if ev.Action:GetID() == InputActions.Paint:GetID() then
        SurfacePainter.RequestPaint()
    end
end)
