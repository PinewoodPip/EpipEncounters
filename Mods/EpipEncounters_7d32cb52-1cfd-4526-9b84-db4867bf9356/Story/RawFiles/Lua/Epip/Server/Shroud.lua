
---------------------------------------------
-- Server scripting for the toggle shroud option.
---------------------------------------------

Epip.Features.Shroud = {

    STATE = {
        UNSET = -1,
        DISABLED = 0,
        ENABLED = 1,
    },

    ---------------------------------------------
    -- INTERNAL VARIABLES - DO NOT SET
    ---------------------------------------------
    queriedState = -1,
}
local Shroud = Epip.Features.Shroud

---------------------------------------------
-- LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_ServerOptionChanged", function(payload)
    if payload.Mod == "EpipEncounters" and payload.Setting == "RenderShroud" then
        Shroud.queriedState = payload.Value
        Osi.ShroudRender(Shroud.queriedState)
    end
end)

Ext.Osiris.RegisterListener("RegionStarted", 1, "after", function(level)
    if Shroud.queriedState ~= Shroud.STATE.UNSET then
        Osi.ShroudRender(Shroud.queriedState)
    end
end)