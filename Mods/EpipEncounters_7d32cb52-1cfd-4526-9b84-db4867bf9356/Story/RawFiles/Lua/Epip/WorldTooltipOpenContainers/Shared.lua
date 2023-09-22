
---@class Feature_WorldTooltipOpenContainers : Feature
local OpenContainers = {
    NETMSG_REQUEST_CANCEL = "Features.WorldTooltipOpenContainers.NetMsg.RequestCancel",
}
Epip.RegisterFeature("WorldTooltipOpenContainers", OpenContainers)

---------------------------------------------
-- NET MESSAGES
---------------------------------------------

---@class EPIPENCOUNTERS_Feature_WorldTooltipOpenContainers_OpenContainer : NetMessage
---@field CharacterNetID NetId
---@field ItemNetID NetId

---@class Features.WorldTooltipOpenContainers.NetMsg.RequestCancel : NetLib_Message_Character