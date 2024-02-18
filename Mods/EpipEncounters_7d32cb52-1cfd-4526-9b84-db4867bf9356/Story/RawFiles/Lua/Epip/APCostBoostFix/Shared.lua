
---@class Feature_APCostBoostFix : Feature
local Fix = {
    NETMSG_ATTACK = "Features.APCostBoostFix.NetMsg.Attack",
}
Epip.RegisterFeature("APCostBoostFix", Fix)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIPENCOUNTERS_UseItem
---@field CharacterNetID NetId
---@field ItemNetID NetId

---@class Features.APCostBoostFix.NetMsg.Attack
---@field AttackerNetID NetId
---@field TargetNetID NetId
