
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

-- Listen for requests to attack.
Net.RegisterListener(Fix.NETMSG_ATTACK, function (payload)
    local attacker = Character.Get(payload.AttackerNetID)
    local target = Character.Get(payload.TargetNetID) or Item.Get(payload.TargetNetID)

    Osiris.CharacterAttack(attacker, target)
end)
