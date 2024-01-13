
---@class Features.SurfacePainter : Feature
local SurfacePainter = {
    NETMSG_PAINT_REQUEST = "Features.SurfacePainter.NetMsg.PaintRequest",

    ---Surfaces that cannot accept modifiers (Blessed, Cursed, Purified)
    ---@type table<SurfaceType, true>
    SURFACES_WITH_NO_MODIFIERS = {
        ["Lava"] = true,
        ["Source"] = true,
        ["Deepwater"] = true,
        ["ExplosionCloud"] = true,
        ["FrostCloud"] = true,
        ["Deathfog"] = true,
        ["ShockwaveCloud"] = true,
    },

    TranslatedStrings = {
        InputAction_Paint_Name = {
            Handle = "hea5cb90ag194cg4fcag8100gbfa79d33b150",
            Text = "Paint Surface",
            ContextDescription = "Keybind name",
        },
        InputAction_Paint_Description = {
            Handle = "h2bbdd581g5f42g436fgafbbg923568599545",
            Text = "Creates a surface at the cursor's world position, if the Surface Painter UI is open.",
            ContextDescription = "Keybind tooltip",
        },
    },

    Hooks = {
        GetSurfaceData = {}, ---@type Hook<Features.SurfacePainter.Hooks.GetSurfaceData>
    },

    USE_LEGACY_EVENTS = false,
    USE_LEGACY_HOOKS = false,
}
Epip.RegisterFeature("Features.SurfacePainter", SurfacePainter)

---------------------------------------------
-- CLASSES
---------------------------------------------

---@class Features.SurfacePainter.PaintRequest
---@field Position Vector3
---@field SurfaceType SurfaceType|string
---@field Radius number
---@field LifeTime integer In seconds.

---------------------------------------------
-- EVENTS/HOOKS
---------------------------------------------

---@class Features.SurfacePainter.Hooks.GetSurfaceData
---@field Request Features.SurfacePainter.PaintRequest? Hookable. Defaults to `nil`.

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class Features.SurfacePainter.NetMsg.PaintRequest : Features.SurfacePainter.PaintRequest
