
local Actions = {}
Epip.AddFeature("DefaultHotbarActions", "DefaultHotbarActions", Actions)

-- Pyramid
Game.Net.RegisterListener("EPIP_UseTeleporterPyramid", function(cmd, payload)
    local char = Ext.GetCharacter(payload.NetID)

    Osi.PROC_PIP_UseTeleporterPyramid(char.MyGuid)
end)