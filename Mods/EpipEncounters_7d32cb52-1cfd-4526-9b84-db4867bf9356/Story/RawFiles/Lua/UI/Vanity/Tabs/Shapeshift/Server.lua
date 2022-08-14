
---@class VanityShapeshift
local Shapeshift = Epip.Features.VanityShapeshift

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

local function ClearStatuses(char)
    for _,form in pairs(Shapeshift.FORMS) do
        local statusName = form:GetStatusName()

        Osi.RemoveStatus(char.MyGuid, statusName)
    end
end

Net.RegisterListener("EPIPENCOUNTERS_Vanity_Shapeshift_Revert", function(payload)
    local char = Character.Get(payload.NetID)

    ClearStatuses(char)
end)

Net.RegisterListener("EPIPENCOUNTERS_Vanity_Shapeshift_Apply", function(payload)
    local char = Character.Get(payload.NetID)
    local form = Shapeshift.GetForm(payload.TemplateGUID)
    local statusName = form:GetStatusName()
    
    ClearStatuses(char)

    Osi.ApplyStatus(char.MyGuid, statusName, -1, 1, char.MyGuid)
end)