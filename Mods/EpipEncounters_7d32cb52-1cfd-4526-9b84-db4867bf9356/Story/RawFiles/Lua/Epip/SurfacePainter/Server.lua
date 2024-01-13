
---@class Features.SurfacePainter
local SurfacePainter = Epip.GetFeature("Features.SurfacePainter")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for requests to paint a surface.
Net.RegisterListener(SurfacePainter.NETMSG_PAINT_REQUEST, function (payload)
    local x, y, z = payload.Position:unpack()

    -- Weird inconsistency between the enum and what Osiris expects.
    if payload.SurfaceType == "Deathfog" then
        payload.SurfaceType = "DeathfogCloud"
    end

    Osiris.CreateSurfaceAtPosition(x, y, z, "Surface" ..  payload.SurfaceType, payload.Radius, payload.LifeTime)
end)
