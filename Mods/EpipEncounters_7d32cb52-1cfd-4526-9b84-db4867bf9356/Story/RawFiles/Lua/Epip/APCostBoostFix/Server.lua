
---@class Feature_APCostBoostFix
local Fix = Epip.GetFeature("EpipEncounters", "APCostBoostFix")

---------------------------------------------
-- EVENT LISTENERS
---------------------------------------------

Net.RegisterListener("EPIPENCOUNTERS_UseItem", function (payload)
    local char = Character.Get(payload.CharacterNetID)
    local item = Item.Get(payload.ItemNetID)

    Osiris.CharacterUseItem(char, item, "")
end)