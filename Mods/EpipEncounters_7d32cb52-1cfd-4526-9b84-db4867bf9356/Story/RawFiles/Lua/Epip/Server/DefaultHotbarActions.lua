
local Actions = {}
Epip.AddFeature("DefaultHotbarActions", "DefaultHotbarActions", Actions)

-- Pyramid
Net.RegisterListener("EPIP_UseTeleporterPyramid", function(payload)
    local char = Ext.GetCharacter(payload.NetID)

    Osi.PROC_PIP_UseTeleporterPyramid(char.MyGuid)
end)