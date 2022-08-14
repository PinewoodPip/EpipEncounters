
---@class Feature_Housing : Feature
local Housing = Epip.Features.Housing

---------------------------------------------
-- METHODS
---------------------------------------------

---@param furniture GUID|Feature_Housing_Furniture
---@param position Vector3D
function Housing.SpawnFurniture(furniture, position)
    local x, y, z = Osi.FindValidPosition(position[1], position[2] + 20, position[3], 10, NULLGUID)
    local objGUID = Osi.CreateItemTemplateAtPosition(furniture.TemplateGUID, x, y, z)

    Housing:DebugLog("Furniture spawned: ", furniture.Name, objGUID)
end

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

-- Listen for furniture being moved.
Net.RegisterListener("EPIPENCOUNTERS_Housing_PlaceMovingFurniture", function(payload)
    local obj = Item.Get(payload.ObjNetID)
    local position = payload.Position

    Osi.TeleportToPosition(obj.MyGuid, position[1], position[2], position[3], "", 0, 0)

    Housing:DebugLog("Item teleported: ", obj.DisplayName)
end)

-- Spawn furniture.
Net.RegisterListener("EPIPENCOUNTERS_Housing_SpawnFurniture", function(payload)
    Housing.SpawnFurniture(Housing.GetFurniture(payload.FurnitureGUID), payload.Position)
end)