
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

Settings.Events.SettingValueChanged:Subscribe(function (ev)
    local setting = ev.Setting

    if setting.ModTable == "EpipEncounters" and setting.ID == "RenderShroud" then
        Shroud.queriedState = ev.Value
        
        Osi.ShroudRender(Shroud.queriedState)
    end
end)

Ext.Osiris.RegisterListener("RegionStarted", 1, "after", function(level)
    if Shroud.queriedState ~= Shroud.STATE.UNSET then
        Osi.ShroudRender(Shroud.queriedState)
    end
end)