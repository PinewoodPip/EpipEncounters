
---@class Feature_InfiniteCarryWeight
local Encumbrance = Epip.GetFeature("Feature_InfiniteCarryWeight")
local PartyInventory = Client.UI.PartyInventory

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_ToggleEncumbrance", function(payload)
    Encumbrance.Toggle(payload.Enabled)
end)

-- Edit the carry weight label to not show the maximum.
PartyInventory.Hooks.GetUpdate:Subscribe(function (e)
    if Encumbrance:IsEnabled() then
        for _,data in ipairs(e.GoldAndCarryWeight) do
            local weight = data.WeightLabel:match("^(%d+)/%d+$")

            data.WeightLabel = weight
        end
    end
end)