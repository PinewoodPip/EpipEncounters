
-- Sends surface data to client on request.
Net.RegisterListener("EPIPENCOUNTERS_GetSurfaceData", function(_, payload)
    local position = payload.Position
    local charNetID = payload.CharacterNetID
    local cell = Ext.Entity.GetAiGrid():GetCellInfo(position[1], position[3])
    
    if cell then
        local groundSurface
        local cloudSurface
        local groundSurfaceOwnerNetID
        local cloudSurfaceOwnerNetID
        
        if cell.CloudSurface then
            cloudSurface = Ext.Entity.GetSurface(cell.CloudSurface)
        end
        if cell.GroundSurface then
            groundSurface = Ext.Entity.GetSurface(cell.GroundSurface)
        end
        
        if groundSurface then
            local owner = Ext.Entity.GetGameObject(groundSurface.OwnerHandle)
            local netID = nil
            if owner then netID = owner.NetID end

            groundSurfaceOwnerNetID = netID
        end
        if cloudSurface then
            local owner = Ext.Entity.GetGameObject(cloudSurface.OwnerHandle)
            local netID = nil
            if owner then netID = owner.NetID end

            cloudSurfaceOwnerNetID = netID
        end

        Net.PostToCharacter(Character.Get(charNetID), "EPIPENCOUNTERS_ReturnSurfaceData", {
            GroundSurfaceOwnerNetID = groundSurfaceOwnerNetID,
            CloudSurfaceOwnerNetID = cloudSurfaceOwnerNetID,
        })
    end
end)